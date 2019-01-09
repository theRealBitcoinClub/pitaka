import 'package:dio/dio.dart';
import 'dart:convert';

class GenericCreateResponse {
  final bool success;
  final String xid;

  GenericCreateResponse({this.success, this.xid});

  factory GenericCreateResponse.fromResponse(Response response) {
    return GenericCreateResponse(
      success: response.data['success'],
      xid: response.data['xid'],
    );
  }
}

class PlainSuccessResponse {
  final bool success;

  PlainSuccessResponse({this.success});

  factory PlainSuccessResponse.fromResponse(Response response) {
    return PlainSuccessResponse(
      success: response.data['success']
    );
  }
}

class Balance {
  String account;
  int balance;
}

class BalancesResponse {
  final bool success;
  final List<Balance> balances;

  BalancesResponse({this.success, this.balances});

  factory BalancesResponse.fromResponse(Response response) {
    List<Balance> _balances = [];
    for (final bal in response.data['balances']) {
      var balanceObj = new Balance();
      balanceObj.account = bal['account'];
      balanceObj.balance = bal['balance'];
      _balances.add(balanceObj);
    }
    return BalancesResponse(
      success: response.data['success'],
      balances: _balances
    );
  }
}