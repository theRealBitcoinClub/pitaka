import 'package:dio/dio.dart';

class GenericCreateResponse {
  final bool success;
  final String id;

  GenericCreateResponse({this.success, this.id});

  factory GenericCreateResponse.fromResponse(Response response) {
    return GenericCreateResponse(
      success: response.data['success'],
      id: response.data['id'],
    );
  }
}

class PlainSuccessResponse {
  final bool success;
  final String error;

  PlainSuccessResponse({this.success, this.error});

  factory PlainSuccessResponse.fromResponse(Response response) {
    return PlainSuccessResponse(success: response.data['success'], error: response.data['error']);
  }

  factory PlainSuccessResponse.toDatabase(){
    return PlainSuccessResponse(success: true, error: '');
  }
}

class OtpVerificationResponse {
  final bool success;
  final bool verified;

  OtpVerificationResponse({this.success, this.verified});

  factory OtpVerificationResponse.fromResponse(Response response) {
    return OtpVerificationResponse(success: response.data['success'], verified: response.data['verified']);
  }
}

class Balance {
  String accountName;
  String accountId;
  String timestamp;
  String signature;
  double balance;
}

class BalancesResponse {
  final bool success;
  final List<Balance> balances;

  BalancesResponse({this.success, this.balances});

  factory BalancesResponse.fromResponse(Response response) {
    List<Balance> _balances = [];
    if (response.data['balances'] != null) {
      for (final bal in response.data['balances']) {
        var balanceObj = new Balance();
        balanceObj.accountName = bal['AccountName'];
        double balance = bal['Balance'].toDouble();
        balanceObj.balance = balance;
        balanceObj.accountId = bal['AccountID'];
        balanceObj.timestamp = response.data['timestamp'].toString();
        balanceObj.signature = bal['Signature'];
        _balances.add(balanceObj);
      }
    }
    return BalancesResponse(
        success: response.data['success'], balances: _balances);
  }

  factory BalancesResponse.fromDatabase(List accounts) {
    List<Balance> _balances = [];
    for (final account in accounts) {
      var balanceObj = new Balance();
      balanceObj.accountName = account['accountName'];
      double balance = account['balance'].toDouble();
      balanceObj.balance = balance;
      balanceObj.accountId = account['accountId'];
      balanceObj.timestamp = account['timestamp'];
      balanceObj.signature = account['signature'];
      _balances.add(balanceObj);
    }
    return BalancesResponse(
      success: true, balances: _balances
    );
  }

}

class Transaction {
  String mode; // send or receive
  double amount;
}

class TransactionsResponse {
  final bool success;
  final List<Transaction> transactions;

  TransactionsResponse({this.success, this.transactions});

  factory TransactionsResponse.fromResponse(Response response) {
    List<Transaction> _transactions = [];
    if (response.data['transactions'] != null) {
      for (final txn in response.data['transactions']) {
        var transObj = new Transaction();
        transObj.mode = txn['Mode'];
        transObj.amount = txn['Amount'].toDouble();
        _transactions.add(transObj);
      }
    }
    return TransactionsResponse(
        success: response.data['success'], transactions: _transactions);
  }
}

class Account {
  String accountName;
  String accountId;
  String balance;
}

class AccountsResponse {
  final bool success;
  final List<Account> accounts;

  AccountsResponse({this.success, this.accounts});

  factory AccountsResponse.fromResponse(Response response) {
    List<Account> _accounts = [];
    if (response.data['accounts'] != null) {
      for (final bal in response.data['accounts']) {
        var accountObj = new Account();
        accountObj.accountName = bal['Name'];
        accountObj.accountId = bal['ID'];
        _accounts.add(accountObj);
      }
    }
    return AccountsResponse(
        success: response.data['success'], accounts: _accounts);
  }
}
