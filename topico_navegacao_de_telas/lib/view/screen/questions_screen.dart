import 'package:flutter/material.dart';

class QuestionsScreen extends StatefulWidget {
  final List<Widget> children;
  const QuestionsScreen({super.key, required this.children});
  @override
  State<QuestionsScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.children.length,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              for (var i = 1; i <= widget.children.length; i++) Tab(text: "$i")
            ],
          ),
          title: const Text(
              "Aula 13 - Programação para Mobile - Questionários com Navigator"),
        ),
        body: TabBarView(children: widget.children),
      ),
    );
  }
}
