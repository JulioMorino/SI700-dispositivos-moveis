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
                if (_formKey.currentState!.validate() && !_termsAccepted) {
                  showTermDialog();
                } else if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  Future<String?> futureResult =
                      SheetsDatabase.helper.submitData([
                    name,
                    _selectedOption == 1 ? 'Email' : 'Telefone',
                    contact,
                    userMessage,
                    _selectedCategory!,
                    _termsAccepted == true ? 'Sim' : 'Não'
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

                  _formKey.currentState!.reset();
                  setState(() {
                    _termsAccepted = false;
                    _selectedOption = 1;
                    _selectedCategory = null;
                  });
                }
              },
              child: Text('Enviar'),
            ),
          ],
        ));
  }

  showTermDialog() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 27, 27, 27),
          title: Icon(
            Icons.error,
            color: Colors.red,
            size: 60,
          ),
          content: Text(
            'Você precisa aceitar os termos e condições para enviar os dados.',
            style: TextStyle(
                fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
