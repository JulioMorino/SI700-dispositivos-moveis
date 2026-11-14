"""Código compartilhado: modelo CLIP, geração de vetores (embeddings) e filtro "é rocha?"."""
import io
import json
from pathlib import Path

import numpy as np
import open_clip
import torch
from PIL import Image, ImageOps

ML_DIR = Path(__file__).resolve().parent
DATASET_DIR = ML_DIR / "dataset"
INDEX_PATH = ML_DIR / "index.npz"
CONFIG_PATH = ML_DIR / "config.json"
ROCKS_PATH = ML_DIR / "rocks.json"

NEGATIVE_FOLDER = "_negativos"
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp"}

MODEL_NAME = "ViT-B-32"
PRETRAINED = "laion2b_s34b_b79k"

# Modelo exportado para rodar no celular (ver export_onnx.py).
EXPORT_DIR = ML_DIR / "export"
ONNX_INT8_PATH = EXPORT_DIR / "clip_visual_int8.onnx"
APP_MODEL_PATH = ML_DIR.parent / "assets" / "models" / "clip_visual_int8.onnx"
# Muda sempre que o modelo exportado mudar: o app recusa um índice de outra versão.
MODEL_VERSION = "clip-vitb32-laion2b-int8-v1"

# Pré-processamento PRÓPRIO (o mesmo é reimplementado em Dart no app):
#   1. corrige rotação EXIF  2. redimensiona o lado menor para 224 com média de área (BOX)
#   3. corta o centro 224x224  4. divide por 255 e normaliza com média/desvio do CLIP
IMAGE_SIZE = 224
CLIP_MEAN = (0.48145466, 0.4578275, 0.40821073)
CLIP_STD = (0.26862954, 0.26130258, 0.27577711)

# Frases para o filtro "isto é uma rocha?". O CLIP compara a foto com cada uma.
ROCK_PROMPTS = [
    "a photo of a rock",
    "a photo of a rock outcrop",
    "a close-up photo of a stone surface",
    "a photo of a boulder",
    "a photo of petrified wood",
    "a photo of a mineral specimen",
]
NOT_ROCK_PROMPTS = [
    "a photo of a person",
    "a selfie",
    "a photo of a face",
    "a photo of a building",
    "a photo of an animal",
    "a photo of a car",
    "a photo of the sky",
    "a photo of a tree",
    "a photo of a computer screen",
    "a photo of furniture indoors",
    "a photo of a document with text",
    "a photo of food",
]

# Valores padrão; o evaluate.py grava valores calibrados no config.json.
DEFAULT_CONFIG = {"match_threshold": 0.80, "rock_threshold": 0.50, "top_k": 3}

_model = None
_preprocess = None
_tokenizer = None
_text_feats = None


def load_model():
    global _model, _preprocess, _tokenizer
    if _model is None:
        _model, _, _preprocess = open_clip.create_model_and_transforms(
            MODEL_NAME, pretrained=PRETRAINED
        )
        _model.eval()
        _tokenizer = open_clip.get_tokenizer(MODEL_NAME)
    return _model, _preprocess, _tokenizer


def open_image(source) -> Image.Image:
    """Abre um caminho ou bytes, corrigindo a rotação EXIF (comum em fotos de celular)."""
    img = Image.open(io.BytesIO(source) if isinstance(source, (bytes, bytearray)) else source)
    return ImageOps.exif_transpose(img).convert("RGB")


def preprocess_np(img: Image.Image) -> np.ndarray:
    """Imagem RGB -> array float32 [3, 224, 224]. Espelhado em lib/provider/embedding_service.dart."""
    w, h = img.size
    scale = IMAGE_SIZE / min(w, h)
    nw, nh = max(IMAGE_SIZE, round(w * scale)), max(IMAGE_SIZE, round(h * scale))
    img = img.resize((nw, nh), Image.BOX)
    left, top = (nw - IMAGE_SIZE) // 2, (nh - IMAGE_SIZE) // 2
    img = img.crop((left, top, left + IMAGE_SIZE, top + IMAGE_SIZE))
    x = np.asarray(img, dtype=np.float32) / 255.0  # [224, 224, 3]
    x = (x - np.array(CLIP_MEAN, dtype=np.float32)) / np.array(CLIP_STD, dtype=np.float32)
    return x.transpose(2, 0, 1).copy()  # canais primeiro (NCHW sem o N)


@torch.no_grad()
def _embed_torch(batch: np.ndarray) -> np.ndarray:
    model, _, _ = load_model()
    feats = model.encode_image(torch.from_numpy(batch))
    return (feats / feats.norm(dim=-1, keepdim=True)).cpu().numpy()


_ort_sessions = {}


def _embed_onnx(batch: np.ndarray, path=ONNX_INT8_PATH) -> np.ndarray:
    import onnxruntime as ort

    key = str(path)
    if key not in _ort_sessions:
        _ort_sessions[key] = ort.InferenceSession(key, providers=["CPUExecutionProvider"])
    sess = _ort_sessions[key]
    out = sess.run(None, {sess.get_inputs()[0].name: batch})[0]
    return out / np.linalg.norm(out, axis=1, keepdims=True)


def embed_images(images, backend="onnx", batch_size=16, onnx_path=ONNX_INT8_PATH) -> np.ndarray:
    """Lista de imagens PIL -> vetores [N, 512] normalizados (norma 1).

    backend="onnx"  -> o mesmo modelo int8 que roda no celular (padrão: índice e app ficam coerentes)
    backend="torch" -> modelo original em PyTorch (referência)
    """
    out = []
    for i in range(0, len(images), batch_size):
        batch = np.stack([preprocess_np(im) for im in images[i : i + batch_size]])
        if backend == "torch":
            out.append(_embed_torch(batch))
        else:
            for j in range(len(batch)):  # o modelo exportado recebe 1 imagem por vez, como no app
                out.append(_embed_onnx(batch[j : j + 1], onnx_path))
    return np.concatenate(out).astype(np.float32)


def prompt_embeddings() -> np.ndarray:
    """Vetores de texto das frases do filtro "é rocha?" (pré-calculados e enviados ao app)."""
    return _prompt_feats().astype(np.float32)


def logit_scale() -> float:
    model, _, _ = load_model()
    return float(model.logit_scale.exp().item())


@torch.no_grad()
def _prompt_feats():
    global _text_feats
    if _text_feats is None:
        model, _, tokenizer = load_model()
        feats = model.encode_text(tokenizer(ROCK_PROMPTS + NOT_ROCK_PROMPTS))
        _text_feats = (feats / feats.norm(dim=-1, keepdim=True)).cpu().numpy()
    return _text_feats


def rock_probability(img_emb: np.ndarray) -> np.ndarray:
    """Probabilidade (0 a 1) de cada imagem ser uma rocha, segundo as frases acima."""
    model, _, _ = load_model()
    logits = model.logit_scale.exp().item() * img_emb @ _prompt_feats().T
    logits -= logits.max(axis=1, keepdims=True)
    probs = np.exp(logits)
    probs /= probs.sum(axis=1, keepdims=True)
    return probs[:, : len(ROCK_PROMPTS)].sum(axis=1)


def class_scores(query: np.ndarray, emb: np.ndarray, labels: np.ndarray, top_k: int, mask=None):
    """Para cada classe: média das top_k similaridades de cosseno entre a consulta e as fotos da classe.

    `mask` (bool, mesmo tamanho de emb) permite ignorar fotos (usado na avaliação).
    """
    sims = emb @ query
    scores = {}
    for cls in np.unique(labels):
        sel = labels == cls
        if mask is not None:
            sel &= mask
        s = np.sort(sims[sel])[::-1][:top_k]
        if len(s):
            scores[str(cls)] = float(s.mean())
    return scores


def decide(query: np.ndarray, emb: np.ndarray, labels: np.ndarray, cfg: dict) -> dict:
    """Regra de decisão completa (a MESMA implementada em lib/recognition/similarity.dart).

    1. filtro "é rocha?"  -> not_rock
    2. k-NN por classe    -> match (se score >= limiar) ou no_match
    """
    rock_p = float(rock_probability(query[None, :])[0])
    if rock_p < cfg["rock_threshold"]:
        return {"status": "not_rock", "rock_probability": round(rock_p, 4)}
    scores = class_scores(query, emb, labels, cfg["top_k"])
    best = max(scores, key=scores.get)
    if scores[best] < cfg["match_threshold"]:
        return {"status": "no_match", "score": round(scores[best], 4)}
    return {"status": "match", "id": best, "score": round(scores[best], 4)}


def f16_b64(arr: np.ndarray) -> str:
    """float32 -> float16 little-endian -> base64 (formato compacto usado no Firestore)."""
    import base64

    return base64.b64encode(np.ascontiguousarray(arr, dtype="<f2").tobytes()).decode("ascii")


def list_dataset():
    """Retorna [(classe, caminho)], com classe == NEGATIVE_FOLDER para as negativas, em ordem de nome."""
    items = []
    for folder in sorted(p for p in DATASET_DIR.iterdir() if p.is_dir()):
        for f in sorted(folder.iterdir()):
            if f.suffix.lower() in IMAGE_EXTS:
                items.append((folder.name, f))
    return items


def load_config():
    if CONFIG_PATH.exists():
        return {**DEFAULT_CONFIG, **json.loads(CONFIG_PATH.read_text(encoding="utf-8"))}
    return dict(DEFAULT_CONFIG)
