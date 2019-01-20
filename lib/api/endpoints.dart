import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'dart:io';
import 'config.dart';
import 'responses.dart';

Future<dynamic> _sendPostRequest(url, payload) async {
  Dio dio = new Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  dio.cookieJar = new PersistCookieJar(tempPath);
  final response = await dio.post(url, data: json.encode(payload));
  return response;
}

Future<dynamic> _sendGetRequest(url) async {
  Dio dio = new Dio();
  Directory tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  dio.cookieJar = new PersistCookieJar(tempPath);
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
    return BalancesResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get balances');
  }
}

Future<TransactionsResponse> getTransactions(account) async {
  final String url = baseUrl + '/api/wallet/transactions/?account=' + account;
  final response = await _sendGetRequest(url);

  if (response.statusCode == 200) {
    return TransactionsResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get transactions');
  }
}
