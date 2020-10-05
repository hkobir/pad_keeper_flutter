import 'package:flutter/material.dart';
import 'package:pad_keeper/screens/note_list.dart';
main()=>runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NoteList(),
    );
  }
}
