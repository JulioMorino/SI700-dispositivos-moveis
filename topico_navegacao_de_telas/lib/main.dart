import 'package:flutter/material.dart';
import 'app_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formulários - Aula 13',
      theme: ThemeData(primarySwatch: Colors.blue),
      onGenerateRoute: _appRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
