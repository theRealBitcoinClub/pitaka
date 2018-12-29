import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart' show rootBundle;

class TermsComponent extends StatefulWidget {
  @override
  TermsComponentState createState() => new TermsComponentState();
}

class TermsComponentState extends State<TermsComponent> {
  String _markdownData;

  void getFileData() async {
    String path = 'assets/texts/terms_and_conditions.txt';
    String data = await rootBundle.loadString(path);
    setState(() {
      _markdownData = data;
    });
  }

  List<Widget> _buildTerms(BuildContext context) {
    var ws = new List<Widget>();
    if (_markdownData != null) {
      Markdown mk = new Markdown(data: _markdownData);
      ws.add(mk);
    } else {
      Opacity opc = new Opacity(
        opacity: 0.8,
        child: const ModalBarrier(dismissible: false, color: Colors.grey),
      );
      ws.add(opc);
      Center prog = new Center(
        child: new CircularProgressIndicator(),
      );
      ws.add(prog);
    }
    return ws;
  }

  @override
  void initState() {
    super.initState();
    getFileData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Terms and Conditions'),
          centerTitle: true,
        ),
        body: new Builder(builder: (BuildContext context) {
          return new Stack(children: _buildTerms(context));
        }));
  }
}
