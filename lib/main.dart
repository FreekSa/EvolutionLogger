import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'models/log.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(home: App()));
  WidgetsFlutterBinding.ensureInitialized();
}

class App extends StatefulWidget {
  // first page
  const App({Key? key}) : super(key: key);

  @override
  ListOfLogs createState() => ListOfLogs();
}

class ListOfLogs extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: Text("Logs"),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    child: Icon(Icons.add),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddLogWidget()),
                      ).then(onGoBack);
                    },
                  ),
                )
              ],
            ), // naam van het log om toe te voegen
            body: Center(
              child: FutureBuilder<List<Log>>(
                  future: CreateDatabase.instance.GetLogs(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Log>> snapshot) {
                    if (snapshot.data == null) {
                      return Center(child: Text('No logs in List.'));
                    } else {
                      List<Log> logs = snapshot.data!.toList();
                      return ListView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: snapshot.data!.map((log) {
                          return Center(
                              child: Card(
                                  child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              ListTile(
                                onTap: () async {
                                  print(log.id);
                                },
                                onLongPress: () {
                                  setState(() {
                                    CreateDatabase.instance.remove(log.id!);
                                  });
                                },
                                leading: Icon(Icons.medication),
                                title: Text(log.title),
                                subtitle: Text(
                                    "${DateTime.parse(log.date).hour}:${DateTime.parse(log.date).minute < 10 ? "0${DateTime.parse(log.date).minute}" : "${DateTime.parse(log.date).minute}"} \t ${DateTime.parse(log.date).day}/${DateTime.parse(log.date).month}/${DateTime.parse(log.date).year}"),
                              )
                            ],
                          )));
                        }).toList(),
                      );
                    }
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.circle),
              onPressed: () => {
                setState(() => {ListOfLogs()})
              },
            )));
  }

  bool onlyUnique(value, index, self) {
    return self.indexOf(value) == index;
  }

  FutureOr onGoBack(dynamic value) {
    // update list after you add a product
    setState() {
      ListOfLogs();
    }
  }
}

class CreateDatabase {
  CreateDatabase._privateConstructor();
  static final CreateDatabase instance = CreateDatabase._privateConstructor();
  static Database? _database;
  static Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<Database> get database async => _database ??= await _initDatabase();
  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'log.db');
    return await openDatabase(path,
        version: 1, onCreate: _onCreate, onConfigure: _onConfigure);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs(
          id TEXT PRIMARY KEY,
          title TEXT,
          date TEXT
      )
      ''');
  }

  listTables() async {
    Database db = await instance.database;
    (await db.query('sqlite_master', columns: ['type', 'name']))
        .forEach((row) {});
  }

  Future<List<Log>> GetLogs() async {
    Database db = await instance.database;
    var logs = await db.query('logs', orderBy: 'date');
    List<Log> logsList =
        logs.isNotEmpty ? logs.map((c) => Log.fromMap(c)).toList() : [];
    return logsList;
  }

  Future<int> add(Log log) async {
    Database db = await instance.database;
    return await db.insert('logs', log.toMap());
  }

  Future<int> remove(String id) async {
    Database db = await instance.database;
    return await db.delete('logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> update(Log log) async {
    Database db = await instance.database;
    return await db
        .update('logs', log.toMap(), where: "id = ?", whereArgs: [log.id]);
  }
}

class AddLogWidget extends StatefulWidget {
  AddLogWidget({Key? key}) : super(key: key);
  @override
  AddLog createState() => new AddLog();
}

class AddLog extends State<AddLogWidget> {
  DateTime pickedDate = DateTime.now();
  TimeOfDay pickedTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);
  @override
  Widget build(BuildContext context) {
    final title = TextEditingController();
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Voeg klacht toe'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
          ),
          body: Column(
            children: <Widget>[
              Text(pickedDate == null ? "test" : pickedDate.toString()),
              TextButton(
                  // aftrekken van Count (per log)
                  child: const Text("Datum"),
                  onPressed: () async {
                    final initialDate = DateTime.now();
                    showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(DateTime.now().year - 20),
                            lastDate: DateTime(DateTime.now().year + 10))
                        .then((date) {
                      setState(() {
                        if (date == null) {
                          pickedDate = DateTime.now();
                        } else {
                          pickedDate = date as DateTime;
                        }
                        ;
                      });
                    });
                  }),
              TextButton(
                  // aftrekken van Count (per log)
                  child: const Text("Uur"),
                  onPressed: () async {
                    final initialTime = TimeOfDay(
                        hour: DateTime.now().hour,
                        minute: DateTime.now().minute);
                    showTimePicker(
                      context: context,
                      initialTime: initialTime,
                    ).then((time) {
                      setState(() {
                        if (time == null) {
                          pickedTime = TimeOfDay(
                              hour: DateTime.now().hour,
                              minute: DateTime.now().minute);
                        } else {
                          pickedTime = time;
                          pickedDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              time.hour,
                              time.minute);
                        }
                        ;
                      });
                    });
                  }),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  icon: const Icon(Icons.local_drink),
                  hintText: 'Klacht',
                  labelText: 'Klacht',
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var uuid = Uuid();
                  if (title.text != null) {
                    await CreateDatabase.instance.add(Log(
                      id: uuid.v4(),
                      title: title.text,
                      date: pickedDate.toString(),
                    ));
                  } else {
                    print('niet gelukt');
                  }
                  Navigator.pop(context);
                  // Navigate back to first route when tapped.
                },
                child: const Text('Voeg toe'),
              ),
            ],
          )),
    );
  }
}
