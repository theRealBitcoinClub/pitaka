import 'dart:convert';

import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../api/responses.dart';

class DatabaseHelper {
  static DatabaseHelper _databaseHelper;    // Singleton DatabaseHelper
	static Database _database;                // Singleton Database


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
      "id INTEGER NOT NULL PRIMARY KEY,"
      "accountName TEXT,"
      "accountId TEXT,"
      "balance DOUBLE(40,2),"
      "timestamp TEXT,"
      "signature TEXT"
      ")");

    await db.execute("CREATE TABLE OfflineTransaction ("
      "id INTEGER NOT NULL PRIMARY KEY,"
      "amount DOUBLE(40,2),"
      "timestamp TEXT,"
      "transactionType TEXT,"
      "transactionJson TEXT"
      ")");
	}

  // Update latest balance of balance objects in database
  Future<String> updateOfflineBalances (List<Balance> balances) async {
    Database db = await this.database;
    await db.delete('Balance');
    for (final balance in balances) {
      var values = {
        'balance': balance.balance,
        'accountName': balance.accountName,
        'accountId': balance.accountId,
        'timestamp': balance.timestamp,
        'signature': balance.signature
      };
      await db.insert(
        'Balance',
        values
      );
    }
		return 'success';
  }

	// Get latest balance of balance objects in database
	Future <List<Map<String, dynamic>>> offLineBalances() async {
		Database db = await this.database;
		List<Map<String, dynamic>> result = await db.query('Balance');
		return result;
	}

  Future<String> updateBalances(Map payload) async{
    Database db = await this.database;
    String fromAccount = payload['from_account'];
    String toAccount = payload['to_account'];
    var qs1 = await db.query('Balance',where: 'accountId = ?', whereArgs: [fromAccount]);
    var instance = qs1[0];
    var signedBalance = {
      'message': instance['balance'],
      'signature': instance['signature'],
      'balance': instance['balance']
    };
    payload['signed_balance'] =  signedBalance;
    var temp = json.encode(payload);
    db.insert('OfflineTransaction', {
      "amount":payload['amount'],
      "timestamp":instance['timestamp'],
      "transactionType":"off-line",
      "transactionJson": temp
    });
    double newBalance = instance['balance'] - payload['amount'];
    await db.update('Balance', {'balance': newBalance}, where: 'accountId = ?', whereArgs: [fromAccount]);
    // Check if the recipient is in the user accounts list.
    var qs2 = await db.query('Balance',where: 'accountId = ?', whereArgs: [toAccount]);
    if (qs2.length == 1) {
      instance = qs2[0];
      newBalance = instance['balance'] + payload['amount'];
      await db.update('Balance', {'balance': newBalance}, where: 'accountId = ?', whereArgs: [toAccount]);
    }
    return 'success';
  }

  Future<int>processTransfer(Map payload) async {
    // Database db = await this.database;
    
    return 1;
  }

}