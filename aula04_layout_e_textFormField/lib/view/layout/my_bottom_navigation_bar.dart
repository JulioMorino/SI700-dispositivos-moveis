import 'package:aula04_layout_e_textformfield/view/layout/my_navigation_drawer.dart';
import 'package:aula04_layout_e_textformfield/view/screens/primeira_tela.dart';
import 'package:aula04_layout_e_textformfield/view/screens/segunda_tela.dart';
import 'package:aula04_layout_e_textformfield/view/screens/terceira_tela.dart';
import 'package:flutter/material.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('My bottom tab')),
        body: IndexedStack(
          children: [SegundaTela(), PrimeiraTela(), TerceiraTela()],
          index: _currentScreen,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (value) {
            setState(() {
              print(value);
              _currentScreen = value;
            });
          },
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.wifi), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.house), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.call), label: ''),
          ],
        ));
  }
}
