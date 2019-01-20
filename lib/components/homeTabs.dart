import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/endpoints.dart';
import '../api/responses.dart';

Future<List<Balance>> fetchBalances() async {
  var response = await getBalances();
  return response.balances;
}

Future<List<Transaction>> fetchTransactions() async {
  var response = await getBalances();
  return response.balances;
}

final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');

ListView _buildAccountsList(balances) {
  return ListView.builder(
      itemCount: balances.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
            onTap: () {
              print('Touched!');
            },
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 6.0),
                          child: Text(
                            "${balances[index].account}",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                          child: Text(
                            "${formatCurrency.format(balances[index].balance)}",
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
            ));
      });
}

var accountsTab = new Builder(builder: (BuildContext context) {
  fetchBalances();
  return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
          future: fetchBalances(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                return _buildAccountsList(snapshot.data);
              } else {
                return new CircularProgressIndicator();
              }
            } else {
              return new CircularProgressIndicator();
            }
          }));
});

List<double> transactions = [
  450.50,
  2000.75,
  9250.00,
  400.00,
  56.45,
  100.00,
  3291.34,
  300.00,
  459.50,
  100.00
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
                    "Sent ${formatCurrency.format(transactions[index])}",
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
