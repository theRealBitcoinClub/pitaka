import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'config.dart';
import 'responses.dart';

Future<dynamic> _sendPostRequest(url, payload) async {
  Dio dio = new Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  final response = await dio.post(url, data: json.encode(payload));
  return response;
}

Future<dynamic> _sendGetRequest(url) async {
  Dio dio = new Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  final response = await dio.get(url);
  return response;
}

Future<GenericCreateResponse> createUser(payload) async {
  final String url = baseUrl + '/api/users/create';
  final response = await _sendPostRequest(url, payload);

  if (response.statusCode == 200) {
    return GenericCreateResponse.fromResponse(response);
  } else {
    throw Exception('Failed to create user');
  }
}

Future<GenericCreateResponse> createAccount(payload) async {
  final String url = baseUrl + '/api/accounts/create';
  final response = await _sendPostRequest(url, payload);

  if (response.statusCode == 200) {
    return GenericCreateResponse.fromResponse(response);
  } else {
    throw Exception('Failed to create account');
  }
}

Future<PlainSuccessResponse> loginUser(payload) async {
  final String url = baseUrl + '/api/auth/login';
  final response = await _sendPostRequest(url, payload);

  if (response.statusCode == 200) {
    return PlainSuccessResponse.fromResponse(response);
  } else {
    throw Exception('Failed to login user');
  }
}

Future<BalancesResponse> getBalances() async {
  final String url = baseUrl + '/api/wallet/balance';
  final response = await _sendGetRequest(url);
  if (response.statusCode == 200) {
    // Store account details in keychain
    List<String> _accounts = [];
    for (final bal in response.data['balances']) {
      String acct = bal['AccountName'] + '|' + bal['AccountID'];
      _accounts.add(acct);
    }
    await FlutterKeychain.put(key: "accounts", value: _accounts.join(','));
    // Parse response into BalanceResponse
    return BalancesResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get balances');
  }
}

Future<TransactionsResponse> getTransactions() async {
  final String url = baseUrl + '/api/wallet/transactions';
  final response = await _sendGetRequest(url);
  if (response.statusCode == 200) {
    return TransactionsResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get transactions');
  }
}

Future<AccountsResponse> getAccounts() async {
  final String url = baseUrl + '/api/accounts/list';
  final response = await _sendGetRequest(url);
  if (response.statusCode == 200) {
    return AccountsResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get accounts');
  }
}

Future<PlainSuccessResponse> transferAsset(payload) async {
  final String url = baseUrl + '/api/assets/transfer';
  final response = await _sendPostRequest(url, payload);
  if (response.statusCode == 200) {
    return PlainSuccessResponse.fromResponse(response);
  } else {
    throw Exception('Failed to transfer asset');
  }
}
