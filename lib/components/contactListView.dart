import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/globals.dart' as globals;
import '../api/responses.dart';


final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
var balanceObj = Balance();
bool syncing = globals.syncing;

ListView buildContactList(contacts) {
  return ListView.builder(
    itemCount: contacts.length,
    itemBuilder: (BuildContext context, int index) {
      String dateOfLastBalance = contacts[index].date;
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
                            "${contacts[index].accountName}",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          )
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(15.0, 10.0, 12.0, 12.0),
                      child: Text(
                        "${formatCurrency.format(contacts[index].balance)}",
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
                    !globals.loading? Container() :
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 12.0, 12.0),
                      child:
                        Image.asset(
                        "assets/images/loading.gif",
                        height: 30.0,
                        width: 30.0,
                      )
                    ),
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
    }
  );
}
