import 'package:flutter/material.dart';

class PrimeiraTela extends StatefulWidget {
  const PrimeiraTela({Key? key}) : super(key: key);

  @override
  State<PrimeiraTela> createState() => _PrimeiraTelaState();
}

class _PrimeiraTelaState extends State<PrimeiraTela> {
  String nome = '';
  final GlobalKey<FormState> _formKey = GlobalKey<
      FormState>(); //mantem variavel caso ocorra alguma interrupcao no android

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.green,
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text('Nome completo')),
                onSaved: (newValue) {},
                validator: (receivedValue) {
                  if (receivedValue == null) {
                    return 'Erro: Insira seu nome';
                  } else {}
                },
              ),
              TextFormField(
                validator: (String? value) {
                  value!.isEmpty ? 'Nome obrigatório' : null;
                },
              ),
              TextFormField(),
              ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      //faça algo
                    }
                  },
                  child: Text('Submit'))
            ],
          )),
    );
  }
}
