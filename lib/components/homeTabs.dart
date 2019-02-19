import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../api/endpoints.dart';

final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');

ListView _buildBalancesList(balances) {
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
                            "${balances[index].accountName}",
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
  return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
          future: getBalances(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (snapshot.data.balances.length > 0) {
                  return _buildBalancesList(snapshot.data.balances);
                } else {
                  return new CircularProgressIndicator();
                }
              } else {
                return new CircularProgressIndicator();
              }
            } else {
              return new CircularProgressIndicator();
            }
          }));
});

String _formatMode(String mode) {
  String formattedMode;
  if (mode == 'receive') {
    formattedMode = 'Received';
  }
  if (mode == 'send') {
    formattedMode = 'Sent';
  }
  return formattedMode;
}

Icon _getModeIcon(String mode) {
  Icon icon;
  if (mode == 'receive') {
    icon = Icon(
      Icons.add,
      size: 30.0,
      color: Colors.green,
    );
  }
  if (mode == 'send') {
    icon = Icon(
      Icons.remove,
      size: 30.0,
      color: Colors.red,
    );
  }
  return icon;
}

ListView _buildTransactionsList(transactions) {
  return ListView.builder(
      itemCount: transactions.length,
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
                            "${_formatMode(transactions[index].mode)}",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.fromLTRB(12.0, 6.0, 12.0, 12.0),
                          child: Text(
                            "${formatCurrency.format(transactions[index].amount)}",
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
                            child: _getModeIcon(transactions[index].mode),
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

var transactionsTab = new Builder(builder: (BuildContext context) {
  return new Container(
      alignment: Alignment.center,
      child: new FutureBuilder(
          future: getTransactions(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data != null) {
                if (snapshot.data.transactions.length > 0) {
                  return _buildTransactionsList(snapshot.data.transactions);
                } else {
                  return Text('No transactions to display');
                }
              } else {
                return new CircularProgressIndicator();
              }
            } else {
              return new CircularProgressIndicator();
            }
          }));
});
