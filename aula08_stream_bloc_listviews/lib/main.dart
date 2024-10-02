import 'package:aula08_stream_bloc_listviews/bloc/manage_bloc.dart';
import 'package:aula08_stream_bloc_listviews/view/add_note.dart';
import 'package:aula08_stream_bloc_listviews/view/list_note.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) {
        return ManageBloc(InsertState(noteList: []))..add(GetNoteListEvent());
      },
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: const Center(
        child: ListNote(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<ManageBloc>(context).add(
              UpdateCancel()); //garante que estarei no estado de Insert quando clicar em adicionar
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNote()),
          );
        },
        tooltip: 'Inserir no Banco',
        child: const Icon(Icons.add),
      ),
    );
  }
}
