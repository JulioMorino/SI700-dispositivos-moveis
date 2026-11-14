// Lógica de decisão do reconhecimento, em Dart puro (sem Flutter), para ser testável.
// É a MESMA regra de ml/common.py -> decide():
//   1. filtro "é rocha?": compara a foto com frases de texto (CLIP zero-shot)
//   2. k-NN: para cada rocha, média das top-k similaridades de cosseno
//   3. limiar: score >= matchThreshold -> reconheceu
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Decodifica o formato do Firestore: base64 de float16 (little-endian) -> Float32List.
Float32List decodeF16Base64(String b64) {
  final bytes = base64Decode(b64);
  final data = ByteData.sublistView(bytes);
  final out = Float32List(bytes.length ~/ 2);
  for (int i = 0; i < out.length; i++) {
    out[i] = _halfToFloat(data.getUint16(i * 2, Endian.little));
  }
  return out;
}

double _halfToFloat(int h) {
  final int sign = (h >> 15) & 0x1;
  final int exp = (h >> 10) & 0x1f;
  final int frac = h & 0x3ff;
  double value;
  if (exp == 0) {
    value = frac * math.pow(2, -24).toDouble(); // subnormal
  } else if (exp == 31) {
    value = frac == 0 ? double.infinity : double.nan;
  } else {
    value = (1 + frac / 1024) * math.pow(2, exp - 15).toDouble();
  }
  return sign == 1 ? -value : value;
}

/// Normaliza o vetor para norma 1 (assim, produto escalar = similaridade de cosseno).
Float32List l2Normalize(List<double> v) {
  double sum = 0;
  for (final x in v) {
    sum += x * x;
  }
  final double norm = math.sqrt(sum);
  final out = Float32List(v.length);
  for (int i = 0; i < v.length; i++) {
    out[i] = norm == 0 ? 0 : v[i] / norm;
  }
  return out;
}

double _dot(Float32List a, Float32List b, int offsetB) {
  double s = 0;
  for (int i = 0; i < a.length; i++) {
    s += a[i] * b[offsetB + i];
  }
  return s;
}

/// Documento recognition_config/current do Firestore.
class RecognitionConfig {
  final String modelVersion;
  final double matchThreshold;
  final double rockThreshold;
  final int topK;
  final double logitScale;
  final int dim;
  final Float32List promptEmbeddings; // [nPrompts * dim]
  final List<bool> promptIsRock;

  RecognitionConfig({
    required this.modelVersion,
    required this.matchThreshold,
    required this.rockThreshold,
    required this.topK,
    required this.logitScale,
    required this.dim,
    required this.promptEmbeddings,
    required this.promptIsRock,
  });

  factory RecognitionConfig.fromMap(Map<String, dynamic> map) {
    return RecognitionConfig(
      modelVersion: map["modelVersion"] as String,
      matchThreshold: (map["matchThreshold"] as num).toDouble(),
      rockThreshold: (map["rockThreshold"] as num).toDouble(),
      topK: (map["topK"] as num).toInt(),
      logitScale: (map["logitScale"] as num).toDouble(),
      dim: (map["dim"] as num).toInt(),
      promptEmbeddings: decodeF16Base64(map["promptEmbeddings"] as String),
      promptIsRock: List<bool>.from(map["promptIsRock"] as List),
    );
  }
}

/// Documento rocks/{id} do Firestore: descrição + vetores das fotos de referência.
class RockReference {
  final String id;
  final String name;
  final String lithology;
  final List<String> minerals;
  final String description;
  final String modelVersion;
  final int dim;
  final int count;
  final Float32List embeddings; // [count * dim]

  RockReference({
    required this.id,
    required this.name,
    required this.lithology,
    required this.minerals,
    required this.description,
    required this.modelVersion,
    required this.dim,
    required this.count,
    required this.embeddings,
  });

  factory RockReference.fromMap(String id, Map<String, dynamic> map) {
    return RockReference(
      id: id,
      name: (map["name"] ?? id) as String,
      lithology: (map["lithology"] ?? "") as String,
      minerals: List<String>.from((map["minerals"] ?? const []) as List),
      description: (map["description"] ?? "") as String,
      modelVersion: (map["modelVersion"] ?? "") as String,
      dim: (map["dim"] as num).toInt(),
      count: (map["count"] as num).toInt(),
      embeddings: decodeF16Base64(map["embeddings"] as String),
    );
  }
}

/// Probabilidade (0 a 1) de a foto ser uma rocha: softmax sobre as frases, somando as frases "de rocha".
double rockProbability(Float32List query, RecognitionConfig cfg) {
  final int n = cfg.promptIsRock.length;
  final logits = List<double>.generate(
      n, (i) => cfg.logitScale * _dot(query, cfg.promptEmbeddings, i * cfg.dim));
  final double maxLogit = logits.reduce(math.max);
  double total = 0, rock = 0;
  for (int i = 0; i < n; i++) {
    final double e = math.exp(logits[i] - maxLogit);
    total += e;
    if (cfg.promptIsRock[i]) rock += e;
  }
  return rock / total;
}

/// Para cada rocha: média das top-k similaridades entre a consulta e as fotos de referência.
Map<String, double> classScores(Float32List query, List<RockReference> rocks, int topK) {
  final scores = <String, double>{};
  for (final rock in rocks) {
    final sims = List<double>.generate(
        rock.count, (j) => _dot(query, rock.embeddings, j * rock.dim));
    sims.sort((a, b) => b.compareTo(a));
    final top = sims.take(topK).toList();
    if (top.isNotEmpty) {
      scores[rock.id] = top.reduce((a, b) => a + b) / top.length;
    }
  }
  return scores;
}

enum RecognitionStatus { match, noMatch, notRock }

class RecognitionResult {
  final RecognitionStatus status;
  final RockReference? rock;
  final double score;
  final double rockProbability;

  RecognitionResult(this.status, this.rock, this.score, this.rockProbability);
}

/// A regra completa (igual a ml/common.py -> decide()).
RecognitionResult decide(
    Float32List query, List<RockReference> rocks, RecognitionConfig cfg) {
  final double rockP = rockProbability(query, cfg);
  if (rockP < cfg.rockThreshold) {
    return RecognitionResult(RecognitionStatus.notRock, null, 0, rockP);
  }
  final scores = classScores(query, rocks, cfg.topK);
  if (scores.isEmpty) {
    return RecognitionResult(RecognitionStatus.noMatch, null, 0, rockP);
  }
  final String bestId =
      scores.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  final double best = scores[bestId]!;
  if (best < cfg.matchThreshold) {
    return RecognitionResult(RecognitionStatus.noMatch, null, best, rockP);
  }
  return RecognitionResult(RecognitionStatus.match,
      rocks.firstWhere((r) => r.id == bestId), best, rockP);
}
