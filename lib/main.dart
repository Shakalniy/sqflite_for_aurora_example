import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  List<Map> users = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController valueController = TextEditingController();
  TextEditingController numController = TextEditingController();
  String path = "";

  Future<void> getUsers() async {
    // open db
    print(path);
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
        });

    // Get the records
    List<Map> list = await database.rawQuery('SELECT * FROM Test');
    List<Map> expectedList = [
      {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
      {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
    ];
    print(list);
    // print(expectedList);

    setState(() {
      users = list;
    });

    // Close the database
    await database.close();
  }

  void addUser() async {
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          await db.execute(
              'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
        });

    String name = nameController.text.trim();
    var value = int.parse(valueController.text.trim());
    var num = double.parse(numController.text.trim());
    if (name.isNotEmpty) {
      // Insert some records in a transaction
      await database.transaction((txn) async {
        int id = await txn.rawInsert(
            'INSERT INTO Test(name, value, num) VALUES("$name", $value, $num)');
        print(id);

        // int id1 = await txn.rawInsert(
        //     'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
        // print('inserted1: $id1');
        // int id2 = await txn.rawInsert(
        //     'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
        //     ['another name', 12345678, 3.1416]);
        // print('inserted2: $id2');
      });
    }

    await getUsers();

    // Update some record
    // int count = await database.rawUpdate(
    //     'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    //     ['updated name', '9876', 'some name']);
    // print('updated: $count');

    // Count the records
    // int? count = Sqflite.firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
    // assert(count == 2);
    //
    // Delete a record
    // count = await database.rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
    // assert(count == 1);

    // Close the database
    await database.close();
  }

  void deleteAll() async {
    await deleteDatabase(path);

    await getUsers();
  }

  String getRecord(Map user) {
    return "${user['name']}, ${user['value']}, ${user['num']}";
  }

  void onInit() async {
    var databasesPath = await getDatabasesPath();
    String p = '$databasesPath/demo.db';
    setState(() {
      path = p;
    });
    await getUsers();
  }

  @override
  void initState() {
    onInit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 50,),
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "Enter name"
              ),
            ),
            TextFormField(
              controller: valueController,
              decoration: const InputDecoration(
                  hintText: "Enter value"
              ),
            ),
            TextFormField(
              controller: numController,
              decoration: const InputDecoration(
                  hintText: "Enter num"
              ),
            ),
            for (var user in users)
              Text(getRecord(user))
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FloatingActionButton(
              onPressed: deleteAll,
              child: const Icon(Icons.delete),
            ),
            FloatingActionButton(
              onPressed: addUser,
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }
}
