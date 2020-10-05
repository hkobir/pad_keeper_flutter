import 'package:flutter/material.dart';
import 'package:pad_keeper/models/note_model.dart';
import 'package:pad_keeper/screens/note_details.dart';
import 'package:pad_keeper/utils/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  _NoteListState createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  int itemsCount = 0;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;

  @override
  Widget build(BuildContext context) {
    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes"),
      ),
      body: getNoteList(),
      floatingActionButton: FloatingActionButton(
        tooltip: "Add note",
        onPressed: () {
          navigateToDetail(Note("", "", 2, ""), "Add Note");
        },
        child: Icon(Icons.add),
      ),
    );
  }

  getNoteList() {
    TextStyle txtStyle = Theme.of(context).textTheme.subtitle1;

    if (itemsCount <= 0) {
      return Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.block,
            color: Colors.grey,
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            "Empty note!",
            style: TextStyle(color: Colors.red),
          )
        ],
      ));
    } else {
      return ListView.builder(
          itemCount: itemsCount,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: getPriorityColor(noteList[index].priority),
                  child: getPriorityIcon(noteList[index].priority),
                ),
                title: Text(
                  noteList[index].title,
                  style: txtStyle,
                ),
                subtitle: Text(noteList[index].date),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _delete(context, noteList[index]);
                  },
                ),
                onTap: () {
                  navigateToDetail(noteList[index], "Edit Note");
                },
              ),
            );
          });
    }
  }

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result = await Navigator.push(
        //get bool result return back from note details to know list updated
        context,
        MaterialPageRoute(
            builder: (context) => NoteDetail(
                  title: title,
                  note: note,
                )));
    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.itemsCount = noteList.length;
        });
      });
    });
  }
}
