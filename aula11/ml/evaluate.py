"""Avalia o reconhecimento com as fotos do dataset e calibra os limiares (grava config.json).

Duas avaliações para as fotos positivas:
  - leave-one-out: cada foto é comparada com todas as outras (otimista: rajadas quase iguais).
  - em blocos: a foto é comparada sem o seu bloco de 5 fotos consecutivas (mais realista).
As negativas são comparadas com todas as positivas e devem ser rejeitadas.

Uso:  python evaluate.py
"""
import json

import numpy as np

from common import (
    CONFIG_PATH,
    DEFAULT_CONFIG,
    INDEX_PATH,
    NEGATIVE_FOLDER,
    class_scores,
    rock_probability,
)

BLOCK = 5


def main():
    data = np.load(INDEX_PATH)
    emb, labels, files = data["emb"], data["labels"], data["files"]
    top_k = DEFAULT_CONFIG["top_k"]

    pos = labels != NEGATIVE_FOLDER
    rock_p = rock_probability(emb)

    # posição de cada foto dentro da sua classe -> bloco
    block = np.zeros(len(labels), dtype=int)
    for cls in np.unique(labels):
        idx = np.where(labels == cls)[0]
        block[idx] = np.arange(len(idx)) // BLOCK

    results = []  # (arquivo, classe real, prevista, score, rock_p, modo)
    for i in range(len(labels)):
        if pos[i]:
            for mode in ("loo", "bloco"):
                mask = pos.copy()
                if mode == "loo":
                    mask[i] = False
                else:
                    mask &= ~((labels == labels[i]) & (block == block[i]))
                sc = class_scores(emb[i], emb, labels, top_k, mask)
                pred = max(sc, key=sc.get)
                results.append((files[i], labels[i], pred, sc[pred], rock_p[i], mode))
        else:
            sc = class_scores(emb[i], emb, labels, top_k, pos)
            pred = max(sc, key=sc.get)
            results.append((files[i], labels[i], pred, sc[pred], rock_p[i], "neg"))

    def subset(mode):
        return [r for r in results if r[5] == mode]

    print("=== Classificação entre as rochas (sem limiar) ===")
    for mode in ("loo", "bloco"):
        rs = subset(mode)
        acc = np.mean([r[1] == r[2] for r in rs])
        print(f"  {mode:5s}: {acc * 100:5.1f}% de acerto ({len(rs)} fotos)")

    blo, neg = subset("bloco"), subset("neg")
    s_pos = np.array([r[3] for r in blo])
    s_neg = np.array([r[3] for r in neg])
    r_pos = np.array([r[4] for r in blo])
    r_neg = np.array([r[4] for r in neg])

    print("\n=== Similaridade com a rocha mais parecida ===")
    print(f"  positivas (bloco): min {s_pos.min():.3f}  média {s_pos.mean():.3f}  max {s_pos.max():.3f}")
    print(f"  negativas        : min {s_neg.min():.3f}  média {s_neg.mean():.3f}  max {s_neg.max():.3f}")
    print("\n=== Probabilidade de 'é rocha' (filtro por texto) ===")
    print(f"  positivas: min {r_pos.min():.3f}  média {r_pos.mean():.3f}")
    print(f"  negativas: min {r_neg.min():.3f}  média {r_neg.mean():.3f}  max {r_neg.max():.3f}")

    # Busca dos limiares que maximizam a acurácia balanceada (positivas aceitas com a classe
    # certa + negativas rejeitadas), usando a avaliação em blocos.
    correct = np.array([r[1] == r[2] for r in blo])
    best, cands = -1.0, []
    for rt in np.round(np.arange(0.05, 0.96, 0.05), 2):
        for mt in np.round(np.arange(0.50, 0.99, 0.005), 3):
            tp = np.mean(correct & (r_pos >= rt) & (s_pos >= mt))
            tn = np.mean(~((r_neg >= rt) & (s_neg >= mt)))
            bal = (tp + tn) / 2
            if bal > best + 1e-9:
                best, cands = bal, [(rt, mt)]
            elif abs(bal - best) <= 1e-9:
                cands.append((rt, mt))
    # entre os empates, pega o "meio" da região (mais margem para fotos novas)
    rock_t = float(np.median([c[0] for c in cands]))
    match_t = float(np.median([c[1] for c in cands]))

    accepted = (r_pos >= rock_t) & (s_pos >= match_t)
    neg_acc = (r_neg >= rock_t) & (s_neg >= match_t)
    print("\n=== Limiares calibrados ===")
    print(f"  rock_threshold  = {rock_t:.2f}")
    print(f"  match_threshold = {match_t:.3f}")
    print(f"  positivas reconhecidas corretamente: {np.mean(accepted & correct) * 100:.1f}%")
    print(f"  negativas rejeitadas:                {np.mean(~neg_acc) * 100:.1f}%")

    erros = [r for r, a, c in zip(blo, accepted, correct) if not (a and c)]
    erros += [r for r, a in zip(neg, neg_acc) if a]
    if erros:
        print("\n=== Erros (avaliação em blocos) ===")
        for f, real, pred, s, rp, mode in erros:
            print(f"  {f:34s} real={real:24s} previsto={pred:24s} sim={s:.3f} rocha={rp:.2f}")

    cfg = {"match_threshold": round(match_t, 3), "rock_threshold": round(rock_t, 2), "top_k": top_k}
    CONFIG_PATH.write_text(json.dumps(cfg, indent=2), encoding="utf-8")
    print(f"\nConfig salva em {CONFIG_PATH}: {cfg}")


if __name__ == "__main__":
    main()
