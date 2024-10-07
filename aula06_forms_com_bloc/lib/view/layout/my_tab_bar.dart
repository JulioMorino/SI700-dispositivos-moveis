import 'package:flutter/material.dart';

import '../screens/primeira_tela.dart';
import '../screens/segunda_tela.dart';
import '../screens/terceira_tela.dart';

class MyTabLayout extends StatelessWidget {
  const MyTabLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MyTabLayout"),
          bottom: const TabBar(tabs: [
            Tab(icon: Icon(Icons.wifi), text: "Wifi"),
            Tab(icon: Icon(Icons.face), text: "Carinha"),
            Tab(icon: Icon(Icons.hail_outlined), text: "Carona")
          ]),
        ),
        body: TabBarView(
            children: [PrimeiraTela(), SegundaTela(), TerceiraTela()]),
      ),
    );
  }
}
