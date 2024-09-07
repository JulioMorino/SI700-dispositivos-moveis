import 'package:flutter/material.dart';

class TerceiraTela extends StatefulWidget {
  const TerceiraTela({Key? key}) : super(key: key);

  @override
  State<TerceiraTela> createState() => _TerceiraTelaState();
}

class _TerceiraTelaState extends State<TerceiraTela> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe14d39), Color(0xffe87a6c)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(width: 5),
                  ),
                  child: Image.network(
                      'https://raw.githubusercontent.com/ulissesdias/si700/main/e_forms_intro/assets/images/ulisses.gif'),
                )),
            Text(
              'Utils.linkUniformVariable({kind: 2fv})',
              style: TextStyle(color: Colors.white, fontSize: 20),
            )
          ],
        ));
  }
}
