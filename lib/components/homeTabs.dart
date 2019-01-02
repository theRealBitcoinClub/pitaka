import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';

Future<String> userId;
Future<String> accountId;

void getUserId() async {
  userId = FlutterKeychain.get(key: "userId");
}

void getAccountId() async {
  userId = FlutterKeychain.get(key: "accountId");
}

var balanceTab = new Builder(builder: (BuildContext context) {
  getUserId();
  getAccountId();
  return Column(children: <Widget>[
    Text("PHP 2,000.000",
        style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold)),
    new FutureBuilder<String>(
        future: userId,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return new Text(
              snapshot.data != null ? 'User ID: ' + snapshot.data : '');
        }),
    new FutureBuilder<String>(
        future: accountId,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          return new Text(
              snapshot.data != null ? 'Account ID: ' + snapshot.data : '');
        }),
  ]);
});

List<String> transactions = [
  "450.50",
  "2,000.75",
  "9,250.00",
  "400.00",
  "56.45",
  "100.00",
  "3,291.34",
  "300.00",
  "459.50",
  "100.00"
];

var transactionsTab = ListView.builder(
  itemBuilder: (BuildContext context, int index) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 6.0),
                  child: Text(
                    "Sent Php ${transactions[index]}",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                  child: Text(
                    "to Ken Telmo",
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.arrow_right,
                      size: 30.0,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(
          height: 2.0,
          color: Colors.grey,
        )
      ],
    );
  },
  itemCount: 10,
);
