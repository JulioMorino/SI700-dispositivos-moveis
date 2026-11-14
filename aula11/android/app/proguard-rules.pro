# Exigido pelo flutter_onnxruntime: impede que o R8 remova/renomeie as classes
# do ONNX Runtime no build de release (o código nativo as acessa por nome).
-keep class ai.onnxruntime.** { *; }
