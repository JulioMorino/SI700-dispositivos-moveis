"""Gera index.npz: um vetor CLIP por foto do dataset (positivas e negativas).

Rode de novo sempre que adicionar ou remover fotos:  python build_index.py
"""
import numpy as np

from common import INDEX_PATH, embed_images, list_dataset, open_image


def main():
    items = list_dataset()
    print(f"Gerando vetores de {len(items)} fotos (a 1ª execução baixa o modelo, ~600 MB)...")
    emb = embed_images([open_image(path) for _, path in items])
    np.savez(
        INDEX_PATH,
        emb=emb,
        labels=np.array([cls for cls, _ in items]),
        files=np.array([path.name for _, path in items]),
    )
    counts = {}
    for cls, _ in items:
        counts[cls] = counts.get(cls, 0) + 1
    for cls, n in counts.items():
        print(f"  {cls}: {n}")
    print(f"Salvo em {INDEX_PATH}")


if __name__ == "__main__":
    main()
