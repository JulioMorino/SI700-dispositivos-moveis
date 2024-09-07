import 'package:aula05_forms/provider/sheets_provider.dart';
import 'package:aula05_forms/view/screens/feedback_screen.dart';
import 'package:flutter/material.dart';

class TerceiraTela extends StatefulWidget {
  const TerceiraTela({Key? key}) : super(key: key);

  @override
  State<TerceiraTela> createState() => _TerceiraTelaState();
}

class _TerceiraTelaState extends State<TerceiraTela> {
  String name = '';
  String contact = '';
  String userMessage = '';
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); //mantem variavel caso ocorra alguma interrupcao no android
  bool _termsAccepted = false;
  int _selectedOption = 1;
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Nome'), // Rótulo do campo
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome'; // Mensagem de erro
                }
                return null;
              },
              onSaved: (value) {
                // Ação ao salvar o campo
                name = value!;
              },
            ),
            TextFormField(
              decoration:
                  InputDecoration(labelText: 'Contato'), // Rótulo do campo
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu contato'; // Mensagem de erro
                }
                return null;
              },
              onSaved: (value) {
                // Ação ao salvar o campo
                contact = value!;
              },
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Mensagem do Usuario'), // Rótulo do campo
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira uma mensagem'; // Mensagem de erro
                }
                return null;
              },
              onSaved: (value) {
                // Ação ao salvar o campo
                userMessage = value!;
              },
            ),
            RadioListTile(
              title: Text('Email'),
              value: 1,
              groupValue: _selectedOption,
              onChanged: (int? value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            RadioListTile(
              title: Text('Telefone'),
              value: 2,
              groupValue: _selectedOption,
              onChanged: (int? value) {
                setState(() {
                  _selectedOption = value!;
                });
              },
            ),
            DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: Text('Selecione uma categoria'),
                items:
                    ['Dúvida', 'Sugestão', 'Reclamação'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                }),
            CheckboxListTile(
              title: Text('Aceito os termos e condições'),
              value: _termsAccepted,
              onChanged: (bool? value) {
                setState(() {
                  _termsAccepted = value ?? false;
                });
              },
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Future<String?> futureResult =
                      SheetsDatabase.helper.submitData([
                    name,
                    contact,
                    userMessage,
                    _selectedOption == 1 ? 'Email' : 'Telefone',
                    _selectedCategory!
                  ]);

                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        padding: const EdgeInsets.all(16.0),
                        color: Colors.grey[900], // Fundo da BottomSheet
                        child: FeedbackScreen(futureResult: futureResult),
                      );
                    },
                  );
                }
              },
              child: Text('Enviar'),
            ),
          ],
        ));
  }
}
