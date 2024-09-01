import 'package:flutter/material.dart';
import 'package:aula04_layout_e_textformfield/view/screens/tip.dart';
import 'package:flutter/services.dart';

class SegundaTela extends StatefulWidget {
  const SegundaTela({Key? key}) : super(key: key);

  @override
  State<SegundaTela> createState() => _SegundaTelaState();
}

class _SegundaTelaState extends State<SegundaTela> {
  Tip tip = Tip();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xff2c742f),
      child: Column(children: [
        TextFormField(
          initialValue: tip.amount,
          keyboardType: TextInputType.number,
          onChanged: (value) {
            setState(() {
              tip.amount = value;
            });
          },
          decoration: const InputDecoration(labelText: 'Valor total'),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
          ],
        ),
        Text('Gorjeta Customizada: ${tip.customTip}',
            style: TextStyle(color: Colors.white)),
        Text('Valor Total: ${tip.amount}',
            style: TextStyle(color: Colors.white)),
        Text('Gorjeta Padrão: ${tip.defaultTip}',
            style: TextStyle(color: Colors.white)),
        Text('Valor da Gorjeta Padrão: ${tip.defaultTippedAmount}',
            style: TextStyle(color: Colors.white)),
        Text(
            'Valor Total com Gorjeta Padrão: ${tip.amountPlusDefaultTippedAmount}',
            style: TextStyle(color: Colors.white)),
        Text('Valor da Gorjeta Customizada: ${tip.customTippedAmount}',
            style: TextStyle(color: Colors.white)),
        Text(
            'Valor Total com Gorjeta Customizada: ${tip.amountPlusCustomTippedAmount}',
            style: TextStyle(color: Colors.white)),
        InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Gorjeta Customizada',
            ),
            child: Slider(
              min: 1,
              max: 100,
              value: double.parse(tip.customTip),
              onChanged: (value) {
                setState(() {
                  tip.customTip = value.toString();
                });
              },
            ))
      ]),
    );
  }
}
