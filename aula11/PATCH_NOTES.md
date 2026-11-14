# Patch Notes: aula11 / Reconhecimento de Afloramentos

Este arquivo registra **toda** alteração no projeto, de forma didática. Cada versão diz **o que mudou**, **por
quê**, mostra os **trechos antes/depois** e lista **o que foi instalado ou baixado e para quê**.
A versão mais nova fica no topo.

---

## v0.3: Reconhecimento 100% no celular (ONNX) + rochas no Firestore

### Por quê
- **Antes (v0.2):** o app dependia de um servidor Python no PC, com o IP fixo no código. Só funcionava em casa, na
  mesma rede Wi-Fi.
- **Agora:** o modelo roda **dentro do celular**, e as rochas de referência ficam no **Firestore**.
- **Resultado:** funciona em qualquer lugar (ex.: na Unicamp, com dados móveis), sem servidor exposto, sem IP no
  código e sem cartão de crédito (plano Spark gratuito).

### A ideia em uma frase
O modelo PyTorch foi **convertido para ONNX** (formato que roda em qualquer plataforma), **comprimido para int8** e
colocado nos assets do app. O Firestore guarda só os **vetores** das fotos de referência e as descrições.

### 1. Python (`ml/`)
**Novos arquivos**
| Arquivo | Para que serve |
|---|---|
| `export_onnx.py` | PyTorch → ONNX fp32 (352 MB) → quantização int8 (**89 MB**) → teste de fidelidade → copia para `assets/models/` |
| `upload_firestore.py` | Publica `rocks/{id}` e `recognition_config/current` no Firestore. `--fixture` gera os dados do teste do Dart |
| `check_preprocess_parity.py` | Mede se o pré-processamento do Dart dá o mesmo resultado que o do Python |
| `RELATORIO_MODELO.md` | Relatório técnico: pipeline, hiperparâmetros, avaliação, referências, receita |

**`common.py`: pré-processamento próprio**
- Antes era usada a função pronta do open_clip, impossível de copiar exatamente em Dart.
- Agora há uma função simples, reimplementada igualzinha no app:
```python
# depois
img = img.resize((nw, nh), Image.BOX)        # lado menor -> 224, média de área
img = img.crop(...)                          # corte central 224x224
x = (x/255 - CLIP_MEAN) / CLIP_STD           # normalização
```
- `embed_images(..., backend="onnx")`: o índice passa a ser gerado com o **mesmo modelo int8 do app**. Vetores de
  modelos diferentes não são comparáveis.
- Nova função `decide()`: a regra de decisão num lugar só. O servidor, o upload e o teste do Dart usam a mesma.

**Recalibração com o modelo int8**: `match_threshold` 0.782 → **0.765** e `rock_threshold` 0.15 → **0.30**. O acerto
continua em 100% / 100%.

**O que foi instalado (venv)**
| Pacote | Para que |
|---|---|
| `onnx` | Formato de arquivo do modelo exportado |
| `onnxruntime` | Executa o ONNX no PC (fidelidade e índice) e faz a quantização int8 |
| `onnxscript` | Dependência do exportador ONNX do PyTorch |
| `firebase-admin` | Escreve no Firestore a partir do PC, com chave de conta de serviço |

### 2. Firestore
- Nova coleção `rocks/{id}`: nome, litologia, minerais, descrição e `embeddings`.
  - Os vetores são guardados em **float16 + base64**, porque o Firestore não aceita listas dentro de listas.
  - Isso dá ~53 KB por rocha com 40 fotos.
- Novo documento `recognition_config/current`: limiares, `logitScale`, as frases do filtro "é rocha?" e o `modelVersion`.
- Novo arquivo `firestore.rules`:
  - `rocks` e `recognition_config`: só leitura, e só para quem está logado.
  - Notas: cada usuário lê e escreve só as suas.
  - Todo o resto: bloqueado.

### 3. Flutter
**Novos arquivos**
| Arquivo | Para que serve |
|---|---|
| `lib/recognition/similarity.dart` | A regra de decisão em Dart puro: decodifica float16, filtro é-rocha, k-NN top-3, limiares |
| `lib/provider/embedding_service.dart` | Carrega o ONNX e transforma a foto em vetor. O pré-processamento roda em outro isolate (`compute`) para não travar a tela |
| `lib/provider/reference_index_provider.dart` | Lê `rocks` e `recognition_config` (padrão singleton `helper`, igual ao `GenericCrudProvider`) e confere o `modelVersion` |
| `test/recognition_similarity_test.dart` | Confere que o Dart decide **igual** ao Python |
| `test/preprocess_parity_test.dart` | Gera os tensores do Dart para comparar com o Python |

**`lib/provider/recognition_provider.dart`: reescrito, com a mesma assinatura**
```dart
// antes (v0.2): HTTP para o PC
Response response = await _dio.post("/recognize", data: form);
// depois (v0.3): tudo local
final index = await ReferenceIndexProvider.helper.load();     // Firestore
final query = await EmbeddingService.helper.embed(bytes);     // ONNX no celular
final r = decide(query, index.rocks, index.config);           // k-NN + limiares
```
💡 **Lição de arquitetura:** a tela e o BLoC praticamente não mudaram, porque o Provider esconde **de onde** vem o
resultado. É para isso que serve separar as camadas.

**`lib/bloc/recognition_bloc.dart`**
- Novo evento `PrepareRecognition`: pré-carrega o modelo e a base ao abrir a tela.
- O `catch` agora separa três casos, cada um com sua mensagem:
  - `RecognitionException`: mensagem pronta (ex.: "base ainda não publicada").
  - `FirebaseException`: permissão negada ou sem internet.
  - Outros erros.

**`lib/bloc/manage_bloc.dart`**: `onError` no stream de notas. Com as regras novas, quando ninguém está logado
(uid "default") a leitura é negada, e antes isso virava um erro não tratado.

**`lib/view/list_note.dart`**: o botão de reconhecimento dispara `ResetRecognition` + `PrepareRecognition`.

**O que foi instalado (pub)**
| Pacote | Versão | Para que |
|---|---|---|
| `flutter_onnxruntime` | 1.9.0 | Executa o modelo ONNX no Android/iOS (ONNX Runtime nativo 1.28.0) |
| `image` | 4.13.1 | Decodificar, girar (EXIF), redimensionar e cortar a foto em Dart puro |

### 4. Android
- `android/app/build.gradle`: `minSdkVersion` 23 → **24** (Android 7.0), o mínimo exigido pelo ONNX Runtime.
- `android/gradle.properties`: memória do Gradle de 1.5 GB → **4 GB**. O build falhava com `Java heap space`
  (o asset de 89 MB pesa).
- `android/app/proguard-rules.pro` (novo): `-keep class ai.onnxruntime.**`, para o R8 não remover as classes que o
  código nativo usa.
- `AndroidManifest.xml`: **removido** o `usesCleartextTraffic`, já que não existe mais HTTP local. Fica só o `INTERNET`.
- `pubspec.yaml`: o asset `assets/models/clip_visual_int8.onnx` foi registrado.

### 5. `.gitignore`
- Antes, `/ml` ignorava a pasta inteira, scripts inclusive.
- Agora são ignorados só as fotos (`ml/dataset/`), o `.venv`, o `index.npz`, os `.onnx` e as chaves de serviço do
  Firebase. Os scripts e o relatório passam a ser versionados.

### 6. Verificações feitas
| Teste | Resultado |
|---|---|
| ONNX fp32 vs. PyTorch | cosseno 1.0000 |
| ONNX int8 vs. PyTorch | cosseno médio 0.976 (quantização por canal testada: 0.737, descartada) |
| Pré-processamento Dart vs. Python (19 fotos) | cosseno médio 0.982, **19/19 decisões corretas** |
| `flutter test` (Dart decide igual ao Python) | ✅ passou |
| `flutter analyze` | sem erros |
| APK de release | 95 MB (armv7) · 105 MB (arm64) · 112 MB (x86_64) |

### Publicação da base (2026-11-14)
- ✅ **Chave de serviço** gerada e salva **fora** do repositório, em `C:\Users\<você>\chaves\`.
  - A variável `GOOGLE_APPLICATION_CREDENTIALS` diz ao `firebase-admin` onde está a chave.
  - Ela só vale na janela do terminal em que foi definida.
- ✅ **Base enviada** com `upload_firestore.py` e conferida lendo de volta do Firestore:
  - `rocks/gnaisse_granada_cianita`: 40 vetores (40 × 512)
  - `rocks/tronco_silicificado`: 39 vetores (39 × 512)
  - `recognition_config/current`: match 0.765 · rock 0.30 · topK 3 · 18 frases
- ⏳ **Publicar as regras** (você): colar `firestore.rules` em Firestore → Regras → Publicar.
- ⏳ **Testar no celular com dados móveis:** `flutter run`.

**Para atualizar a base no futuro** (fotos novas ou descrição alterada no `rocks.json`):
```powershell
cd aula11\ml
$env:GOOGLE_APPLICATION_CREDENTIALS = "C:\Users\<você>\chaves\<arquivo-da-chave>.json"
.\.venv\Scripts\python.exe build_index.py
.\.venv\Scripts\python.exe evaluate.py
.\.venv\Scripts\python.exe upload_firestore.py
```
O app não precisa ser gerado de novo: ele lê a base nova do Firestore.

---

## v0.2: Protótipo de reconhecimento (servidor Python no PC)

### Por quê
Primeira versão de ponta a ponta da ideia "tiro a foto → o app diz qual rocha é". O reconhecimento roda num
servidor Python no PC, e o celular manda a foto pela rede Wi-Fi de casa.

### 1. Dataset renomeado
- As fotos de `ml/dataset/<classe>/` ganharam nomes legíveis: `gnaisse_granada_cianita_001.jpg`,
  `tronco_silicificado_001.jpg`, `negativo_001.jpg`.
- A numeração segue a ordem do horário que estava no nome original do WhatsApp.
- `ml/dataset/renomeacao.csv` guarda `nome_original → nome_novo`, então dá para desfazer.
- Contagem: 40 fotos do gnaisse, 39 do tronco e 31 negativas.

### 2. Pasta `ml/` (Python)
| Arquivo | Para que serve |
|---|---|
| `requirements.txt` | Lista de pacotes Python do projeto |
| `common.py` | Carrega o modelo CLIP, transforma foto em vetor e faz o filtro "é rocha?" |
| `build_index.py` | Gera `index.npz`: um vetor por foto do dataset |
| `evaluate.py` | Mede o acerto e **calibra** os limiares (grava `config.json`) |
| `server.py` | Servidor HTTP (FastAPI) com `POST /recognize` |
| `rocks.json` | Nome e descrição de cada rocha (o "cadastro") |

### 3. O que foi instalado (no ambiente virtual `ml/.venv`)
O ambiente virtual (`python -m venv .venv`) é uma "caixinha" de pacotes só deste projeto, para não misturar com o
Python do sistema.
| Pacote | O que é | Por que |
|---|---|---|
| `torch` (PyTorch), versão CPU | Biblioteca de redes neurais da Meta | É o "motor" que executa o modelo CLIP. A versão CPU é bem menor que a com CUDA (GPU) |
| `open_clip_torch` | Implementação aberta do CLIP | Fornece a arquitetura ViT-B/32 e os pesos pré-treinados |
| `pillow` | Leitura de imagens | Abre JPG/PNG e corrige a rotação EXIF |
| `numpy` | Arrays numéricos | Contas com os vetores (similaridade) |
| `fastapi`, `uvicorn`, `python-multipart` | Servidor web | Recebem a foto do app pela rede |

**Download dos pesos do modelo (~600 MB)**: na primeira execução, o open_clip baixou do Hugging Face os pesos
`ViT-B-32 / laion2b_s34b_b79k`. Eles ficam em cache em `C:\Users\<você>\.cache\huggingface` e não são baixados de novo.

### 4. Flutter
**Novos arquivos**
- `lib/provider/recognition_provider.dart`: envia a foto ao servidor com `dio` (POST multipart).
- `lib/bloc/recognition_bloc.dart`:
  - Evento `RecognizeRequest` e estados `Recognizing` → `Recognized` / `NotRecognized` / `RecognitionError`.
  - Mesmo padrão do `ManageBloc`.
- `lib/view/recognize_screen.dart`:
  - Moldura com a foto, cuja borda muda de cor conforme o resultado.
  - Card com animação (fade + slide via `AnimatedSwitcher`).

**`main.dart`**: o novo BLoC foi registrado no `MultiBlocProvider`.
```dart
// depois
BlocProvider(create: (context) { return RecognitionBloc(); }),
```

**`list_note.dart`**: botão novo (ícone de paisagem) que abre a `RecognizeScreen`. O `heroTag` é próprio para não
conflitar com os outros FABs.

**`AndroidManifest.xml` (main)**
- Adicionada a permissão `INTERNET`, que antes só existia nos manifests de debug/profile.
- Adicionado `android:usesCleartextTraffic="true"`, para permitir HTTP sem "s" ao servidor local.

### Resultado medido
- Tronco × gnaisse: 100% de acerto.
- Negativas: 100% rejeitadas.
- Limiares: `match_threshold = 0.782` e `rock_threshold = 0.15`.

---

## v0.1: Correção: foto da câmera não subia para o Firestore

### O problema
A foto da câmera aparecia na moldura ("piscava duas vezes"), mas não era salva no banco, e nenhum erro aparecia.

### A causa
1. **O Firestore aceita no máximo 1 MiB por documento.** Uma foto da câmera tem vários MB, e o base64 ainda
   aumenta ~33%.
2. **O erro era engolido**: o código chamava `add()` sem `await`. O Future falhava "no vazio" e ninguém via.

### O que mudou
**`lib/view/widgets/pick_a_file.dart`**: a foto é reduzida já na captura.
```dart
// antes
await ImagePicker().pickImage(source: ImageSource.camera);
// depois
await ImagePicker().pickImage(
  source: ImageSource.camera,
  maxWidth: 800, maxHeight: 800, imageQuality: 60,   // ~100 KB
);
```
No FilePicker: `withData: true` (no Android os `bytes` vinham `null` sem isso) e `FileType.image`.

**`lib/provider/generic_crud_provider.dart`**: `await` nas escritas, para o erro "subir" até quem chamou.
```dart
// antes
noteCollection.doc(uid).collection("my_notes").add(note.toMap());
// depois
await noteCollection.doc(uid).collection("my_notes").add(note.toMap());
```

**`lib/bloc/manage_bloc.dart`**
- `on<SubmitEvent>` e `on<DeleteEvent>` passaram a ser `async`, com `try/catch` + `debugPrint`.
- Novo evento `SubscribeNoteStreamEvent`.
  - **Problema que ele resolve:** o BLoC começava a ouvir o Firestore no construtor, quando o `uid` ainda era
    `"default"`. Depois do login ele continuava ouvindo a pasta errada.
  - **Como resolve:** cancela a assinatura antiga e assina de novo com o `uid` atual.

**`lib/view/wrapper.dart`**: quando o `AuthBloc` muda para logado ou deslogado, o `listener` dispara
`SubscribeNoteStreamEvent` e `GetNoteListEvent` no `ManageBloc`. É a View fazendo a ponte entre os dois BLoCs.

### Nada foi instalado nesta versão.
