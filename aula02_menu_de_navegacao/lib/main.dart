// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  String current = '';

  @override
  Widget build(BuildContext context) {
    
    
    
    
    
    
    return Scaffold(
      appBar: AppBar(
        
        
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        
        title: Text(widget.title),
      ),
      body: Center(
        
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                
                mainAxisAlignment: MainAxisAlignment.center,
                children: getChildren(rotulos: ["a", "b", "c", 1, 2, 3, 4, 5, 6]),
              ),
            ),
            Text(current)
          ],
        ),
      ),
       
    );
  }

  List<Widget> getChildren({@required rotulos}){
    List<Widget> children = [];
    rotulos.forEach((child){
      children.add(TextButton(
                    onPressed: (){
                      setState(() {
                        current = child.toString();
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      height: 60,
                      width:  60,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Color.fromARGB(255, 23, 35, 255)),
                      child: Center(child: Text(child.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30 ),)),
                    ),
      ));
    });
    return children;
  }
}
