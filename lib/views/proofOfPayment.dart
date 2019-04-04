import 'package:flutter/material.dart';
import '../views/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';


class ProofOfPaymentComponent extends StatefulWidget {
  @override
  ProofOfPaymentComponentState createState() => new ProofOfPaymentComponentState();
}

class ProofOfPaymentComponentState extends State<ProofOfPaymentComponent> {

  Future<Map> getVal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'code': prefs.getString("_txnQrCode"),
      'date': prefs.getString("_txnDate"),
      'amount': prefs.getString("_txnAmount"),
      'time': prefs.getString("_txnTime")
    };
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  children: <Widget>[
                    Text(snapshot.data['date']),
                    Text(snapshot.data['time']),
                    Text(snapshot.data['amount']),
                    QrImage(
                      data: snapshot.data['code'],
                      size: 0.6 * bodyHeight,
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
          title: Text('Proof Of Payment'),
          centerTitle: true,
          automaticallyImplyLeading: false
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildAccountForm(context));
        })
      );
  }
}
