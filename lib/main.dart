import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'models/log.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        listTileTheme: ListTileThemeData(tileColor: Colors.orange[100]),
        // Define the default brightness and colors.
        brightness: Brightness.dark,
        primaryColor: Colors.orange[800],

        // Define the default font family.
        fontFamily: 'Georgia',
        backgroundColor: Colors.orange,
        primaryColorLight: Colors.yellow,
        // Define the default `TextTheme`. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: const TextTheme(
          headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [Locale('es', '')],
      home: App()));
  WidgetsFlutterBinding.ensureInitialized();
}

class App extends StatefulWidget {
  // first page
  const App({Key? key}) : super(key: key);

  @override
//  CreateChart createState() => CreateChart();
  ListOfLogs createState() => ListOfLogs();
}

/*class CreateChart extends State<App> {
  TooltipBehavior _tooltip = TooltipBehavior(enable: true);
  List<Log> logs = [
    Log(
        title: "Test1",
        date: new DateTime.now().add(const Duration(days: 1)).toString()),
    Log(
        title: "Test2",
        date: new DateTime.now()
            .add(const Duration(days: 2, hours: 1))
            .toString()),
    Log(
        title: "Test3",
        date: new DateTime.now()
            .add(const Duration(days: 3, hours: 2))
            .toString()),
    Log(
        title: "Test4",
        date: new DateTime.now()
            .add(const Duration(days: 4, hours: 3))
            .toString()),
    Log(
        title: "Test5",
        date: new DateTime.now()
            .add(const Duration(days: 5, hours: 4))
            .toString())
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 400,
        height: 400,
        child: Scaffold(
            body: SfCartesianChart(
          title: ChartTitle(text: 'Data'),
          legend: Legend(isVisible: true),
          tooltipBehavior: _tooltip,
          series: <ChartSeries>[
            LineSeries<Log, int>(
                dataSource: logs,
                xValueMapper: (Log l, _) => DateTime.parse(l.date).day,
                yValueMapper: (Log l, _) => DateTime.parse(l.date).hour,
                dataLabelSettings: DataLabelSettings(isVisible: true),
                enableTooltip: true),
          ],
          primaryXAxis:
              NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
          primaryYAxis:
              NumericAxis(edgeLabelPlacement: EdgeLabelPlacement.shift),
        )));
  }
}
*/

class ListOfLogs extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text("Logs"),
              actions: <Widget>[
                Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    child: Icon(Icons.add),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddOrEditLogWidget(
                                  log: Log(
                                      id: "",
                                      date: DateTime.now().toString(),
                                      title: ""),
                                )),
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
                      return ListTileTheme(
                          tileColor: Colors.yellow,
                          child: ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            children: snapshot.data!.map((log) {
                              return Center(
                                  child: Card(
                                      child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Slidable(
                                      key: const ValueKey(0),
                                      endActionPane: ActionPane(
                                        motion: const ScrollMotion(),
                                        children: [
                                          SlidableAction(
                                            onPressed: ((context) => {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddOrEditLogWidget(
                                                                log: log)),
                                                  ).then(onGoBack)
                                                }),
                                            backgroundColor:
                                                const Color(0xFFFF7435),
                                            foregroundColor: Colors.white,
                                            icon: Icons.edit,
                                            label: 'Wijzig',
                                          ),
                                          SlidableAction(
                                            onPressed: ((context) => {
                                                  showDialog<String>(
                                                      context: context,
                                                      builder:
                                                          (BuildContext
                                                                  context) =>
                                                              AlertDialog(
                                                                  title: Text(
                                                                      "Zeker dat je ${log.title} wil verwijderen?"),
                                                                  actions: <
                                                                      Widget>[
                                                                    TextButton(
                                                                        onPressed: () => Navigator.pop(
                                                                            context,
                                                                            "Nee"),
                                                                        child: const Text(
                                                                            "Nee",
                                                                            style:
                                                                                TextStyle(fontSize: 16.0))),
                                                                    TextButton(
                                                                        child: const Text(
                                                                            "Ja",
                                                                            style: TextStyle(
                                                                                fontSize:
                                                                                    16.0)),
                                                                        onPressed:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            Future<int>
                                                                                removed =
                                                                                CreateDatabase.instance.remove(log.id);
                                                                            if (removed !=
                                                                                null) {
                                                                              Navigator.pop(context);
                                                                            }
                                                                          });
                                                                        })
                                                                  ]))
                                                }),
                                            backgroundColor:
                                                const Color(0xFFFE4A49),
                                            foregroundColor: Colors.white,
                                            icon: Icons.delete,
                                            label: 'Verwijder',
                                          ),
                                        ],
                                      ),
                                      child: ListTile(
                                        style: Theme.of(context)
                                            .listTileTheme
                                            .style,
                                        leading: Icon(Icons.medication),
                                        title: Text(log.title),
                                        subtitle: Text(
                                            "${DateTime.parse(log.date).hour}:${DateTime.parse(log.date).minute < 10 ? "0${DateTime.parse(log.date).minute}" : "${DateTime.parse(log.date).minute}"} \t ${DateTime.parse(log.date).day}/${DateTime.parse(log.date).month}/${DateTime.parse(log.date).year}"),
                                      ))
                                ],
                              )));
                            }).toList(),
                          ));
                    }
                  }),
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.deepOrange,
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
    setState(() => {ListOfLogs()});
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

class AddOrEditLogWidget extends StatefulWidget {
  AddOrEditLogWidget({Key? key, required this.log}) : super(key: key);
  Log log;
  @override
  AddOrEditLog createState() => AddOrEditLog(log);
}

class AddOrEditLog extends State<AddOrEditLogWidget> {
  final title = TextEditingController();
  Log? log;
  bool validation = false;
  DateTime pickedDate = DateTime.now();
  TimeOfDay pickedTime =
      TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute);

  AddOrEditLog(Log log) {
    if (log.id.isNotEmpty) {
      pickedDate = DateTime.parse(log.date);
      pickedTime = TimeOfDay(hour: pickedDate.hour, minute: pickedDate.minute);
      title.text = log.title;
    } else {
      title.text = "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: widget.log.id.isEmpty
                ? const Text('Voeg klacht toe')
                : const Text('Wijzig klacht'),
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context)),
          ),
          body: Column(
            children: <Widget>[
              TextFormField(
                controller: title,
                decoration: InputDecoration(
                    icon: const Icon(Icons.local_drink),
                    hintText: 'Klacht',
                    labelText: 'Klacht',
                    errorText: validation ? "Vul een klacht in" : null),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16.0)),
                    child: const Text("Kies datum"),
                    onPressed: () async {
                      showDatePicker(
                              context: context,
                              initialDate: pickedDate,
                              firstDate: DateTime(DateTime.now().year - 20),
                              lastDate: DateTime(DateTime.now().year + 10))
                          .then((date) {
                        setState(() {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (date == null) {
                            return;
                          } else {
                            pickedDate = date;
                            pickedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute);
                          }
                        });
                      });
                    }),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.50,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        primary: Colors.white,
                        textStyle: const TextStyle(fontSize: 16.0)),
                    child: const Text("Kies uur"),
                    onPressed: () async {
                      showTimePicker(
                        context: context,
                        initialTime: pickedTime,
                      ).then((time) {
                        setState(() {
                          FocusManager.instance.primaryFocus?.unfocus();
                          if (time == null) {
                            return;
                          } else {
                            pickedTime = time;
                            pickedDate = DateTime(
                                pickedDate.year,
                                pickedDate.month,
                                pickedDate.day,
                                pickedTime.hour,
                                pickedTime.minute);
                          }
                          ;
                          print(time);
                        });
                      });
                    }),
              ),
              Container(
                margin: const EdgeInsets.all(3),
                child: Text(
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year} \t ${pickedTime.hour}:${pickedTime.minute < 10 ? "0" + pickedTime.minute.toString() : pickedTime.minute}",
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  var uuid = Uuid();
                  if (title.text.isNotEmpty) {
                    if (widget.log.id.isNotEmpty) {
                      await CreateDatabase.instance.update(Log(
                          id: widget.log.id,
                          title: title.text,
                          date: pickedDate.toString()));
                    } else {
                      await CreateDatabase.instance.add(Log(
                        id: uuid.v4(),
                        title: title.text,
                        date: pickedDate.toString(),
                      ));
                    }
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      validation = true;
                    });
                  }
                },
                child: widget.log.id.isEmpty
                    ? const Text('Voeg toe')
                    : const Text('Wijzig'),
              ),
            ],
          )),
    );
  }
}
