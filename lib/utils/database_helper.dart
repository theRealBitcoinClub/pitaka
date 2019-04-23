// import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
// import 'package:pitaka/model/balance.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database

  // String noteTable = 'note_table';
	// String colId = 'id';
	// String colTitle = 'title';
	// String colDescription = 'description';
	// String colPriority = 'priority';
	// String colDate = 'date';

	DatabaseHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

	factory DatabaseHelper() {

		if (_databaseHelper == null) {
			_databaseHelper = DatabaseHelper._createInstance(); // This is executed only once, singleton object
		}
		return _databaseHelper;
	}

	Future<Database> get database async {

		if (_database == null) {
			_database = await initializeDatabase();
		}
		return _database;
	}

	Future<Database> initializeDatabase() async {
		// Get the directory path for both Android and iOS to store database.
		Directory directory = await getApplicationDocumentsDirectory();
		String path = directory.path + 'local.db';

		// Open/create the database at a given path
		var pitakaDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
		return pitakaDatabase;
	}


	void _createDb(Database db, int newVersion) async {
    await db.execute("CREATE TABLE Balance ("
      "id INTEGER PRIMARY KEY,"
      "account TEXT,"
      "balance TEXT,"
      "timestamp TEXT,"
      "signature TEXT,"
      "datecreated TEXT"
      ")");

    await db.execute("CREATE TABLE OfflineTransaction ("
      "id INTEGER PRIMARY KEY,"
      "amount DOUBLE(40,2),"
      "timestamp TEXT,"
      "transactionType TEXT,"
      "transactionJson TEXT"
      ")");
	}

	// Get latest balance of balance objects in database
	Future<int> getLatestBalance() async {
		Database db = await this.database;
		List<Map<String, dynamic>> bal = await db.rawQuery('SELECT balance from balance limit 1');
		int result = Sqflite.firstIntValue(bal);
		return result;
	}

}