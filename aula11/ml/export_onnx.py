"""Exporta o encoder de IMAGEM do CLIP para ONNX, quantiza para int8 e confere se o resultado é fiel.

Saídas:
  ml/export/clip_visual_fp32.onnx   (~350 MB, só para comparação)
  ml/export/clip_visual_int8.onnx   (~90 MB, o que vai para o app)
  ml/export/model_meta.json         (versão, constantes de pré-processamento, logit_scale)
  assets/models/clip_visual_int8.onnx  (cópia usada pelo Flutter)

Uso:  python export_onnx.py
"""
import json
import shutil

import numpy as np
import torch
from onnxruntime.quantization import QuantType, quantize_dynamic

from common import (
    APP_MODEL_PATH,
    CLIP_MEAN,
    CLIP_STD,
    EXPORT_DIR,
    IMAGE_SIZE,
    MODEL_NAME,
    MODEL_VERSION,
    ONNX_INT8_PATH,
    PRETRAINED,
    embed_images,
    list_dataset,
    load_model,
    logit_scale,
    open_image,
)

FP32_PATH = EXPORT_DIR / "clip_visual_fp32.onnx"


class VisualEncoder(torch.nn.Module):
    """Só a parte de imagem do CLIP: [1, 3, 224, 224] -> [1, 512]."""

    def __init__(self, clip_model):
        super().__init__()
        self.visual = clip_model.visual

    def forward(self, pixel_values):
        return self.visual(pixel_values)


def export_fp32():
    model, _, _ = load_model()
    enc = VisualEncoder(model).eval()
    dummy = torch.randn(1, 3, IMAGE_SIZE, IMAGE_SIZE)
    EXPORT_DIR.mkdir(exist_ok=True)
    torch.onnx.export(
        enc,
        (dummy,),
        str(FP32_PATH),
        input_names=["pixel_values"],
        output_names=["embedding"],
        opset_version=17,
        dynamo=False,  # exportador clássico: grafo simples, compatível com o onnxruntime mobile
    )
    print(f"FP32 exportado: {FP32_PATH} ({FP32_PATH.stat().st_size / 1e6:.0f} MB)")


def quantize():
    # Quantização dinâmica: os pesos das camadas lineares viram int8 (4x menor).
    # As ativações continuam float e são quantizadas "na hora" durante a execução.
    quantize_dynamic(str(FP32_PATH), str(ONNX_INT8_PATH), weight_type=QuantType.QInt8)
    print(f"INT8 quantizado: {ONNX_INT8_PATH} ({ONNX_INT8_PATH.stat().st_size / 1e6:.0f} MB)")


def parity():
    """Compara os vetores PyTorch vs. ONNX fp32 vs. ONNX int8 em todas as fotos do dataset."""
    imgs = [open_image(p) for _, p in list_dataset()]
    ref = embed_images(imgs, backend="torch")
    fp32 = embed_images(imgs, backend="onnx", onnx_path=FP32_PATH)
    int8 = embed_images(imgs, backend="onnx", onnx_path=ONNX_INT8_PATH)
    for name, e in (("ONNX fp32", fp32), ("ONNX int8", int8)):
        cos = np.sum(ref * e, axis=1)
        print(f"  {name} vs PyTorch: cosseno médio {cos.mean():.4f}  mínimo {cos.min():.4f}")
    return float(np.sum(ref * int8, axis=1).mean())


def main():
    export_fp32()
    quantize()
    print("Conferindo fidelidade em todas as fotos do dataset...")
    mean_cos = parity()

    meta = {
        "modelVersion": MODEL_VERSION,
        "model": MODEL_NAME,
        "pretrained": PRETRAINED,
        "imageSize": IMAGE_SIZE,
        "mean": CLIP_MEAN,
        "std": CLIP_STD,
        "resize": "lado menor -> 224 por média de área (BOX), depois corte central 224x224",
        "input": "pixel_values float32 [1,3,224,224]",
        "output": "embedding float32 [1,512] (normalizar L2)",
        "logitScale": logit_scale(),
        "parityCosineInt8": round(mean_cos, 4),
        "torch": torch.__version__,
    }
    (EXPORT_DIR / "model_meta.json").write_text(json.dumps(meta, indent=2), encoding="utf-8")

    APP_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(ONNX_INT8_PATH, APP_MODEL_PATH)
    print(f"Copiado para o app: {APP_MODEL_PATH}")


if __name__ == "__main__":
    main()
