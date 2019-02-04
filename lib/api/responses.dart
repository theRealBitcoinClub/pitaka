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

  PlainSuccessResponse({this.success});

  factory PlainSuccessResponse.fromResponse(Response response) {
    return PlainSuccessResponse(success: response.data['success']);
  }
}

class Balance {
  String accountName;
  String accountId;
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
        balanceObj.balance = bal['Balance'].toDouble();
        _balances.add(balanceObj);
      }
    }
    return BalancesResponse(
        success: response.data['success'], balances: _balances);
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
