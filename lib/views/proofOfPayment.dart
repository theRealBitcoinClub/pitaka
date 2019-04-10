import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../views/app.dart';

class ProofOfPaymentComponent extends StatefulWidget {
  @override
  ProofOfPaymentComponentState createState() => new ProofOfPaymentComponentState();
}

class ProofOfPaymentComponentState extends State<ProofOfPaymentComponent> {

  Future<Map> getVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(prefs.getString("_txnSignature"));
    return {
      'code': prefs.getString("_txnQrCode"),
      'datetime': prefs.getString("_txnDateTime"),
      'amount': prefs.getString("_txnAmount")
    };
  }

  String convertToDoble (String val) {
    var given = double.parse(val);
    // return "PHP ${given.toStringAsFixed(2)}";
    final formatCurrency = new NumberFormat.currency(symbol: 'PHP ');
    return "${formatCurrency.format(given)}";
  }
  List<Widget> _buildAccountForm(BuildContext context) {
    final bodyHeight = MediaQuery.of(context).size.height -
      MediaQuery.of(context).viewInsets.bottom;
    Widget widget = FutureBuilder(
        future: getVal(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData) {
            if(snapshot.data != null) {
              return Center(
                child: new ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  children: <Widget>[
                    new SizedBox(
                      height: 30.0,
                    ),
                    Text(
                      convertToDoble(snapshot.data['amount']),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 35.0,
                        fontWeight: FontWeight.bold
                      )
                    ),
                    Text(
                      snapshot.data['datetime'],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.0
                      )
                    ),
                    new SizedBox(
                      height: 30.0,
                    ),
                    QrImage(
                      version: 15,
                      data: snapshot.data['code'],
                      size: 0.5 * bodyHeight,
                    ),
                    new SizedBox(
                      height: 10.0,
                    ),
                    new RaisedButton(
                      onPressed: () {
                        Application.router.navigateTo(context, '/home');
                        },
                      child: new Text('Continue'),
                    )
                  ],
                ),
              );
            }
          }
        }
    );
    var ws = new List<Widget>();
    ws.add(widget);
    return ws;
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        appBar: AppBar(
          title: Text('Payment Proof'),
          centerTitle: true,
          automaticallyImplyLeading: false
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
