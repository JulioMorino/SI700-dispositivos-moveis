import 'package:flutter/material.dart';

import '../screens/primeira_tela.dart';
import '../screens/segunda_tela.dart';
import '../screens/terceira_tela.dart';

class MyBottomNavigationBar extends StatefulWidget {
  const MyBottomNavigationBar({super.key});

  @override
  State<MyBottomNavigationBar> createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  int _currentScreen = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("MyBottomNavigationBar")),
      body: IndexedStack(
        index: _currentScreen,
        children: [PrimeiraTela(), SegundaTela(), TerceiraTela()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentScreen,
        onTap: (value) {
          setState(() {
            _currentScreen = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.wifi),
            label: "asdf",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.face_2),
            label: "asdf",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.hail_outlined,
              ),
              label: "adsf")
        ],
        fixedColor: Colors.red,
      ),
    );
  }
}
