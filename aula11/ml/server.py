"""Servidor de reconhecimento.

Uso (na pasta ml/, com o venv ativo):
    uvicorn server:app --host 0.0.0.0 --port 8000

POST /recognize  (multipart, campo "image")
  {"status": "match", "id", "name", "description", "lithology", "minerals", "score"}
  {"status": "no_match", "score"}   -> rocha, mas nenhum exemplar parecido o suficiente
  {"status": "not_rock", "rock_probability"}
"""
import json

import numpy as np
from fastapi import FastAPI, File, HTTPException, UploadFile

from common import (
    INDEX_PATH,
    NEGATIVE_FOLDER,
    ROCKS_PATH,
    decide,
    embed_images,
    load_config,
    load_model,
    open_image,
)

app = FastAPI(title="Reconhecimento de Afloramentos")

load_model()
_data = np.load(INDEX_PATH)
_pos = _data["labels"] != NEGATIVE_FOLDER
EMB, LABELS = _data["emb"][_pos], _data["labels"][_pos]
ROCKS = json.loads(ROCKS_PATH.read_text(encoding="utf-8"))
CFG = load_config()
print(f"Índice: {len(LABELS)} fotos de referência | config: {CFG}")


@app.get("/health")
def health():
    return {"ok": True, "references": int(len(LABELS)), "config": CFG}


@app.post("/recognize")
async def recognize(image: UploadFile = File(...)):
    try:
        img = open_image(await image.read())
    except Exception:
        raise HTTPException(status_code=400, detail="Imagem inválida")

    result = decide(embed_images([img])[0], EMB, LABELS, CFG)
    print(result)
    if result["status"] == "match":
        result.update(ROCKS.get(result["id"], {"name": result["id"], "description": ""}))
    return result
