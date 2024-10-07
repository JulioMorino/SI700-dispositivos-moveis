// ignore_for_file: file_names
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final controlller;
  String labelText;
  int? initialValue;
  CustomTextFormField(
      {required this.controlller, required this.labelText, super.key});

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: widget.initialValue?.toString(),
        controller: widget.controlller,
        decoration: InputDecoration(
          labelText: widget.labelText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Campo obrigatório' : null,
      ),
    );
  }
}
