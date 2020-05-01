import 'package:demo_flutter_app/Note.dart';
import 'package:flutter/material.dart';
import 'package:date_utils/date_utils.dart';
import 'package:flutter_calendar/flutter_calendar.dart';
import 'package:toast/toast.dart';

void main() => runApp(
      MaterialApp(home: CalendarScreen()),
    );

class CalendarScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Calendar View",
          style: TextStyle(color: Colors.grey),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.grey,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Divider(
              color: Colors.grey,
            ),
            ListItems(),
          ],
        ),
      )
    );
  }
}

class ListItems extends StatefulWidget {
  ListItems({Key key}) : super(key: key);

  @override
  _ListItemsState createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {
  List<Note> noteList = List();

  void addNote(String title, String des, String timestamp) {
    setState(() {
      Note note = Note(DateTime.now().millisecondsSinceEpoch.toString(), title, des, timestamp);
    //  note.timestamp = timestamp;
      noteList.add(note);
      print("CalendarScreen_NotelistSize: " + noteList.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {

    /* Making list items */
    List<Widget> listItems = [];

    if (noteList != null && noteList.length > 0) {
      for (var i = 0; i < noteList.length; i++) {
        var noteItem = noteList[i];
        listItems.add(ListTile(
          leading: Icon(Icons.adb),
          title: Text(
            noteItem.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
          ),
          subtitle: Text(
            noteItem.description,
          ),
          /*selected: i == _selectedIndex,
        onTap: () => _onSelectItem(i),*/
        ));
      }
    } else {
      listItems.add(Text("No data available"));
    }

    // TODO: implement build
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.all(10),
          child: Calendar(

            onDateSelected: (date) => {
                  Toast.show(
                      "Selected date: " +
                          date.day.toString() +
                          "/" +
                          date.month.toString() +
                          "/" +
                          date.year.toString(),
                      context,
                      gravity: Toast.BOTTOM),
                  addNote(
                      "Selected date",
                      date.day.toString() +
                          "/" +
                          date.month.toString() +
                          "/" +
                          date.year.toString(),
                      DateTime.now().toString()),
                },
            //  initialCalendarDateOverride: DateTime.now(),
            showCalendarPickerIcon: false,
            showTodayAction: false,
            isExpandable: true,

          ),
        ),
        Column(
          children: listItems,
        )
      ],
    );
  }
}
