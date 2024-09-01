import 'package:aula04_layout_e_textformfield/view/layout/my_bottom_navigation_bar.dart';
import 'package:aula04_layout_e_textformfield/view/layout/my_navigation_drawer.dart';
import 'package:aula04_layout_e_textformfield/view/layout/my_tab_layout.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  static const String _title = 'Flutter Stateful Clicker Counter';
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        // useMaterial3: false,
        primarySwatch: Colors.blue,
      ),
      //home: MyTabLayout(),
      home: MyNavigationDrawer(),
    );
  }
}
