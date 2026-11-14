// Gera os tensores do pré-processamento em DART para algumas fotos do dataset.
// Depois, ml/check_preprocess_parity.py compara com o pré-processamento do Python
// (pixel a pixel e no vetor final do modelo).
// Se o dataset não existir (ex.: em outro PC), o teste é pulado.
import 'dart:io';
import 'dart:typed_data';

import 'package:aula11/provider/embedding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final dataset = Directory('ml/dataset');

  test('gera tensores do pré-processamento Dart', () {
    final outDir = Directory('build/preprocess_dart')..createSync(recursive: true);
    final files = dataset
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => RegExp(r'\.(jpe?g|png)$', caseSensitive: false).hasMatch(f.path))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    // uma a cada 6 fotos, para o teste ser rápido
    for (int i = 0; i < files.length; i += 6) {
      final Float32List t = preprocessImage(files[i].readAsBytesSync());
      expect(t.length, 3 * 224 * 224);
      final name = files[i].uri.pathSegments.last;
      File('${outDir.path}/$name.f32').writeAsBytesSync(t.buffer.asUint8List());
    }
  }, skip: dataset.existsSync() ? false : 'ml/dataset ausente');
}
