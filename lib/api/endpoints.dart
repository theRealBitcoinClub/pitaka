import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'config.dart';
import 'responses.dart';
import '../helpers.dart';

Future<dynamic> sendPostRequest(url, payload) async {
  var dio = new Dio();
  dio.transformer = new FlutterTransformer();
  var tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  final response = await dio.post(url, data: payload);
  return response;
}

Future<dynamic> sendGetRequest(url) async {
  var dio = new Dio();
  var tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  final response = await dio.get(url);
  return response;
}

Future<GenericCreateResponse> createUser(payload) async {
  try {
    final String url = baseUrl + '/api/users/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<GenericCreateResponse> registerBusiness(payload) async {
  try {
    String publicKey = await FlutterKeychain.get(key: "publicKey");
    String privateKey = await FlutterKeychain.get(key: "privateKey");
    var txnhash = "${payload['tin']}:message:$publicKey";
    String signature = await signTransaction(txnhash, privateKey);
    payload['signature'] = signature;
    payload['txn_hash'] = txnhash;
    payload['public_key'] = publicKey;
    final String url = baseUrl + '/api/business/registration';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e){
    throw Exception(e);
  }
}
Future<GenericCreateResponse> createAccount(payload) async {
  try {
    final String url = baseUrl + '/api/accounts/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<GenericCreateResponse> addAccount(payload) async {
  try {
    final String url = baseUrl + '/api/accounts/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<PlainSuccessResponse> loginUser(payload) async {
  final String url = baseUrl + '/api/auth/login';
  try {
    Response response;
    response = await sendPostRequest(url, payload);
    // Save user details in shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var user = response.data['user'];
    await prefs.setString('firstName', user['FirstName']);
    await prefs.setString('lastName', user['LastName']);
    await prefs.setString('email', user['Email']);
    return PlainSuccessResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<void> sendLoginRequest() async {
  String publicKey = await FlutterKeychain.get(key: "publicKey");
  String privateKey = await FlutterKeychain.get(key: "privateKey");
  String loginSignature = await signTransaction("hello world", privateKey);
  var loginPayload = {
    "public_key": publicKey,
    "session_key": "hello world",
    "signature": loginSignature,
  };
  await loginUser(loginPayload);
}

Future getBusinessList() async {
  final String url = baseUrl + "/api/business/list?sel=all";
  List data = List();
  Response response;
  try {
    response = await sendGetRequest(url);
    for (final temp in response.data['business']) {
      var subData = {
        'id' : temp['id'],
        'title': temp['name'],
        'tin': temp['tin'],
        'type': temp['type'],
        'address': temp['address'],
        'linkedaccount': temp['linked_account_name']
      };
      data.add(subData);
    }
  } catch (e) {
    print(e);
  }
  return data;
}

Future<BalancesResponse> getBalances() async {
  final String url = baseUrl + '/api/wallet/balance';
  Response response;
  try {
    response = await sendGetRequest(url);
    // Store account details in keychain
    List<String> _accounts = [];
    for (final bal in response.data['balances']) {
      String acct = "${bal['AccountName']} | ${bal['AccountID']} | ${bal['Balance']}";
      _accounts.add(acct);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('accounts', _accounts);
    // Parse response into BalanceResponse
    return BalancesResponse.fromResponse(response);
  } catch (e) {
    print(e);
    // Login before resending the request again
    await sendLoginRequest();
    return await getBalances();
  }
}

Future<TransactionsResponse> getTransactions() async {
  final String url = baseUrl + '/api/wallet/transactions';
  Response response;
  try {
    response = await sendGetRequest(url);
    return TransactionsResponse.fromResponse(response);
  } catch (e) {
    // Login before resending the request again
    await sendLoginRequest();
    return await getTransactions();
  }
}

Future<AccountsResponse> getAccounts() async {
  final String url = baseUrl + '/api/accounts/list';
  final response = await sendGetRequest(url);
  if (response.statusCode == 200) {
    return AccountsResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get accounts');
  }
}

Future<PlainSuccessResponse> transferAsset(payload) async {
  final String url = baseUrl + '/api/assets/transfer';
  final response = await sendPostRequest(url, payload);
  if (response.statusCode == 200) {
    return PlainSuccessResponse.fromResponse(response);
  } else {
    throw Exception('Failed to transfer asset');
  }
}

Future<PlainSuccessResponse> requestOtpCode(payload) async {
  final String url = baseUrl + '/api/otp/request';
  Response response;
  try {
    response = await sendPostRequest(url, payload);
    return PlainSuccessResponse.fromResponse(response);
  } catch(e) {
    print(e);
    throw Exception('Failed to generate OTP code');
  }
}

Future<OtpVerificationResponse> verifyOtpCode(payload) async {
  final String url = baseUrl + '/api/otp/verify';
  Response response;
  try {
    response = await sendPostRequest(url, payload);
    return OtpVerificationResponse.fromResponse(response);
  } catch(e) {
    throw Exception('Failed to verify OTP code');
  }
}
