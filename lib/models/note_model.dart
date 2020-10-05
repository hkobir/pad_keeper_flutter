class Note {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;

  Note(this._title, this._date, this._priority, [this._description]);

  Note.withId(this._id, this._title, this._date, this._priority,
      [this._description]);

  int get priority => _priority;

  set priority(int value) {
    if (value >= 1 && value <= 2) {
      _priority = value;
    }
  }

  String get date => _date;

  set date(String value) {
    _date = value;
  }

  String get description => _description;

  set description(String value) {
    if (value.length <= 255) {
      _description = value;
    }
  }

  String get title => _title;

  set title(String value) {
    if (value.length <= 255) {
      _title = value;
    }
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }

  //SQFlite deals with only Map object

//convert Note object into map
  Map<String, dynamic> noteToMap() {
    var noteMap = Map<String, dynamic>();
    if (id != null) {
      noteMap['id'] = _id;
    }
    noteMap['title'] = _title;
    noteMap['description'] = _description;
    noteMap['date'] = _date;
    noteMap['priority'] = _priority;
    return noteMap;
  }

//extract Note object from map
Note.mapToNote(Map<String, dynamic> noteMap){
    this._id = noteMap['id'];
    this._title = noteMap['title'];
    this._description = noteMap['description'];
    this._date = noteMap['date'];
    this._priority = noteMap['priority'];

}
}
