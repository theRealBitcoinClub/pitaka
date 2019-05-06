import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../api/responses.dart';
// import '../utils/helpers.dart';
// import '../utils/globals.dart' as globals;


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
      "signature TEXT,"
      "datetime TEXT"
      ")");

    await db.execute("CREATE TABLE OfflineTransaction ("
      "id INTEGER NOT NULL PRIMARY KEY,"
      "account INTEGER,"
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
    db.delete('OfflineTransaction');
    for (final balance in balances) {
      DateTime datetime = DateTime.now();
      String dateOfLastBalance = new DateFormat.yMMMd().add_jm().format(datetime);
      var values = {
        'balance': balance.balance,
        'accountName': balance.accountName,
        'accountId': balance.accountId,
        'timestamp': balance.timestamp,
        'signature': balance.signature,
        'datetime': dateOfLastBalance
      };
      await db.insert(
        'Balance',
        values
      );
    }
		return 'success';
  }

  Future<String> checkAccountBalance (String accountId) async {
    Database db = await this.database;
    var balances = await db.query(
      'Balance',
      orderBy: 'id ASC',
      where: 'accountId = ?',
      whereArgs: [accountId]
    );
    var balance = balances[0];
    double totalTransactions = 0.0;
    var transactions = await db.query(
      'OfflineTransaction',
      orderBy: 'id ASC',
      where: 'account = ?',
      whereArgs: [balance['id']]
    );
    for (final txn in transactions) {
      if(txn['transactionType'] == 'incoming') {
        totalTransactions -= txn['amount'].toDouble();
      } else {
        totalTransactions += txn['amount'].toDouble();
      }
    }
    var computedBalance =  balance['balance'] - totalTransactions;
    return computedBalance.toString();
  } 
  
	// Get latest balance of balance objects in database
	Future <List<Map<String, dynamic>>> offLineBalances() async {
		Database db = await this.database;
    List<Map<String, dynamic>> result = [];
		List<Map<String, dynamic>> qs = await db.query('Balance');
    for (var account in qs) {
      // qs = await db.query('OfflineTransaction');
      double totalTransactions = 0.0;
      var latestTimeStamp = account['timestamp'];
      var transactions = [];
      transactions = await db.query(
        'OfflineTransaction',
        orderBy: 'id ASC',
        where: 'account = ?',
        whereArgs: [account['id']]
      );
      for (final txn in transactions) {
        if(txn['transactionType'] == 'incoming') {
          totalTransactions -= txn['amount'].toDouble();
        } else {
          totalTransactions += txn['amount'].toDouble();
        }
        latestTimeStamp = txn['timestamp'];
      }
      double computedBalance;
      var val = account['balance'].toDouble();
      computedBalance =  val - totalTransactions;
      result.add({
        'balance': computedBalance,
        'timestamp': latestTimeStamp,
        'accountName': account['accountName'],
        'accountId': account['accountId'],
        'signature': account['signature'],
        'datetime': account['datetime']
      });
    }
		return result;
	}

 
  Future<String> offLineTransfer(Map payload) async{
    Database db = await this.database;
    String fromAccount = payload['from_account'];
    String toAccount = payload['to_account'];
    String table1 = 'Balance';
    String table2 = 'OfflineTransaction';
    var qs1 = await db.query(table1,where: 'accountId = ?', whereArgs: [fromAccount]);
    var instance = qs1[0];
    var concatenated = "${instance['balance']}${instance['accountId']}${instance['timestamp']}";
    var bytes = utf8.encode(concatenated);
    var hashMessage = sha256.convert(bytes).toString();
    payload['signed_balance'] =  {
      'message': hashMessage,
      'signature': instance['signature'],
      'balance': instance['balance'],
      'timestamp': instance['timestamp']
    };
    var converted = json.encode(payload);
    var txnTimeStamp = payload['txn_hash'].split(':messsage:')[1];
    await db.insert(table2, {
      "account": instance['id'],
      "amount":payload['amount'],
      "timestamp":txnTimeStamp,
      "transactionType":"outcoming",
      "transactionJson": converted
    });
    // Check if the recipient(toAccount) is in the user's accounts.
    var qs2 = await db.query(table1,where: 'accountId = ?', whereArgs: [toAccount]);
    if (qs2.length == 1) {
      instance = qs2[0];
      await db.insert(table2, {
        "account": instance['id'],
        "amount":payload['amount'],
        "timestamp":txnTimeStamp,
        "transactionType":"incoming",
        "transactionJson": converted
      });
    }
    return 'success';
  }

  Future<int>acceptPayment(Map payload) async {
    Database db = await this.database;
    String table1 = 'Balance';
    String table2 = 'OfflineTransaction';
    var qs = await db.query(table1,where: 'accountId = ?', whereArgs: [payload['to_account']]);
    var instance = qs[0];
    var converted = json.encode(payload);
    db.insert(table2, {
      "amount":payload['amount'],
      "timestamp":instance['timestamp'],
      "transactionType":"incoming",
      "transactionJson": converted
    });
    double newBalance = instance['balance'] + payload['amount'];
    DateTime datetime = DateTime.now();
    String dateOfLastBalance = new DateFormat.yMMMd().add_jm().format(datetime);
    return await db.update(
      table1,
      {
        'balance': newBalance,
        'datetime': dateOfLastBalance
      },
      where: 'accountId = ?',
      whereArgs: [payload['to_account']]
    );
  }

}