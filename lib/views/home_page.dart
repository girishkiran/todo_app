import 'package:flutter/material.dart';
import 'package:todo_app/views/task_list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text('TODO'),
          centerTitle: true,
        ),
        body: const TaskListScreen(),
      ),
    );
  }
}
