"""Envia o índice de referência (vetores + descrições + limiares) para o Firestore.

Documentos gravados:
  rocks/{rockId}                 nome, descrição, minerais... + embeddings (float16 em base64)
  recognition_config/current     limiares, logitScale, frases do filtro "é rocha?" (vetores)

Pré-requisito (gratuito, plano Spark): chave de conta de serviço
  Console Firebase -> Configurações do projeto -> Contas de serviço -> "Gerar nova chave privada".
  Salve o JSON FORA do repositório e aponte a variável de ambiente:
    $env:GOOGLE_APPLICATION_CREDENTIALS = "C:\\chaves\\aula09-notes-firebase-adminsdk.json"

Uso:
  python upload_firestore.py --dry-run     # só mostra o que seria enviado
  python upload_firestore.py               # envia
  python upload_firestore.py --fixture     # gera test/fixtures/recognition_fixture.json (teste do Dart)
"""
import argparse
import json

import numpy as np

from common import (
    INDEX_PATH,
    ML_DIR,
    MODEL_VERSION,
    NEGATIVE_FOLDER,
    NOT_ROCK_PROMPTS,
    ROCK_PROMPTS,
    ROCKS_PATH,
    decide,
    f16_b64,
    load_config,
    logit_scale,
    prompt_embeddings,
)

FIXTURE_PATH = ML_DIR.parent / "test" / "fixtures" / "recognition_fixture.json"


def build_payload():
    data = np.load(INDEX_PATH)
    emb, labels = data["emb"], data["labels"]
    rocks_info = json.loads(ROCKS_PATH.read_text(encoding="utf-8"))
    cfg = load_config()

    rocks = {}
    for rock_id in sorted(set(labels) - {NEGATIVE_FOLDER}):
        vecs = emb[labels == rock_id]
        info = rocks_info.get(rock_id, {})
        rocks[rock_id] = {
            "name": info.get("name", rock_id),
            "lithology": info.get("lithology", ""),
            "minerals": info.get("minerals", []),
            "description": info.get("description", ""),
            "modelVersion": MODEL_VERSION,
            "dim": int(vecs.shape[1]),
            "count": int(vecs.shape[0]),
            "embeddings": f16_b64(vecs),
        }

    config = {
        "modelVersion": MODEL_VERSION,
        "matchThreshold": cfg["match_threshold"],
        "rockThreshold": cfg["rock_threshold"],
        "topK": cfg["top_k"],
        "logitScale": logit_scale(),
        "dim": int(emb.shape[1]),
        "promptEmbeddings": f16_b64(prompt_embeddings()),
        "promptIsRock": [True] * len(ROCK_PROMPTS) + [False] * len(NOT_ROCK_PROMPTS),
        "prompts": ROCK_PROMPTS + NOT_ROCK_PROMPTS,
    }
    return rocks, config, emb, labels


def write_fixture(rocks, config, emb, labels):
    """Exemplos com a decisão do Python, para o teste do Dart conferir que dá o mesmo resultado.

    Os vetores de referência e de consulta passam por float16 (como no Firestore) antes de decidir.
    """
    def f16(a):
        return np.asarray(a, dtype=np.float16).astype(np.float32)

    pos = labels != NEGATIVE_FOLDER
    ref, ref_labels = f16(emb[pos]), labels[pos]
    cfg = {"match_threshold": config["matchThreshold"], "rock_threshold": config["rockThreshold"],
           "top_k": config["topK"]}

    queries = []
    for idx in [*np.where(labels == NEGATIVE_FOLDER)[0][:4], *np.where(pos)[0][::20]]:
        q = f16(emb[idx])
        queries.append({"embedding": f16_b64(q), "expected": decide(q, ref, ref_labels, cfg)})

    FIXTURE_PATH.parent.mkdir(parents=True, exist_ok=True)
    FIXTURE_PATH.write_text(json.dumps({"config": config, "rocks": rocks, "queries": queries}, indent=1),
                            encoding="utf-8")
    print(f"Fixture com {len(queries)} consultas: {FIXTURE_PATH}")


def upload(rocks, config):
    import firebase_admin
    from firebase_admin import firestore

    firebase_admin.initialize_app()  # usa GOOGLE_APPLICATION_CREDENTIALS
    db = firestore.client()
    batch = db.batch()
    for rock_id, doc in rocks.items():
        batch.set(db.collection("rocks").document(rock_id), {**doc, "updatedAt": firestore.SERVER_TIMESTAMP})
    batch.set(db.collection("recognition_config").document("current"),
              {**config, "updatedAt": firestore.SERVER_TIMESTAMP})
    batch.commit()
    print("Enviado para o Firestore.")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--fixture", action="store_true")
    args = ap.parse_args()

    rocks, config, emb, labels = build_payload()
    for rock_id, doc in rocks.items():
        print(f"rocks/{rock_id}: {doc['count']} fotos, embeddings {len(doc['embeddings']) / 1024:.1f} KB")
    print(f"recognition_config/current: match={config['matchThreshold']} rock={config['rockThreshold']} "
          f"topK={config['topK']} logitScale={config['logitScale']:.2f}")

    if args.fixture:
        write_fixture(rocks, config, emb, labels)
    if not args.dry_run and not args.fixture:
        upload(rocks, config)


if __name__ == "__main__":
    main()
