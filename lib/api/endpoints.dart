import 'package:http/http.dart' as http;
import 'dart:convert';
import 'config.dart';
import 'responses.dart';

Future<dynamic> _sendPostRequest(url, payload) async {
  var headers = {'Content-Type': 'application/json'};
  final response =
      await http.post(url, body: json.encode(payload), headers: headers);
  return response;
}

Future<GenericCreateResponse> createUser(payload) async {
  final String url = baseUrl + '/api/users/create';
  final response = await _sendPostRequest(url, payload);

  if (response.statusCode == 200) {
    return GenericCreateResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create user');
  }
}

Future<GenericCreateResponse> createAccount(payload) async {
  final String url = baseUrl + '/api/accounts/create';
  final response = await _sendPostRequest(url, payload);

  if (response.statusCode == 200) {
    return GenericCreateResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to create account');
  }
}
