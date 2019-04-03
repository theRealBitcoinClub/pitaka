import 'package:flutter/material.dart';
// import '../api/endpoints.dart';
import '../views/app.dart';
import 'package:flutter_keychain/flutter_keychain.dart';


class ProofOfPaymentComponent extends StatefulWidget {
  @override
  ProofOfPaymentComponentState createState() => new ProofOfPaymentComponentState();
}

class ProofOfPaymentComponentState extends State<ProofOfPaymentComponent> {

  Future<String> getVal() async {
    var x = await FlutterKeychain.get(key: "_txnQrCode");
    return x.toString();
  }

  List<Widget> _buildAccountForm(BuildContext context) {
    Form form = new Form(
      child: new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new SizedBox(
            height: 30.0,
          ),
          Text("${getVal()}"),
          new RaisedButton(
            onPressed: () {
              var x = getVal();
              print(x);
              Application.router.navigateTo(context, '/home');
              },
            child: new Text('Continue'),
          )
        ],
      ));
    var ws = new List<Widget>();
    ws.add(form);

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
