import 'package:demo_flutter_app/CalendarScreen.dart';
import 'package:demo_flutter_app/DbOperations.dart';
import 'package:demo_flutter_app/Note.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toast/toast.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primaryColor: Colors.green,
        primaryColorDark: Colors.transparent,
        fontFamily: 'Montserrat',

        /*primaryTextTheme: TextTheme(
          title: TextStyle(
            color: Colors.yellow,
          ),
        ),*/
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbOperationsObj = DbOperations();

  bool isVisible = true;
  String alertMsg = "";
  String errorMsgInsert = "Some error occurred while running the operation.";
  String titleTextFieldValue = "";
  String titleTextFieldValueDialog = "";
  String editContent = "Edit Content";
  String desTextFieldValue = "";
  String desTextFieldValueDialog = "";
  List<Note> noteList = List();
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  TextEditingController textFieldControllerTitle, textFieldControllerDes;
  TextEditingController textFieldControllerTitleDialogUpdate,
      textFieldControllerDesDialogUpdate;

  Future _getInsertedNoteList() async {
    noteList.clear();
    int rowCount = await dbOperationsObj.queryRowCount();
    print("_getInsertedNoteList...row count: " + rowCount.toString());
    if (rowCount > 0) {
      final allRows = await dbOperationsObj.getAllRows();
      allRows.forEach((row) {
        Note note = Note(
            row[DbOperations.columnId].toString(),
            row[DbOperations.columnTitle],
            row[DbOperations.columnDescription],
            row[DbOperations.columnTimestamp]);
        //  note.timestamp = row[DbOperations.columnTimestamp];
        noteList.add(note);
      });
    }
    //  print("_getInsertedNoteList...noteList size: " + noteList.length.toString());
    setState(() {
      //
    });
  }

  Future _addNote(String title, String des, String timestamp) async {
    Note note = Note(DateTime.now().millisecondsSinceEpoch.toString(), title,
        des, timestamp);
    //   note.timestamp = timestamp;
    var insertStatus = await dbOperationsObj.saveNote(note); // insert operation to Db
    print("_addNote : " + insertStatus.toString());
    if (insertStatus > 0) {
      _getInsertedNoteList();
      Toast.show(alertMsg, context, gravity: Toast.BOTTOM);
    } else {
      Toast.show(errorMsgInsert, context, gravity: Toast.BOTTOM);
    }
  }

  void _changeVisibility() {
    setState(() {
      if (titleTextFieldValue.trim().length > 0 ||
          desTextFieldValue.trim().length > 0) {
        alertMsg = "Saved Successfully";
        var formatter = new DateFormat('yyyy-MM-dd HH:mm:ss');
        _addNote(titleTextFieldValue, desTextFieldValue, formatter.format(DateTime.now()));
      } else if (titleTextFieldValue.trim().length == 0) {
        alertMsg = "Please enter some title";
      } else if (desTextFieldValue.trim().length > 0) {
        alertMsg = "Please add some description";
      }
      titleTextFieldValue = "";
      desTextFieldValue = "";
      isVisible = !isVisible;
    });
  }

  TextField createTextField(
      dynamic maxLength,
      TextEditingController textFieldController,
      String hintText,
      String text,
      bool isCounterTextEnable,
      bool enableStatus,
      int lineNumber,
      bool isFromDialog) {
    textFieldController.text = text;

    return TextField(
      textCapitalization: TextCapitalization.sentences,
      controller: textFieldController,
      autofocus: !isVisible,
      keyboardType: TextInputType.multiline,
      maxLength: maxLength,
      maxLines: lineNumber,
      enabled: enableStatus,

      /*onChanged: (value){
        print("createTextField: onChanged: "+value);
        if(isFromDialog){
          textFieldController.text = value;
        }
      },*/
      decoration: isCounterTextEnable
          ? InputDecoration.collapsed(
              hintText: hintText,
              hasFloatingPlaceholder: true,
            )
          : InputDecoration(
              counterText: "", hintText: hintText, border: InputBorder.none),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    /* Fetching textField value */
    textFieldControllerTitle = TextEditingController();
    textFieldControllerTitle.addListener(() {
      print("textFieldControllerTitle..." + textFieldControllerTitle.text);
      titleTextFieldValue = textFieldControllerTitle.text;
    });
    textFieldControllerDes = TextEditingController();
    textFieldControllerDes.addListener(() {
      print("textFieldControllerDes..." + textFieldControllerDes.text);
      desTextFieldValue = textFieldControllerDes.text;
    });

    textFieldControllerTitleDialogUpdate = TextEditingController();
    textFieldControllerTitleDialogUpdate.addListener(() {
      print("textFieldControllerTitleDialogUpdate..." +
          textFieldControllerTitleDialogUpdate.text);
      titleTextFieldValueDialog = textFieldControllerTitleDialogUpdate.text;
    });
    textFieldControllerDesDialogUpdate = TextEditingController();
    textFieldControllerDesDialogUpdate.addListener(() {
      print("textFieldControllerDesDialogUpdate..." +
          textFieldControllerDesDialogUpdate.text);
      desTextFieldValueDialog = textFieldControllerDesDialogUpdate.text;
    });
    super.initState();
    print("initState...");
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    print("dispose...");
    dbOperationsObj.closeDb();
  }

  @override
  Widget build(BuildContext context) {
    print("build...");

    /* Making list items */
    List<Widget> drawerItems = [];

    if (noteList.length == 0) {
      drawerItems.add(ListTile(
        leading: Icon(Icons.adb),
        title: Text(
          "Oops!",
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
        ),
        subtitle: Text("No data available"),
        /*selected: i == _selectedIndex,
        onTap: () => _onSelectItem(i),*/
      ));
    } else {
      for (var i = 0; i < noteList.length; i++) {
        var noteItem = noteList[i];
        drawerItems.add(ListTile(
          leading: Icon(Icons.adb),
          trailing: IconButton(
              icon: Icon(Icons.delete_outline),
              onPressed: () {
                showAlert("Delete Item!", "Are you sure?", i);
              }),
          title: Text(
            noteItem.title,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w400),
          ),
          subtitle: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  noteItem.description,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  noteItem.timestamp,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          onTap: () {
            openDialog(context, i);
          },
          /*selected: i == _selectedIndex,
        onTap: () => _onSelectItem(i),*/
        ));
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      // resizeToAvoidBottomPadding: false,
       resizeToAvoidBottomInset: false,
      drawer: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              UserAccountsDrawerHeader(
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    "S",
                    style: TextStyle(
                        //fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                        color: Colors.green),
                  ),
                ),
                accountName: Text("Sankha Ghosh"),
                accountEmail: Text("ghoshsankha1@gmail.com"),
              ),
              Column(
                children: drawerItems,
              ),
            ],
          ),
        ),
      ),

      backgroundColor: Colors.white,

      appBar: PreferredSize(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(
                child: Card(
                  margin: EdgeInsets.all(20),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(4, 4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          _getInsertedNoteList();
                          _scaffoldKey.currentState.openDrawer();
                        },
                      ),
                      Expanded(
                        child: Text(widget.title),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CalendarScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          preferredSize: Size(100, 100)),

      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              createTextField(100, textFieldControllerTitle, "Give a title...",
                  titleTextFieldValue, true, !isVisible, 5, false),
              Divider(
                color: Colors.grey,
              ),
              createTextField(
                  500,
                  textFieldControllerDes,
                  "Describe briefly...",
                  desTextFieldValue,
                  false,
                  !isVisible,
                  10,
                  false),
            ],
          )),

      floatingActionButton: FloatingActionButton(
        onPressed: _changeVisibility,
        backgroundColor: Colors.greenAccent,
        //  tooltip: 'Increment',
        child: Icon(
          isVisible ? Icons.add : Icons.check,
          color: Colors.white,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void openDialog(BuildContext context, int position) {
    Dialog dialog = Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        height: MediaQuery.of(context).size.height,
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10),
              child: Text(
                editContent,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              color: Colors.grey,
            ),
            createTextField(100, textFieldControllerTitleDialogUpdate, "",
                noteList[position].title, true, true, 5, true),
            Divider(
              color: Colors.grey,
            ),
            Expanded(
              child: Container(
                //   width: MediaQuery.of(context).size.height,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    createTextField(500, textFieldControllerDesDialogUpdate, "",
                        noteList[position].description, false, true, 10, true)
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                onPressed: () {
                  _updateNote(noteList[position].id);
                  Navigator.of(context).pop();
                },
                color: Colors.white,
                splashColor: Colors.white,
                disabledColor: Colors.white,
                child: Text(
                  "Update".toUpperCase(),
                  style: TextStyle(color: Colors.grey),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.elliptical(5, 5)),
                    side: BorderSide(width: 1, color: Colors.grey)),
              ),
            )
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (context) => dialog);
  }

  _updateNote(String id) async {
    var note = Note(
        DateTime.now().millisecondsSinceEpoch.toString(),
        titleTextFieldValueDialog,
        desTextFieldValueDialog,
        DateTime.now().toString());
    //  note.timestamp = DateTime.now().toString();
    int updateStatus = await dbOperationsObj.updateNote(note, id);
    if (updateStatus > 0) {
      alertMsg = "Saved Successfully";
      Toast.show(alertMsg, context, gravity: Toast.BOTTOM);
      _getInsertedNoteList();
      return;
    }
    Toast.show(errorMsgInsert, context, gravity: Toast.BOTTOM);
  }

  _deleteItem(int position) async {
    int deleteStatus = await dbOperationsObj.deleteNote(noteList[position].id);
    if (deleteStatus > 0) {
      alertMsg = "Deleted Successfully";
      Toast.show(alertMsg, context, gravity: Toast.BOTTOM);
      _getInsertedNoteList();
      return;
    }
    Toast.show(errorMsgInsert, context, gravity: Toast.BOTTOM);
  }

  void showAlert(String title, String description, int pos) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            elevation: 5,
            title: Text(title),
            content: Text(description),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  _deleteItem(pos);
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text("No"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
