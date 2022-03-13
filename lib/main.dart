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
  runApp(MaterialApp(home: App()));
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
              title: Text("Café"),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    child: Icon(Icons.add),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddLog()),
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
                                      var uuid = Uuid();
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        CreateDatabase.instance.remove(log.id!);
                                      });
                                    },
                                    leading: Icon(Icons.local_drink),
                                    title: Text(log.title)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: <Widget>[
                                    TextButton(
                                      // aftrekken van Count (per log)
                                      child: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          int index = snapshot.data!.indexWhere(
                                              (x) => x.id == log.id);
                                          Log editLog = snapshot.data!
                                              .firstWhere(
                                                  (x) => x.id == log.id);
                                          Log l = Log(
                                              id: log.id,
                                              title: editLog.title,
                                              date: editLog.date);
                                          CreateDatabase.instance.update(l);
                                        });
                                      },
                                    ),
                                    Text("test"), // aantal
                                  ],
                                ),
                              ])));
                        }).toList(),
                      );
                    }
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                print("floating action button clicked");
              },
            )));
  }

  bool onlyUnique(value, index, self) {
    return self.indexOf(value) == index;
  }

  FutureOr onGoBack(dynamic value) {
    // update list after you add a product
    ListOfLogs();
    setState() {}
    ;
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
    (await db.query('sqlite_master', columns: ['type', 'name'])).forEach((row) {
      print(row.values);
    });
  }

  Future<List<Log>> GetLogs() async {
    Database db = await instance.database;
    var logs = await db.query('logs');
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

class AddLog extends StatelessWidget {
  const AddLog({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final title = TextEditingController();
    final date = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voeg klacht toe'),
      ),
      body: Column(
        children: <Widget>[
          TextFormField(
            controller: title,
            decoration: const InputDecoration(
              icon: const Icon(Icons.local_drink),
              hintText: 'Klacht',
              labelText: 'Klacht',
            ),
          ),
          TextFormField(
            controller: date,
            decoration: const InputDecoration(
              icon: const Icon(Icons.calendar_today),
              hintText: 'Datum',
              labelText: 'Datum',
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              var uuid = Uuid();
              if (title.text != null && date.text != null) {
                await CreateDatabase.instance.add(Log(
                  id: uuid.v4(),
                  title: title.text,
                  date: DateTime.now().toString(),
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
      ),
    );
  }
}
