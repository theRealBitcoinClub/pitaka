import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/globals.dart' as globals;
import '../api/responses.dart';
import 'package:qr_flutter/qr_flutter.dart';


final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
var balanceObj = Balance();
bool syncing = globals.syncing;

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

// _showProof(List<Transaction> transaction, BuildContext context, int index) async {
//   Dialog transacDialog = Dialog(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//     child: Container(
//       height: 500.0,
//       width: 400.0,

//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: <Widget>[
//           QrImage(
//             data: transaction[transaction.length - index -1].paymentProof,
//             size: 250.0
//           ),

//           Padding(
//             padding:  EdgeInsets.all(10.0),
//             child: Text("${formatCurrency.format(
//             transaction[transaction.length - index - 1]
//                 .amount)}", style: TextStyle(fontSize: 20.0),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(5.0),
//             child: Text("${transaction[transaction.length - index -
//                 1].time}", style: TextStyle(fontSize: 20.0),
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.all(5.0),
//             child: Text("ID: ${transaction[transaction.length -
//                 index - 1].txnID}", style: TextStyle(fontSize: 20.0),
//             ),
//           ),
//           Padding(padding: EdgeInsets.only(top: 20.0)),
//           FlatButton(onPressed: (){
//             Navigator.of(context).pop();
//           },
//               child: Text('Back', style: TextStyle(color: Colors.red, fontSize: 18.0),))
//         ],
//       ),
//     ),
//   );

//   if(transaction[transaction.length - index - 1].mode == "send") {
//     showDialog(context: context, builder: (BuildContext context) => transacDialog);
//   }
//  }

ListView buildContactList(contacts) {
  return ListView.builder(
    itemCount: contacts.length,
    itemBuilder: (BuildContext context, int index) {
      return GestureDetector(
        //onTap: () => _showProof(contacts, context, index),
        onTap: () => print("Send fund to this contact!"),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Text(contacts[index].firstName[0],
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      )
                    ),
                  )
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(8.0, 1.0, 12.0, 4.0),
                      child: Text(
                        "${contacts[index].firstName}" + ' ' + "${contacts[index].lastName}",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 4.0),
                      child: Text(
                        "${contacts[index].mobileNumber}",
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(8.0, 1.0, 12.0, 4.0),
                      child: Icon(
                        Icons.send,
                        size: 25.0,
                        color: Colors.red,
                      ),
                    ),
                  ],
                )
                // Padding(
                //   padding: const EdgeInsets.all(8.0),
                //   child: Column(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: <Widget>[
                //       Padding(
                //         padding: const EdgeInsets.all(8.0),
                //         child: Icon(
                //           Icons.send,
                //           size: 25.0,
                //           color: Colors.red,
                //         )
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ],
        )
      );
    }
  );
}
