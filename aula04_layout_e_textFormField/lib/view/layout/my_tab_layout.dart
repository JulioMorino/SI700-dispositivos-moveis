import 'package:aula04_layout_e_textformfield/view/layout/my_navigation_drawer.dart';
import 'package:aula04_layout_e_textformfield/view/screens/primeira_tela.dart';
import 'package:aula04_layout_e_textformfield/view/screens/segunda_tela.dart';
import 'package:aula04_layout_e_textformfield/view/screens/terceira_tela.dart';
import 'package:flutter/material.dart';

class MyTabLayout extends StatelessWidget {
  const MyTabLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
              title: Text('My tab'),
              bottom: TabBar(
                tabs: [
                  Tab(
                    icon: Icon(Icons.call),
                  ),
                  Container(
                    width: 700,
                    padding: EdgeInsets.all(20),
                    color: Colors.green,
                    child: Tab(
                      icon: Icon(Icons.house),
                    ),
                  ),
                  Tab(
                    icon: Icon(Icons.wifi),
                  )
                ],
              )),
          body: TabBarView(
              children: [PrimeiraTela(), SegundaTela(), TerceiraTela()]),
          drawer: MyNavigationDrawer(),
        ));
  }
}
