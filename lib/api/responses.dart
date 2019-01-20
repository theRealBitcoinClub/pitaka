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
  String account;
  double balance;
}

class BalancesResponse {
  final bool success;
  final List<Balance> balances;

  BalancesResponse({this.success, this.balances});

  factory BalancesResponse.fromResponse(Response response) {
    List<Balance> _balances = [];
    for (final bal in response.data['balances']) {
      var balanceObj = new Balance();
      balanceObj.account = bal['Account'];
      balanceObj.balance = bal['Balance'];
      _balances.add(balanceObj);
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
    for (final bal in response.data['transactions']) {
      var transObj = new Transaction();
      transObj.mode = bal['Mode'];
      transObj.amount = bal['Amount'];
      _transactions.add(transObj);
    }
    return TransactionsResponse(
        success: response.data['success'], transactions: _transactions);
  }
}
