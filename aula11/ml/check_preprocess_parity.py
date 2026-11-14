"""Compara o pré-processamento do Dart (app) com o do Python.

Antes rode, na pasta aula11/:  flutter test test/preprocess_parity_test.dart
Depois, nesta pasta:           python check_preprocess_parity.py
"""
import numpy as np

from common import ML_DIR, _embed_onnx, list_dataset, open_image, preprocess_np

DART_DIR = ML_DIR.parent / "build" / "preprocess_dart"


def main():
    by_name = {p.name: p for _, p in list_dataset()}
    diffs, coss = [], []
    for f in sorted(DART_DIR.glob("*.f32")):
        dart = np.fromfile(f, dtype="<f4").reshape(3, 224, 224)
        py = preprocess_np(open_image(by_name[f.stem]))
        diffs.append(np.abs(dart - py).mean())
        e_dart = _embed_onnx(dart[None])[0]
        e_py = _embed_onnx(py[None])[0]
        coss.append(float(e_dart @ e_py))
        print(f"  {f.stem:34s} dif. média pixel {diffs[-1]:.4f}   cosseno dos vetores {coss[-1]:.4f}")
    print(f"\n{len(coss)} fotos | dif. média pixel {np.mean(diffs):.4f} | "
          f"cosseno médio {np.mean(coss):.4f} (mínimo {np.min(coss):.4f})")


if __name__ == "__main__":
    main()
