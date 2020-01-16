import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/globals.dart' as globals;
import '../api/responses.dart';


// final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
// var balanceObj = Balance();
// bool syncing = globals.syncing;

// ListView buildBalancesList(balances) {
//   return ListView.builder(
//       itemCount: balances.length,
//       itemBuilder: (BuildContext context, int index) {
//         return 
//           Column(
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
//                         child:
//                             Text(
//                               "Slow Internet",
//                               style: TextStyle(
//                                   fontSize: 18.0, fontWeight: FontWeight.bold),
//                             )
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           );
//       });
// }


//    ListView buildTransactionsList(transactions) {
//  return ListView.builder(
//       itemBuilder: (BuildContext context, int index) {
//         return 
//           Column(
//             children: <Widget>[
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: <Widget>[
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       Padding(
//                         padding: const EdgeInsets.fromLTRB(15.0, 10.0, 0.0, 0.0),
//                         child:
//                             Text(
//                               "Slow Internet",
//                               style: TextStyle(
//                                   fontSize: 18.0, fontWeight: FontWeight.bold),
//                             )
//                       ),
//                     ],
//                   ), 
//                 ],
//               ),
//             ],
//           );
//       });
//    }

   
  @override
  build(BuildContext context) {
    new Builder(builder: (BuildContext context) {
      return Text('No transactions to display');
    });
  }