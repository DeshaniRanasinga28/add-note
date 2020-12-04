import 'package:addnotes/helper/db_helper.dart';
import 'package:addnotes/model/note.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  Future<List<Note>> notes;
  int id;
  String title;
  String description;


  final formKey = new GlobalKey<FormState>();
  var dbHelper;
  bool isUpdating;

  TextEditingController _editTitleController = TextEditingController();
  TextEditingController _editDescriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    isUpdating = false;

  }

  refreshList(){
    setState(() {
      notes = dbHelper.getAllNotes();
    });
  }

  clearName() {
    _editTitleController.text = '';
    _editDescriptionController.text = '';
  }

  validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      if (isUpdating) {
        Note e = Note( id, title, description);
        dbHelper.update(e);
        setState(() {
          isUpdating = false;
        });
      } else {
        Note e = Note(null, title, description);
        dbHelper.save(e);
      }
      clearName();
      refreshList();
    }
  }

  form() {
    return Form(
      key: formKey,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          verticalDirection: VerticalDirection.down,
          children: <Widget>[
            TextFormField(
              controller: _editTitleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Title'),
              validator: (val) => val.length == 0 ? 'Enter The Title' : null,
              onSaved: (val) => title = val,
            ),
            TextFormField(
              controller: _editDescriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(labelText: 'Description'),
              validator: (val) => val.length == 0 ? 'Enter The Description' : null,
              onSaved: (val) => description = val,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    child: RaisedButton(
                      onPressed: validate,
                      child: Text(isUpdating ? 'UPDATE' : 'ADD'),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    child: RaisedButton(
                      onPressed: () {
                        setState(() {
                          isUpdating = false;
                        });
                        clearName();
                      },
                      child: Text('CLEAR'),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  SingleChildScrollView dataTable(List<Note> notes) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        columns: [
          DataColumn(
            label: Text('Title'),
          ),
          DataColumn(
            label: Text('Description'),
          ),
          DataColumn(
            label: Text(''),
          )
        ],
        rows: notes.map((note) => DataRow(
            cells: [
            DataCell(
              Text(note.title),
              onTap: () {
                setState(() {
                  isUpdating = true;
                  id = note.id;
                });
                _editTitleController.text = note.title;
              },
            ),
              DataCell(
                Text(note.description),
                onTap: () {
                  setState(() {
                    isUpdating = true;
                    id = note.id;
                  });
                  _editTitleController.text = note.title;
                },
              ),
            DataCell(IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                dbHelper.delete(note.id);
                refreshList();
              },
            )),
          ]),
        )
            .toList(),
      ),
    );
  }

  list() {
    return Expanded(
      child: FutureBuilder(
        future: notes,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return dataTable(snapshot.data);
          }
          if (null == snapshot.data || snapshot.data.length == 0) {
            return Text("No Data Found");
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Note"),
        ),
      body: Stack(
        children: [
          Column(
            children: [
              form(),
              list()
            ],
          ),
        ],
      )
    );
  }



}
