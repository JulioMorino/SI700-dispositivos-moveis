import 'package:flutter/foundation.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:image/image.dart' as img;

import '../recognition/similarity.dart';

/// Roda o encoder de imagem do CLIP (ONNX int8) DENTRO do celular: foto -> vetor de 512 números.
class EmbeddingService {
  static EmbeddingService helper = EmbeddingService._createInstance();
  EmbeddingService._createInstance();

  /// Precisa ser igual ao MODEL_VERSION de ml/common.py e ao "modelVersion" no Firestore.
  static const String modelVersion = "clip-vitb32-laion2b-int8-v1";
  static const String assetPath = "assets/models/clip_visual_int8.onnx";

  Future<OrtSession>? _session;

  /// Carrega o modelo uma única vez (~90 MB; pode levar alguns segundos na 1ª vez).
  Future<OrtSession> load() {
    return _session ??= OnnxRuntime().createSessionFromAsset(assetPath);
  }

  Future<Float32List> embed(Uint8List imageBytes) async {
    final OrtSession session = await load();
    // O pré-processamento é pesado em Dart puro: roda em outro isolate para não travar a tela.
    final Float32List pixels = await compute(preprocessImage, imageBytes);

    final OrtValue input =
        await OrtValue.fromList(pixels, [1, 3, kImageSize, kImageSize]);
    final outputs = await session.run({session.inputNames.first: input});
    final OrtValue output = outputs[session.outputNames.first]!;
    final List raw = await output.asFlattenedList();

    await input.dispose();
    for (final v in outputs.values) {
      await v.dispose();
    }
    return l2Normalize(raw.map((e) => (e as num).toDouble()).toList());
  }
}

// ---- Pré-processamento: espelho de preprocess_np() em ml/common.py ----
const int kImageSize = 224;
const List<double> kClipMean = [0.48145466, 0.4578275, 0.40821073];
const List<double> kClipStd = [0.26862954, 0.26130258, 0.27577711];

/// JPEG/PNG -> tensor float32 [3, 224, 224] (achatado), pronto para o modelo.
/// 1. corrige a rotação EXIF  2. redimensiona o lado menor para 224 (média de área)
/// 3. corta o centro 224x224  4. normaliza com média/desvio do CLIP
Float32List preprocessImage(Uint8List bytes) {
  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    throw const FormatException("Imagem inválida");
  }
  image = img.bakeOrientation(image);

  final int w = image.width, h = image.height;
  final double scale = kImageSize / (w < h ? w : h);
  final int nw = _atLeast((w * scale).round()), nh = _atLeast((h * scale).round());
  image = img.copyResize(image,
      width: nw, height: nh, interpolation: img.Interpolation.average);
  image = img.copyCrop(image,
      x: (nw - kImageSize) ~/ 2,
      y: (nh - kImageSize) ~/ 2,
      width: kImageSize,
      height: kImageSize);

  const int plane = kImageSize * kImageSize;
  final out = Float32List(3 * plane);
  for (int y = 0; y < kImageSize; y++) {
    for (int x = 0; x < kImageSize; x++) {
      final p = image.getPixel(x, y);
      final int i = y * kImageSize + x;
      out[i] = (p.r / 255.0 - kClipMean[0]) / kClipStd[0];
      out[plane + i] = (p.g / 255.0 - kClipMean[1]) / kClipStd[1];
      out[2 * plane + i] = (p.b / 255.0 - kClipMean[2]) / kClipStd[2];
    }
  }
  return out;
}

int _atLeast(int v) => v < kImageSize ? kImageSize : v;
