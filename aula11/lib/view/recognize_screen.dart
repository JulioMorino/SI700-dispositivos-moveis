import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/recognition_bloc.dart';

class RecognizeScreen extends StatelessWidget {
  const RecognizeScreen({super.key});

  Future<void> _pick(BuildContext context, ImageSource source) async {
    // Mesmos limites usados no PickAFile: foto leve, rápida de enviar.
    final XFile? image = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 60,
    );
    if (image == null) return;
    final Uint8List bytes = await image.readAsBytes();
    // ignore: use_build_context_synchronously
    BlocProvider.of<RecognitionBloc>(context)
        .add(RecognizeRequest(imageBytes: bytes));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Reconhecer Rocha"),
      ),
      body: BlocBuilder<RecognitionBloc, RecognitionState>(
        builder: (context, state) {
          final bool busy = state is Recognizing;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Frame(state: state),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.15),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _ResultCard(key: ValueKey(state.runtimeType), state: state),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed:
                            busy ? null : () => _pick(context, ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: Text(state is RecognitionIdle
                            ? "Tirar foto"
                            : "Tirar outra foto"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.outlined(
                      tooltip: "Escolher da galeria",
                      onPressed:
                          busy ? null : () => _pick(context, ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Moldura da foto. A borda muda de cor conforme o resultado.
class _Frame extends StatelessWidget {
  final RecognitionState state;
  const _Frame({required this.state});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outlineVariant;
    if (state is Recognized) border = Colors.green;
    if (state is NotRecognized) border = Colors.orange;
    if (state is RecognitionError) border = scheme.error;

    return AspectRatio(
      aspectRatio: 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border, width: 4),
          color: scheme.surfaceContainerHighest,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (state is RecognitionWithImage)
                // gaplessPlayback evita o "pisca" ao reconstruir com os mesmos bytes
                Image.memory((state as RecognitionWithImage).imageBytes,
                    fit: BoxFit.cover, gaplessPlayback: true)
              else
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.landscape, size: 72, color: scheme.outline),
                    const SizedBox(height: 8),
                    Text("Fotografe um afloramento",
                        style: TextStyle(color: scheme.outline)),
                  ],
                ),
              if (state is Recognizing)
                Container(
                  color: Colors.black45,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 12),
                      Text("Analisando...",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final RecognitionState state;
  const _ResultCard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final s = state;

    if (s is Recognized) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(s.name, style: text.headlineSmall)),
                ],
              ),
              if (s.lithology.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(s.lithology,
                    style: text.titleSmall
                        ?.copyWith(color: Theme.of(context).colorScheme.primary)),
              ],
              const SizedBox(height: 12),
              Text(s.description, style: text.bodyMedium),
              if (s.minerals.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final m in s.minerals) Chip(label: Text(m))],
                ),
              ],
              const SizedBox(height: 8),
              Text("Similaridade: ${(s.score * 100).toStringAsFixed(0)}%",
                  style: text.labelSmall),
            ],
          ),
        ),
      );
    }

    if (s is NotRecognized || s is RecognitionError) {
      final bool isError = s is RecognitionError;
      final String message =
          s is NotRecognized ? s.message : (s as RecognitionError).message;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(isError ? Icons.wifi_off : Icons.search_off,
                  color: isError ? Theme.of(context).colorScheme.error : Colors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text(message, style: text.bodyLarge)),
            ],
          ),
        ),
      );
    }

    // Idle e Recognizing: espaço vazio (o "carregando" fica na moldura).
    return const SizedBox(height: 0);
  }
}
