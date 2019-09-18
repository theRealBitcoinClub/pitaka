import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/globals.dart' as globals;
import '../api/responses.dart';
import '../views/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:archive/archive.dart';

final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
var balanceObj = Balance();

ListView buildBalancesList(balances) {
  return ListView.builder(
      itemCount: balances.length,
      itemBuilder: (BuildContext context, int index) {
        String dateOfLastBalance = balances[index].date;
        return 
          Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
                        child:
                            Text(
                              "${balances[index].accountName}",
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            )
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(15.0, 10.0, 12.0, 12.0),
                        child: Text(
                          "${formatCurrency.format(balances[index].balance)}",
                          style: TextStyle(fontSize: 25.0),
                        ),
                      ),
                      globals.online == false ? Padding(
                        padding: const EdgeInsets.fromLTRB(15.0, 0, 12.0, 12.0),
                        child: Text(
                          "as of $dateOfLastBalance",
                          style: TextStyle(fontSize: 12.0)
                        )
                      ) : Container(),
                    ],
                  ), Column (
                    children: <Widget>[
                      globals.syncing ? Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 12.0, 12.0),
                        child:
                          Image.asset(
                          "assets/images/loading.gif",
                          height: 30.0,
                          width: 30.0,
                        )
                      ): Container()
                    ],
                  )
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

 _showProof(List<Transaction> transaction) {
      print('WAS PRESSED');
 }

   ListView buildTransactionsList(transactions) {
     return ListView.builder(
         itemCount: transactions.length,
         itemBuilder: (BuildContext context, int index) {
           return GestureDetector(
               onTap: _showProof(transactions),
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
                             const EdgeInsets.fromLTRB(15.0, 15.0, 12.0, 4.0),
                             child: Text(
                               "${_formatMode(
                                   transactions[transactions.length - index - 1]
                                       .mode)} - ${formatCurrency.format(
                                   transactions[transactions.length - index - 1]
                                       .amount)}",
                               style: TextStyle(fontSize: 20.0),
                             ),
                           ),
                           Padding(
                             padding:
                             const EdgeInsets.fromLTRB(15.0, 4.0, 8.0, 4.0),
                             child: Text(
                                 "${transactions[transactions.length - index -
                                     1]
                                     .time}",
                                 style: TextStyle(fontSize: 16.0)
                             ),
                           ),
                           Padding(
                             padding:
                             const EdgeInsets.fromLTRB(15.0, 4.0, 8.0, 15.0),
                             child: Text(
                                 "ID: ${transactions[transactions.length -
                                     index - 1]
                                     .txnID}",
                                 style: TextStyle(fontSize: 16.0)
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
                               child: _getModeIcon(transactions[transactions
                                   .length - index - 1].mode),
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
