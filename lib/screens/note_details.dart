import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pad_keeper/models/note_model.dart';
import 'package:pad_keeper/utils/database_helper.dart';

class NoteDetail extends StatefulWidget {
  final String title;
  final Note note;

  NoteDetail({this.title, this.note});

  @override
  _NoteDetailState createState() => _NoteDetailState();
}

class _NoteDetailState extends State<NoteDetail> {
  var _priority = ["High", "Low"];
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    TextStyle txtStyle = Theme.of(context).textTheme.subtitle1;

    //set initial value
    titleController.text = widget.note.title;
    descriptionController.text = widget.note.description;

    return WillPopScope(
      //used to handle physical back button
      onWillPop: () {
        navigatePopBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: ListView(
            children: [
              ListTile(
                title: DropdownButton(
                  items: _priority.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  style: txtStyle,
                  value: getPriorityFromDb(widget.note.priority),
                  onChanged: (value) {
                    setState(() {
                      savePriorityToDb(value);
                    });
                  },
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: titleController,
                onChanged: (value) {
                  updateTitle();
                },
                decoration: InputDecoration(
                  labelText: "Title",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 1)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descriptionController,
                onChanged: (value) {
                  updateDescription();
                },
                decoration: InputDecoration(
                  labelText: "Description",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 1)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 1)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Expanded(
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Save",
                          textScaleFactor: 1.5,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          _save();
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: RaisedButton(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Delete",
                          textScaleFactor: 1.5,
                        ),
                      ),
                      color: Theme.of(context).primaryColor,
                      textColor: Theme.of(context).primaryColorLight,
                      onPressed: () {
                        setState(() {
                          _delete();
                        });
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  navigatePopBack() {
    Navigator.pop(context);
  }

  //saving priority to database
  void savePriorityToDb(String value) {
    switch (value) {
      case 'High':
        widget.note.priority = 1;
        break;
      case 'Low':
        widget.note.priority = 2;
        break;
    }
  }

//getting priority from database and display to dropdown
  String getPriorityFromDb(int value) {
    String result;
    switch (value) {
      case 1:
        result = _priority[0];
        break;
      case 2:
        result = _priority[1];
        break;
    }
    return result;
  }

  void updateTitle() {
    widget.note.title = titleController.text;
  }

  void updateDescription() {
    widget.note.description = descriptionController.text;
  }

  void _save() async {
    movetoLastScreen();

    widget.note.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (widget.note.id != null) {
      //update
      result = await databaseHelper.updateNote(widget.note);
    } else {
      //insert
      print("Note value: "+widget.note.noteToMap().toString());
      result = await databaseHelper.insertNote(widget.note);
    }
    if (result != 0) {
      _showDialog('Status', 'Note saved successfully');
    } else {
      _showDialog('Status', 'Problem saving note');
    }
  }

  void _delete() async {
    movetoLastScreen();

    if (widget.note.id == null) {
      _showDialog("Status", "No note was deleted");
      return;
    }

    int result = await databaseHelper.deleteNote(widget.note.id);
    if (result != 0) {
      _showDialog('Status', 'Note deleted successfully');
    } else {
      _showDialog('Status', 'Problem to delete note');
    }
  }

  void _showDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (context) => alertDialog);
  }

  void movetoLastScreen() {
    Navigator.pop(context, true);    //pass bool value as parameter to ensure noteList updated
  }
}
