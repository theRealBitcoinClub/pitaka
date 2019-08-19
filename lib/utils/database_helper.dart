import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../api/responses.dart';
import '../api/endpoints.dart';
// import '../utils/helpers.dart';
import '../utils/globals.dart' as globals;


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
      "account TEXT,"
      "amount DOUBLE(40,2),"
      "timestamp TEXT,"
      "mode TEXT,"
      "transactionJson TEXT"
      ")");
	}

  // Update latest balance of balance objects in database
  Future<String> updateOfflineBalances (List<Balance> balances) async {
    Database db = await this.database;
    await db.delete('Balance');
    await db.delete('OfflineTransaction');
    int idHolder = 1;
    for (final balance in balances) {
      DateTime datetime = DateTime.now();
      String dateOfLastBalance = new DateFormat.yMMMd().add_jm().format(datetime);
      var values = {
        'id': idHolder,
        'balance': balance.balance,
        'accountName': balance.accountName,
        'accountId': balance.accountId,
        'timestamp': balance.timestamp,
        'signature': balance.signature,
        'datetime': dateOfLastBalance
      };
      var idCheck = await db.query(
        'Balance',
        where: 'id = ?',
        whereArgs: [idHolder]
      );
      if (idCheck.length == 0 ) {
        await db.insert(
          'Balance',
          values
        );
      }
      idHolder += 1;
    }
		return 'success';
  }

  
  Future <Map<String, dynamic>> offlineBalanceAnalyser(String accountId, double onlineBalance) async {
    Database db = await this.database;
    double totalTransactions = 0.0;
    String latestTimeStamp = '';
    var transactions = await db.query(
      'OfflineTransaction',
      orderBy: 'id ASC',
      where: 'account = ?',
      whereArgs: [accountId]
    );
    for (final txn in transactions) {
      var amt = double.tryParse(txn['amount'].toString());
      if(txn['mode'].toString() == 'receive') {
        totalTransactions -= amt;
      } else {
        totalTransactions += amt;
      }
      latestTimeStamp = txn['timestamp'].toString();
    }
    double computedBalance =  onlineBalance - totalTransactions;
    return {
      'latestTimeStamp': latestTimeStamp,
      'computedBalance': computedBalance
    };
  }

  Future <bool> ifCleanDB () async {
    Database db = await this.database;
    var transactions = await db.query(
      'OfflineTransaction',
      orderBy: 'id ASC'
    );
    print('this is the length--------------');
    print(transactions.length);
    if (transactions.length == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future <bool> synchToServer () async {
    Database db = await this.database;
    var transactions = await db.query(
      'OfflineTransaction',
      orderBy: 'id ASC'
    );
    for (final txn in transactions) {
      var payload = json.decode(txn['transactionJson']);
      final String url = globals.baseUrl + '/api/assets/transfer';
      await sendPostRequest(url, payload);
    }
    await db.delete('OfflineTransaction');
    globals.syncing = false;
    return true;
  }

	// Get latest balance of balance objects in database
	Future <List<Map<String, dynamic>>> offLineBalances() async {
		Database db = await this.database;
    List<Map<String, dynamic>> result = [];
		List<Map<String, dynamic>> qs = await db.query('Balance');
    for (var account in qs) {
      double onlineBalance = account['balance'];
      var timestamp = account['timestamp'];
      String accountId = account['accountId'].toString();
      var resp = await offlineBalanceAnalyser(accountId, onlineBalance);
      if (resp['latestTimeStamp'] != '') {
        timestamp = resp['latestTimeStamp'];
      }
      var info = {
        'balance': resp['computedBalance'].toString(),
        'timestamp': timestamp,
        'accountName': account['accountName'],
        'accountId': accountId,
        'signature': account['signature'],
        'datetime': account['datetime']
      };

      if (result.indexOf(info) == -1) {
        result.add(info);
      }
      
    }
    
		return result;
	}

  Future <List<Map <String, dynamic>>> offLineTransactions () async {
    Database db = await this.database;
		List<Map<String, dynamic>> qs = await db.query('OfflineTransaction');
    return qs;
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
    var txnTimeStamp = payload['txn_hash'].split(':-:')[1];
    await db.insert(table2, {
      "account": instance['accountId'],
      "amount":payload['amount'],
      "timestamp":txnTimeStamp,
      "mode":"send",
      "transactionJson": converted
    });
    // Check if the recipient(toAccount) is in the user's accounts.
    var qs2 = await db.query(table1,where: 'accountId = ?', whereArgs: [toAccount]);
    if (qs2.length == 1) {
      instance = qs2[0];
      await db.insert(table2, {
        "account": instance['accountId'],
        "amount":payload['amount'],
        "timestamp":txnTimeStamp,
        "mode":"receive",
        "transactionJson": converted
      });
    }
    return 'success';
  }

  Future<int>acceptPayment(Map payload) async {
    Database db = await this.database;
    String table1 = 'Balance';
    String table2 = 'OfflineTransaction';
    var qs1 = await db.query(table1,where: 'accountId = ?', whereArgs: [payload['from_account']]);
    if (qs1.length == 0){
      var qs2 = await db.query(table1,where: 'accountId = ?', whereArgs: [payload['to_account']]);
      var instance = qs2[0];
      var converted = json.encode(payload);
      return db.insert(table2, {
        "account": payload['to_account'],
        "amount":payload['amount'],
        "timestamp":instance['timestamp'],
        "mode":"receive",
        "transactionJson": converted
      });
    } else {
      return 0;
    }
  }

}