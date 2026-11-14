# Relatório técnico: Reconhecimento de afloramentos rochosos por imagem

> Versão do pipeline: `clip-vitb32-laion2b-int8-v1` · Data: 2026-11-14
> Escrito para quem conhece modelos clássicos (Random Forest, MLP, Naive Bayes, regressões) e está começando em
> visão computacional.

---

## 1. O problema

**Objetivo:** dada uma foto tirada no campus da Unicamp, dizer **qual afloramento específico** ela mostra e exibir
o nome e a constituição dele (litologia, minerais, descrição).

Existem duas formulações possíveis:

| | Classificação de litologia | **Identificação de instância (escolhida)** |
|---|---|---|
| Pergunta | "Isto é granito, gnaisse, basalto…?" | "Este é o afloramento X do cadastro?" |
| Dificuldade | Alta: intemperismo, líquen e iluminação mudam a aparência, e geólogos usam outros testes além da foto | Menor: o universo é finito e conhecido |
| De onde vem a informação geológica | Do modelo (pode errar) | De um **cadastro curado** por especialistas |
| Rocha nova | Exige retreinar | Basta fotografar e cadastrar |

O modelo só precisa reconhecer **qual** exemplar é. A descrição geológica vem do cadastro.

---

## 2. O pipeline, passo a passo

```
 Foto (câmera, ≤800 px, JPEG q60)
   │
   ▼  [1] Pré-processamento
 corrige rotação EXIF → lado menor = 224 px (média de área) → corte central 224×224
 → pixels/255 → normaliza por canal: (x − média_CLIP) / desvio_CLIP
   │
   ▼  [2] Extrator de características (encoder de imagem do CLIP ViT-B/32)
 tensor [1, 3, 224, 224] ──► vetor de 512 números ("embedding") ──► normaliza para norma 1
   │
   ├──► [3] Filtro "é rocha?" (zero-shot por texto)
   │     compara o vetor com 18 frases ("a photo of a rock", "a photo of a person", …)
   │     P(rocha) < 0,30 ──► "Não parece uma rocha"
   │
   ▼  [4] Classificador k-NN por similaridade de cosseno
 para cada rocha cadastrada: média das 3 maiores similaridades com as fotos de referência dela
   │
   ▼  [5] Limiar de aceitação (open-set)
 melhor score ≥ 0,765 ──► "É o Gnaisse com Granada e Cianita" + descrição
 melhor score < 0,765 ──► "Não foi possível encontrar registros"
```

### 2.1 O que é um "embedding" (vetor de características)?
Pense numa tabela que você daria para um Random Forest: cada linha é uma amostra, e cada coluna é uma
característica (feature) escolhida à mão, como "comprimento da pétala". Aqui, uma rede neural já treinada
**transforma cada foto numa linha com 512 colunas**. Ninguém escolheu essas colunas à mão: elas foram aprendidas e
capturam textura, cor, padrões e formas. Fotos parecidas viram vetores próximos.

### 2.2 Similaridade de cosseno
Com os vetores normalizados (norma 1), a similaridade de cosseno é só o produto escalar:
`sim(a, b) = Σ aᵢ·bᵢ`, que vai de −1 a 1. Valores perto de 1 significam "muito parecidos".

### 2.3 O classificador: k-NN (k vizinhos mais próximos)
- Para cada rocha, calculamos a similaridade da foto nova com **todas** as fotos de referência dela e tiramos a
  **média das 3 maiores** (top-k, com k = 3). A rocha com a maior média vence.
- Usar a média das 3 maiores, e não só a maior, reduz a chance de uma única foto de referência estranha decidir sozinha.

### 2.4 Por que precisamos de um limiar? (reconhecimento em conjunto aberto)
Um classificador comum (RF, MLP, Naive Bayes) **sempre** escolhe uma das classes que conhece. Se a pessoa fotografar
um cachorro, ele responderia "tronco" ou "gnaisse". Isso é o problema de *open-set recognition* (Scheirer et al.,
2013). A solução simples adotada:
- **Filtro semântico**: o próprio CLIP compara a imagem com frases de texto e estima se é rocha (classificação
  *zero-shot*, Radford et al., 2021). A probabilidade vem de um softmax com temperatura (`logitScale` = 100) sobre
  as 18 frases. P(rocha) é a soma das probabilidades das 6 frases "de rocha".
- **Limiar de similaridade**: se nem a rocha mais parecida passa de 0,765, a resposta é "não encontrado".

---

## 3. Relação com os modelos que você já conhece

| Conceito clássico | Aqui |
|---|---|
| Engenharia de features (escolher colunas) | O encoder do CLIP gera 512 features automaticamente |
| Treinar RF / MLP / Naive Bayes | **Não treinamos nada.** O k-NN é "preguiçoso": só guarda os exemplos e compara |
| `model.fit(X, y)` | Equivale a guardar os vetores das fotos de referência (`build_index.py`) |
| `model.predict(x)` | Comparar com os vizinhos mais próximos e aplicar o limiar |
| Hiperparâmetros (n_estimators, camadas…) | k = 3, limiares 0,765 e 0,30, tamanho 224 px |

**Por que não houve treino?** Usamos *transfer learning* com o modelo congelado: as features de uma rede treinada em
um conjunto enorme e genérico já funcionam muito bem com um classificador simples por cima. Razavian et al. (2014)
mostraram isso para CNNs. Com só 2 rochas e cerca de 40 fotos cada, treinar uma rede do zero levaria a overfitting.

**Daria para usar RF/MLP no lugar do k-NN?** Sim, treinando-os com os vetores de 512 dimensões. É um bom experimento
para o paper (seção 9). As desvantagens no nosso caso:
1. Toda rocha nova exigiria retreinar.
2. Seria preciso um mecanismo extra de rejeição (open-set).

---

## 4. O modelo pré-treinado

| Item | Valor |
|---|---|
| Arquitetura | CLIP com encoder de imagem **ViT-B/32** (Vision Transformer, Dosovitskiy et al., 2021) |
| Como o ViT-B/32 vê a imagem | Divide os 224×224 em 7×7 = 49 "pedaços" de 32×32 px, que passam por 12 camadas Transformer (largura 768) |
| Saída | Vetor de 512 dimensões |
| Implementação | OpenCLIP (Cherti et al., 2023), via pacote `open_clip_torch` |
| Pesos | `laion2b_s34b_b79k`: treinado no LAION-2B (subconjunto em inglês do LAION-5B, Schuhmann et al., 2022), com 34 bilhões de amostras vistas e batch de ~79 mil |
| Como o CLIP aprendeu | Aprendizado contrastivo imagem-texto: aproximar o vetor da imagem do vetor da legenda correta (Radford et al., 2021) |
| Framework | PyTorch (Paszke et al., 2019) |

---

## 5. Dados

| Pasta | Fotos | Conteúdo |
|---|---|---|
| `dataset/gnaisse_granada_cianita/` | 40 | Gnaisse com granada e cianita |
| `dataset/tronco_silicificado/` | 39 | Tronco silicificado |
| `dataset/_negativos/` | 31 | Fotos que **não** são esses exemplares (29 fotos e 2 capturas de tela) |

- Todas foram coletadas em **uma única sessão** e enviadas pelo WhatsApp, que recomprime as imagens.
- Os nomes originais estão em `dataset/renomeacao.csv`.
- As fotos de cada rocha foram tiradas em sequência (rajadas), então há fotos **quase idênticas**. Isso influencia a
  forma de avaliar (seção 7).

---

## 6. Hiperparâmetros e configuração

| Hiperparâmetro | Valor | Onde está |
|---|---|---|
| Tamanho de entrada | 224×224 | `common.py` (`IMAGE_SIZE`) |
| Redimensionamento | Lado menor → 224 por média de área (BOX) + corte central | `common.py` / `embedding_service.dart` |
| Média / desvio (RGB) | (0,4815; 0,4578; 0,4082) / (0,2686; 0,2613; 0,2758) | Constantes do CLIP |
| k (top-k) | 3 | `config.json` |
| Limiar de similaridade (`match_threshold`) | **0,765** (calibrado) | `config.json` |
| Limiar do filtro é-rocha (`rock_threshold`) | **0,30** (calibrado) | `config.json` |
| Temperatura do softmax (`logitScale`) | 100,0 | Valor aprendido do próprio CLIP |
| Frases do filtro | 6 "de rocha" e 12 "de não-rocha" | `common.py` (`ROCK_PROMPTS`, `NOT_ROCK_PROMPTS`) |
| Bloco da validação | 5 fotos consecutivas | `evaluate.py` (`BLOCK`) |
| Grade do `rock_threshold` | 0,05 a 0,95, passo 0,05 | `evaluate.py` |
| Grade do `match_threshold` | 0,50 a 0,99, passo 0,005 | `evaluate.py` |
| Critério de calibração | Acurácia balanceada (Brodersen et al., 2010) | `evaluate.py` |
| Compressão no app | Máx. 800 px, JPEG qualidade 60 | `recognize_screen.dart` |
| Quantização | Dinâmica, pesos int8 por tensor (`QuantType.QInt8`) | `export_onnx.py` |

**Versões de software:**
- Python 3.13.14
- torch 2.15.0+cpu, open_clip_torch 4.2.2
- onnx 1.23.2, onnxruntime 1.32.0, firebase-admin 7.8.0
- Flutter 3.32.1 / Dart 3.8.1
- flutter_onnxruntime 1.9.0 (ONNX Runtime nativo 1.28.0), image 4.13.1

---

## 7. Protocolo de avaliação

### 7.1 Por que não há um "train/test split" clássico?
Num RF você separa, por exemplo, 80% para treino e 20% para teste, porque o modelo **aprende parâmetros** no treino.
Aqui o extrator está congelado e o k-NN não aprende parâmetros. Só 2 números são ajustados: os limiares. Por isso
usamos validação cruzada, que aproveita todas as fotos (Stone, 1974):

1. **Leave-one-out (LOO)**: cada foto vira "teste" e é comparada com todas as outras. É o caso extremo da validação
   cruzada (k-fold com k = N).
2. **Validação em blocos**: cada foto é comparada **sem o seu bloco de 5 fotos consecutivas**.
   - No LOO, uma foto quase sempre encontra uma "irmã" quase idêntica da mesma rajada, e o resultado fica otimista.
   - Retirar o bloco inteiro simula fotos menos parecidas. Esse cuidado com dados dependentes é discutido em
     Roberts et al. (2017).
3. **Negativas**: comparadas com todas as fotos de referência. Todas devem ser rejeitadas.

### 7.2 Calibração dos limiares
Busca em grade: para cada par (`rock_threshold`, `match_threshold`), calcula-se a **acurácia balanceada**, que é a
média entre:
- a taxa de positivas aceitas com a classe certa;
- a taxa de negativas rejeitadas.

Entre os pares empatados no máximo, escolhe-se a **mediana** da região, para deixar margem para fotos novas.

> ⚠️ **Viés otimista:** os limiares foram calibrados nas **mesmas** fotos usadas para avaliar. Num paper, o correto
> é calibrar num conjunto de validação e reportar num conjunto de **teste independente** (outro dia, outro celular,
> outra iluminação). Veja a seção 9.

---

## 8. Resultados

### 8.1 Modelo original (PyTorch, fp32)
| Métrica | Valor |
|---|---|
| Acerto entre as rochas, LOO | 100% (79/79) |
| Acerto entre as rochas, blocos | 100% (79/79) |
| Similaridade das positivas (blocos) | mín. 0,873 · média 0,925 · máx. 0,969 |
| Similaridade das negativas | mín. 0,299 · média 0,562 · máx. 0,694 |
| P(rocha) das positivas | mín. 0,285 · média 0,981 |
| P(rocha) das negativas | mín. 0,001 · média 0,278 · máx. 0,850 |

### 8.2 Modelo do app (ONNX int8): **o que está em uso**
| Métrica | Valor |
|---|---|
| Fidelidade ONNX fp32 vs. PyTorch (cosseno) | 1,0000 |
| Fidelidade ONNX int8 vs. PyTorch (cosseno) | média 0,9764 · mín. 0,9474 |
| Acerto entre as rochas, LOO / blocos | 100% / 100% |
| Similaridade das positivas (blocos) | mín. **0,858** · média 0,914 · máx. 0,966 |
| Similaridade das negativas | mín. 0,309 · média 0,556 · máx. **0,707** |
| Limiares calibrados | `match` 0,765 · `rock` 0,30 |
| Positivas reconhecidas / negativas rejeitadas | 100% / 100% |

Entre a pior positiva (0,858) e a pior negativa (0,707) há uma **margem de 0,15**. Uma margem grande é o que dá
confiança de que fotos novas também serão separadas.

A quantização **por canal** foi testada e descartada: cosseno médio de 0,737, bem pior que a quantização por tensor.

### 8.3 Pré-processamento em Dart vs. Python
O app reimplementa o pré-processamento em Dart (pacote `image`). Foram comparadas 19 fotos:
- Diferença média por pixel: 0,049 (em unidades normalizadas, ≈ 3/255 em brilho).
- Cosseno entre os vetores Dart e Python: média 0,9815 · mín. 0,9662.
- Decisão completa usando os tensores do Dart: **19/19 corretas**. A pior rocha teve score 0,883, e a pior negativa 0,690.

A diferença vem dos decodificadores de JPEG e dos algoritmos de redimensionamento de cada biblioteca. Ela não mudou
nenhuma decisão.

### 8.4 Teste informal do usuário (no app, com o servidor v0.2)
- Fotos de negativas tiradas na hora: rejeitadas.
- Fotos da rocha **giradas** e fotos **tiradas da tela do PC**: reconhecidas corretamente.

Isso sugere robustez à rotação e a mudanças de captura, mas ainda não é um teste independente formal.

---

## 9. Limitações e trabalhos futuros

1. **Conjunto de teste independente**: coletar fotos de outro dia, horário, clima e celular, e reportar acurácia,
   precisão, revocação e taxa de falsos positivos nesse conjunto.
2. **Mais classes**: com 2 rochas o problema é fácil. Afloramentos visualmente parecidos (dois gnaisses, por
   exemplo) vão aproximar os scores. Nesse ponto entra o **GPS como filtro de candidatos**.
3. **Comparação de classificadores**: treinar RF, MLP, Naive Bayes e regressão logística com os mesmos vetores de
   512 dimensões, com a mesma validação em blocos, e comparar com o k-NN (tabela para o paper).
4. **Fine-tuning** do encoder com fotos do campus, se as classes começarem a se confundir.
5. **Usuário curador**: adicionar e remover fotos de referência pelo app.
6. **Negativas mais variadas**: o filtro é-rocha foi calibrado com só 31 negativas.

---

## 10. Execução no celular (arquitetura de produção)

```
 App Flutter (celular)                                   Firestore (plano Spark, gratuito)
 ┌─────────────────────────────────────────┐             ┌─────────────────────────────────┐
 │ RecognizeScreen → RecognitionBloc       │             │ rocks/{id}                      │
 │        → RecognitionProvider            │  leitura    │   nome, minerais, descrição     │
 │            ├ EmbeddingService (ONNX)    │◄────────────│   embeddings (float16, base64)  │
 │            ├ ReferenceIndexProvider ────┼─────────────│ recognition_config/current      │
 │            └ similarity.dart (decisão)  │ (só logado) │   limiares, frases do filtro    │
 └─────────────────────────────────────────┘             └─────────────────────────────────┘
```
- **ONNX** é um formato aberto para redes neurais. O modelo PyTorch foi exportado para ONNX e roda no celular com o
  ONNX Runtime, sem Python e sem servidor.
- **Quantização int8** (Jacob et al., 2018): os pesos passam de float32 (4 bytes) para int8 (1 byte). O modelo caiu
  de 352 MB para **89 MB**, e a fidelidade ficou alta (seção 8.2).
- **Float16 no Firestore**: cada vetor de referência ocupa 1 KB (512 × 2 bytes) e ~1,4 KB em base64. Cada rocha é
  um documento só, com ~53 KB para 40 fotos. Abrir o app custa ~3 leituras.
- **Versão do modelo**: o app só aceita uma base com o mesmo `modelVersion` do modelo embarcado. Vetores de modelos
  diferentes não são comparáveis.

---

## 11. Mapa do projeto: onde fica cada coisa

| Caminho | O que é |
|---|---|
| `ml/dataset/` | Fotos (não versionadas) + `renomeacao.csv` |
| `ml/common.py` | Pré-processamento, modelo, filtro é-rocha, k-NN, `decide()`: a lógica central |
| `ml/build_index.py` | Gera `index.npz` (um vetor por foto) |
| `ml/evaluate.py` | Avaliação (LOO, blocos) e calibração → `config.json` |
| `ml/export_onnx.py` | PyTorch → ONNX → int8 + teste de fidelidade → `assets/models/` |
| `ml/check_preprocess_parity.py` | Compara o pré-processamento do Dart com o do Python |
| `ml/upload_firestore.py` | Publica rochas e configuração no Firestore, e gera o fixture de teste |
| `ml/server.py` | Servidor HTTP de laboratório (v0.2). O app não usa mais |
| `ml/rocks.json` | Cadastro: nome, litologia, minerais, descrição |
| `assets/models/clip_visual_int8.onnx` | Modelo embarcado no app (gerado, não versionado) |
| `lib/recognition/similarity.dart` | Mesma lógica do `decide()`, em Dart |
| `lib/provider/embedding_service.dart` | Pré-processamento + execução do ONNX no celular |
| `lib/provider/reference_index_provider.dart` | Lê `rocks` e `recognition_config` do Firestore |
| `lib/provider/recognition_provider.dart` | Junta tudo: foto → resultado |
| `lib/bloc/recognition_bloc.dart` | Eventos e estados do reconhecimento |
| `lib/view/recognize_screen.dart` | Tela (moldura + card animado) |
| `test/recognition_similarity_test.dart` | Confere Dart == Python na decisão |
| `firestore.rules` | Regras de segurança do Firestore |

---

## 12. Receita reaproveitável (para outros projetos de "reconhecer objetos específicos")

1. **Defina a pergunta**: instância ("qual destes?") ou categoria ("que tipo?"). Para conjuntos pequenos e
   conhecidos, instância com k-NN costuma bastar.
2. **Colete por classe** 20 a 40 fotos variando ângulo, distância e luz, e **uma pasta de negativas** (essencial
   para o "não sei").
3. **Extraia vetores** com um modelo pré-treinado (CLIP / OpenCLIP) → `build_index.py`.
4. **Avalie com cuidado**: LOO e **blocos** (rajadas são dependentes), e calibre os limiares por acurácia
   balanceada → `evaluate.py`.
5. **Rejeite o desconhecido**: limiar de similaridade e, opcionalmente, filtro zero-shot por texto.
6. **Leve para o celular**: exporte para ONNX, quantize em int8, confira a fidelidade (cosseno ≥ ~0,97) →
   `export_onnx.py`.
7. **Espelhe o pré-processamento** no app e **meça a paridade** → `check_preprocess_parity.py`.
8. **Publique as referências** num banco (float16 + base64) com versão do modelo → `upload_firestore.py`.
9. **Teste a decisão** do app contra a do Python com um fixture → `flutter test`.
10. **Reavalie com dados novos** antes de afirmar qualquer acurácia.

### Como reproduzir (na pasta `aula11/ml`, com o venv ativo `.\.venv\Scripts\Activate.ps1`)
```powershell
python export_onnx.py          # gera o modelo int8 e copia para assets/models
python build_index.py          # vetores das fotos (com o modelo int8)
python evaluate.py             # avaliação + config.json
python upload_firestore.py --fixture   # fixture para o teste do Dart
cd ..; flutter test            # Dart decide igual ao Python
cd ml; python upload_firestore.py      # publica no Firestore (precisa da chave de serviço)
```

---

## 13. Referências

- **Brodersen, K. H.; Ong, C. S.; Stephan, K. E.; Buhmann, J. M.** (2010). *The Balanced Accuracy and Its
  Posterior Distribution.* ICPR 2010. Fundamenta a acurácia balanceada como critério de calibração.
- **Cherti, M. et al.** (2023). *Reproducible Scaling Laws for Contrastive Language-Image Learning.* CVPR 2023.
  Fundamenta o OpenCLIP e os pesos treinados no LAION.
- **Cover, T.; Hart, P.** (1967). *Nearest Neighbor Pattern Classification.* IEEE Transactions on Information
  Theory, 13(1). Fundamenta o classificador k-NN.
- **Dosovitskiy, A. et al.** (2021). *An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale.*
  ICLR 2021. Fundamenta a arquitetura ViT.
- **Jacob, B. et al.** (2018). *Quantization and Training of Neural Networks for Efficient Integer-Arithmetic-Only
  Inference.* CVPR 2018. Fundamenta a quantização int8.
- **Paszke, A. et al.** (2019). *PyTorch: An Imperative Style, High-Performance Deep Learning Library.* NeurIPS
  2019. O framework usado.
- **Radford, A. et al.** (2021). *Learning Transferable Visual Models From Natural Language Supervision.* ICML 2021.
  Fundamenta o CLIP, os embeddings imagem-texto e a classificação zero-shot.
- **Razavian, A. S.; Azizpour, H.; Sullivan, J.; Carlsson, S.** (2014). *CNN Features off-the-shelf: an Astounding
  Baseline for Recognition.* CVPR Workshops 2014. Fundamenta o uso de features pré-treinadas com um classificador simples.
- **Roberts, D. R. et al.** (2017). *Cross-validation strategies for data with temporal, spatial, hierarchical, or
  phylogenetic structure.* Ecography, 40(8). Fundamenta a validação em blocos para dados dependentes.
- **Scheirer, W. J.; Rocha, A.; Sapkota, A.; Boult, T. E.** (2013). *Toward Open Set Recognition.* IEEE TPAMI,
  35(7). Fundamenta a rejeição de amostras desconhecidas.
- **Schuhmann, C. et al.** (2022). *LAION-5B: An open large-scale dataset for training next generation image-text
  models.* NeurIPS 2022 (Datasets and Benchmarks). Fundamenta os dados de pré-treino.
- **Stone, M.** (1974). *Cross-Validatory Choice and Assessment of Statistical Predictions.* Journal of the Royal
  Statistical Society, Series B, 36(2). Fundamenta a validação cruzada e o leave-one-out.
