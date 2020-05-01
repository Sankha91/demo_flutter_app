import 'package:demo_flutter_app/DbOperations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class Note{
  String _title;
  String _id;
  String _description;
  String _timestamp;

  Note(this._id, this._title, this._description, this._timestamp);

  String get title => _title;
 /* set title(String title){
    _title = title;
  }*/

  String get description => _description;
 /* set description(String description){
    _description = description;
  }*/

  String get timestamp => _timestamp;
  /* set timestamp(String timestammp){
     DateTime date = timestamp as DateTime;
     var formatter = new DateFormat('yyyy-MM-dd');
     _timestamp = formatter.format(date);
  }*/


  String get id => _id;
  /*set timestamp(String timestamp){
    _timestamp = timestamp;
  }*/

  Map<String, dynamic> toMap(){
    var map = Map<String, dynamic>();
    map[DbOperations.columnId] = _id;
    map[DbOperations.columnTitle] = _title;
    map[DbOperations.columnDescription] = _description;
    map[DbOperations.columnTimestamp] = _timestamp;
    return map;
  }
}