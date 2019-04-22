import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'package:path/path.dart';
import '../router/routes.dart';
import 'package:sqflite/sqflite.dart';

class AppComponent extends StatefulWidget {
  @override
  State createState() {
    return new AppComponentState();
  }
}

class Application {
  static Router router;
}

class AppComponentState extends State<AppComponent> {
  static bool debugMode = false;
  
  AppComponentState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  createDatabase() async {
    String databasesPath = await getDatabasesPath();
    String dbPath = join(databasesPath, 'my.db');

    var database = await openDatabase(dbPath, version: 1, onCreate: populateDb);
    return database;
  }

  void populateDb(Database database, int version) async {
    await database.execute("CREATE TABLE Balance ("
      "id INTEGER PRIMARY KEY,"
      "account TEXT,"
      "balance TEXT,"
      "timestamp TEXT,"
      "signature TEXT,"
      "datecreated TEXT"
      ")");

    await database.execute("CREATE TABLE OfflineTransaction ("
      "id INTEGER PRIMARY KEY,"
      "timestamp TEXT,"
      "signature TEXT,"
      ")");
  }

  @override
  Widget build(BuildContext context) {
    createDatabase();
    final app = new MaterialApp(
      title: 'Paytaca',
      debugShowCheckedModeBanner: debugMode,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      onGenerateRoute: Application.router.generator,
    );
    return app;
  }

  getDatabasesPath() {}
}
