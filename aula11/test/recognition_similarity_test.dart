// Confere que a lógica em Dart (lib/recognition/similarity.dart) decide IGUAL ao Python.
// O fixture é gerado por: ml/ -> python upload_firestore.py --fixture
import 'dart:convert';
import 'dart:io';

import 'package:aula11/recognition/similarity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final file = File('test/fixtures/recognition_fixture.json');

  test('decodeF16Base64 converte float16 corretamente', () {
    // 1.0 = 0x3C00, -2.0 = 0xC000, 0.5 = 0x3800 (little-endian)
    final b64 = base64Encode([0x00, 0x3C, 0x00, 0xC0, 0x00, 0x38]);
    expect(decodeF16Base64(b64), [1.0, -2.0, 0.5]);
  });

  test('decisão em Dart == decisão em Python', () {
    final data = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final cfg = RecognitionConfig.fromMap(Map<String, dynamic>.from(data['config']));
    final rocks = (data['rocks'] as Map<String, dynamic>)
        .entries
        .map((e) => RockReference.fromMap(e.key, Map<String, dynamic>.from(e.value)))
        .toList();

    for (final q in data['queries'] as List) {
      final query = decodeF16Base64(q['embedding'] as String);
      final expected = q['expected'] as Map<String, dynamic>;
      final result = decide(query, rocks, cfg);

      const names = {
        RecognitionStatus.match: 'match',
        RecognitionStatus.noMatch: 'no_match',
        RecognitionStatus.notRock: 'not_rock',
      };
      expect(names[result.status], expected['status']);
      if (expected['status'] == 'match') {
        expect(result.rock!.id, expected['id']);
      }
      if (expected.containsKey('score')) {
        expect(result.score, closeTo((expected['score'] as num).toDouble(), 1e-3));
      }
    }
  }, skip: file.existsSync() ? false : 'fixture ausente: rode upload_firestore.py --fixture');
}
