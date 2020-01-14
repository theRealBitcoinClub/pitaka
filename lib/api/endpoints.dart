import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'responses.dart';
import '../utils/helpers.dart';
import '../utils/database_helper.dart';
import '../utils/globals.dart' as globals;
//import '../utils/print_wrapped.dart';


DatabaseHelper databaseHelper = DatabaseHelper();

Future<dynamic> sendPostRequest(url, payload) async {
  var dio = new Dio();
  dio.options.connectTimeout = 30000;  // Set connection timeout for 30 seconds
  dio.transformer = new FlutterTransformer();
  var tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  Response response;
  try {
    response = await dio.post(
      url, 
      data: payload, 
      options: Options(
        headers: {"Version": "${globals.appVersion}"}
      ),
    );
  } catch(e) {
    // Cast error to string type
    String errorType = e.toString();
    // Check if "DioErrorType.CONNECT_TIMEOUT" error is in the string
    // And return the error type
    if (errorType.contains("DioErrorType.CONNECT_TIMEOUT")) {
      //print("Your internet connection is very slow. Switch to offline mode to continue this transaction.");
      return "DioErrorType.CONNECT_TIMEOUT";
    } else {
      return errorType;
    }
  }
  return response;
}

Future<dynamic> sendGetRequest(url) async {
  globals.loading = true;
  var payload = {
    'public_key': globals.serverPublicKey
  };
  var dio = new Dio();
  dio.options.connectTimeout = 30000;  // Set connection timeout for 30 seconds
  var tempDir = await getTemporaryDirectory();
  String tempPath = tempDir.path;
  CookieJar cj = new PersistCookieJar(dir: tempPath);
  dio.interceptors.add(CookieManager(cj));
  Response response;
  try {
    response = await dio.get(
      url, 
      queryParameters:payload,
      options: Options(
        headers: {"Version": "${globals.appVersion}"}
      ),
    );
  } catch(e) {
    // Cast error to string type
    String errorType = e.toString();
    // Check if "DioErrorType.CONNECT_TIMEOUT" error is in the string
    // And return the error type
    if (errorType.contains("DioErrorType.CONNECT_TIMEOUT")) {
      //print("Your internet connection is very slow. Switch to offline mode to continue this transaction.");
      return "DioErrorType.CONNECT_TIMEOUT";
    } else {
      return errorType;
    }
  }
  globals.loading = false;
  return response;
}

Future<GenericCreateResponse> createUser(payload) async {
  try {
    final String url = globals.baseUrl + '/api/users/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<GenericCreateResponse> registerBusiness(payload) async {
  try {
    String publicKey = await globals.storage.read(key:"publicKey");
    String privateKey = await globals.storage.read(key:"privateKey");
    var txnhash = "${payload['tin']}:message:$publicKey";
    String signature = await signTransaction(txnhash, privateKey);
    payload['signature'] = signature;
    payload['txn_hash'] = txnhash;
    payload['public_key'] = publicKey;
    final String url = globals.baseUrl + '/api/business/registration';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e){
    throw Exception(e);
  }
}

Future<GenericCreateResponse> linkBusinessToAccount(payload) async {
  try {
    String publicKey = await globals.storage.read(key:"publicKey");
    String privateKey = await globals.storage.read(key:"privateKey");
    var txnhash = "linkToBusiness:message:$publicKey";
    String signature = await signTransaction(txnhash, privateKey);
    payload['signature'] = signature;
    payload['txn_hash'] = txnhash;
    payload['public_key'] = publicKey;
    final String url = globals.baseUrl + '/api/business/connect-account';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e){
    throw Exception(e);
  }
}

Future<GenericCreateResponse> createAccount(payload) async {
  try {
    final String url = globals.baseUrl + '/api/accounts/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<GenericCreateResponse> addAccount(payload) async {
  try {
    final String url = globals.baseUrl + '/api/accounts/create';
    final response = await sendPostRequest(url, payload);
    return GenericCreateResponse.fromResponse(response);
  } catch (e) {
    throw Exception(e);
  }
}

Future<PlainSuccessResponse> loginUser(payload) async {
  final String url = globals.baseUrl + '/api/auth/login';
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
  String publicKey = await globals.storage.read(key: "publicKey");
  String privateKey = await globals.storage.read(key: "privateKey");
  String loginSignature = await signTransaction("hello world", privateKey);
  var loginPayload = {
    "public_key": publicKey,
    "session_key": "hello world",
    "signature": loginSignature,
  };
  await loginUser(loginPayload);
}

Future getBusinessList(List list) async {
  for (final q in list) {
    final String url = globals.baseUrl + "/api/business/list?sel=$q";
    List data = List();
    Response response;
    try {
      response = await sendGetRequest(url);
      if (response.data['business'] != null) {
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
      }
    } catch (e) {
      throw(e);
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var temp = json.encode(data);
    await prefs.setString('businessList-$q', temp);
  }
}

Future getAccountsList() async {
  final String url = globals.baseUrl + "/api/accounts/list-not-linked-to-business";
  List data = List();
  Response response;
  try {
    response = await sendGetRequest(url);
    if (response.data['account'] != null) {
      data = response.data['account'];
    }
  } catch (e) {
    throw(e);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var temp = json.encode(data);
  await prefs.setString('accountsList', temp);
  return data;
}

Future<BalancesResponse> getOffLineBalances() async {
  var resp = await databaseHelper.offLineBalances();
  return BalancesResponse.fromDatabase(resp);
}

Future<BalancesResponse> getOnlineBalances() async {
  final String url = globals.baseUrl + '/api/wallet/balance';
  var response;
  try {
    response = await sendGetRequest(url);
    // Store account details in keychain
    List<String> _accounts = [];
    List<Balance> _balances = [];
    for (final bal in response.data['balances']) {
      var balanceObj = new Balance();
      var timestamp = response.data['timestamp'].toString();
      String acct = "${bal['AccountName']} | ${bal['AccountID']} | "
      "${bal['Balance']} | ${bal['Signature']} | $timestamp";
      _accounts.add(acct);
      balanceObj.accountName = bal['AccountName'];
      double balance = bal['Balance'].toDouble();
      balanceObj.balance = balance;
      balanceObj.accountId = bal['AccountID'];
      balanceObj.timestamp = timestamp;
      balanceObj.signature = bal['Signature'];
      _balances.add(balanceObj);
    }
    // Update balances only if response is success
    if (response.data['success']) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('accounts', _accounts);
      await databaseHelper.updateOfflineBalances(_balances);
      // Parse response into BalanceResponse
      return BalancesResponse.fromResponse(response);
    }
  } catch (e) {
    var resp = await databaseHelper.offLineBalances();
    return BalancesResponse.connectTimeoutError(resp);
  }
  return response;
}

Future<TransactionsResponse> getOnlineTransactions() async {
  final String url = globals.baseUrl + '/api/wallet/transactions';
  var response;
  try {
    response = await sendGetRequest(url);

    // Call printWrapped funtion from utils to print very long text
    // Use only for debugging, comment out when done
    // printWrapped("The value of response from getOnlineTransactions() - endpoints.dart is: $response",);

    if (response.data['success']) {
      return TransactionsResponse.fromResponse(response);
    }
  } catch (e) {
    var resp = await databaseHelper.offLineTransactions();
    return TransactionsResponse.connectTimeoutError(resp);
  }
  return response;
}

Future<TransactionsResponse> getOffLineTransactions() async {
  var resp = await databaseHelper.offLineTransactions();
  return TransactionsResponse.fromDatabase(resp);
}

Future<AccountsResponse> getAccounts() async {
  final String url = globals.baseUrl + '/api/accounts/list';
  final response = await sendGetRequest(url);
  if (response.statusCode == 200) {
    return AccountsResponse.fromResponse(response);
  } else {
    throw Exception('Failed to get accounts');
  }
}

Future getBusinesReferences() async {
  await getBusinessList(['all', 'false']);
  await getAccountsList();
}

Future<PlainSuccessResponse> transferAsset(Map payload) async {
  var response;
  if (globals.online) {
    final String url = globals.baseUrl + '/api/assets/transfer';
    // Catch the CONNECT_TIMEOUT error
    try {
      response = await sendPostRequest(url, payload);
      if (response.statusCode == 200) {
        return PlainSuccessResponse.fromResponse(response);
      } else {
        throw Exception('Failed to transfer asset');
      }
    }
    catch(e) {
      if (response == "DioErrorType.CONNECT_TIMEOUT") {
        // Can't return response, added PlainSuccessResponse in responses.dart
        return PlainSuccessResponse.connectTimeoutError();
      }
      //return response;
    }
  } else {
    await databaseHelper.offLineTransfer(payload);
    return PlainSuccessResponse.toDatabase();
  } 
}

// This is called in "authenticate.dart" in sendAuthentication()
Future<PlainSuccessResponse> authWebApp(Map payload) async {
  // Check if online
  if (globals.online) {
    final String url = globals.baseUrl + '/api/web-wallet/authenticate';
    var response;
    try {
      response = await sendPostRequest(url, payload);
      if (response.statusCode == 200) {
        return PlainSuccessResponse.fromResponse(response);
      } else {
        throw Exception('Failed to transfer asset');
      }
    }
    catch(e) {
      // Can't return response, added PlainSuccessResponse in responses.dart
      return PlainSuccessResponse.connectTimeoutError();
    }
  } else {
    return PlainSuccessResponse.toDatabase();
  } 
}

// This is called in "receive.dart" in scanQrcode() function
Future<PlainSuccessResponse> receiveAsset(Map payload) async {
  // Check if online
  if (globals.online) {
    // If sender is offline, send the scanned QRcode payload to server
    await transferAsset(payload);
    return PlainSuccessResponse.toDatabase();
  } else {

    // Call printWrapped funtion from utils to print very long text
    // Use only for debugging, comment out when done
    //printWrapped("The value of payload from receiveAsset() - endpoint.dart is: $payload",);

    // If both sender & reciever are offline, save scanned QRcode payload to local database
    await databaseHelper.acceptOfflinePayment(payload);
    return PlainSuccessResponse.toDatabase();
  }
}

Future<PlainSuccessResponse> requestOtpCode(payload) async {
  final String url = globals.baseUrl + '/api/otp/request';
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
  final String url = globals.baseUrl + '/api/otp/verify';
  Response response;
  try {
    response = await sendPostRequest(url, payload);
    return OtpVerificationResponse.fromResponse(response);
  } catch(e) {
    throw Exception('Failed to verify OTP code');
  }
}