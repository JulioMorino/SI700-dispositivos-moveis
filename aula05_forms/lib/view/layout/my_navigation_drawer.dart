import 'package:aula05_forms/view/screens/primeira_tela.dart';
import 'package:aula05_forms/view/screens/segunda_tela.dart';
import 'package:aula05_forms/view/screens/terceira_tela.dart';
import 'package:flutter/material.dart';

class MyNavigationDrawer extends StatefulWidget {
  const MyNavigationDrawer({Key? key}) : super(key: key);

  @override
  State<MyNavigationDrawer> createState() => _MyNavigationDrawerState();
}

class _MyNavigationDrawerState extends State<MyNavigationDrawer> {
  int _currentScreen = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My drawer')),
      body: IndexedStack(
        index: _currentScreen,
        children: [PrimeiraTela(), SegundaTela(), TerceiraTela()],
      ),
      drawer: Drawer(
        child: ListView(children: [
          DrawerHeader(
              child: Container(
            color: Colors.blue,
          )),
          ListTile(
            onTap: () {
              setState(() {
                _currentScreen = 0;
              });
              Navigator.pop(context);
            },
            leading: Icon(Icons.alarm),
            title: Text('Primeira'),
          ),
          ListTile(
            onTap: () {
              setState(() {
                _currentScreen = 1;
              });
              Navigator.pop(context);
            },
            leading: Icon(Icons.alarm),
            title: Text('Segunda'),
          ),
          ListTile(
            onTap: () {
              setState(() {
                _currentScreen = 2;
              });
              Navigator.pop(context);
            },
            leading: Icon(Icons.alarm),
            title: Text('Terceira'),
          )
        ]),
      ),
    );
  }
}
