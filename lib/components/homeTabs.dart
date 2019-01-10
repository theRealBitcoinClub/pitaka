import 'package:flutter/material.dart';
import 'package:flutter_keychain/flutter_keychain.dart';
import '../api/endpoints.dart';
import '../api/responses.dart';

// String userId;

// void getUserId() async {
//   userId = await FlutterKeychain.get(key: "userId");
// }

Future<List<Balance>> fetchBalances() async {
  var balancesPayload = {};
  var response = await getBalances(balancesPayload);
  return response.balances;
}

ListView _buildBalanceList(balances) {
  return ListView.builder(
      itemCount: balances.length,
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
                        "${balances[index].account}",
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                      child: Text(
                        "Php ${balances[index].balance}",
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
      });
}

var balanceTab = new Builder(builder: (BuildContext context) {
  fetchBalances();
  return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
          future: fetchBalances(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return _buildBalanceList(snapshot.data);
              } else {
                return new CircularProgressIndicator();
              }
            } else {
              return new CircularProgressIndicator();
            }
          }));
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
