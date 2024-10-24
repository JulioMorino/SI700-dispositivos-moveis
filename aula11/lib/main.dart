import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'bloc/auth_bloc.dart';

import 'bloc/manage_bloc.dart';

import 'view/add_note.dart';
import 'view/list_note.dart';
import 'view/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
            apiKey: "AIzaSyBd3dtva1HexybyOgj2gAiyef0f3yjuj-8",
  authDomain: "aula09-notes.firebaseapp.com",
  databaseURL: "https://aula09-notes-default-rtdb.firebaseio.com",
  projectId: "aula09-notes",
  storageBucket: "aula09-notes.appspot.com",
  messagingSenderId: "446234767943",
  appId: "1:446234767943:web:b093725737f9456966f762"
  
  
  ));
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            return ManageBloc(InsertState(noteList: []))
              ..add(
                GetNoteListEvent(),
              );
          },
        ),
        BlocProvider(
          create: (context) {
            return AuthBloc();
          },
        )
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const Wrapper(),
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
      body: const Center(child: ListNoteScreen()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          BlocProvider.of<ManageBloc>(context).add(UpdateCancel());
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => AddNoteScreen()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
