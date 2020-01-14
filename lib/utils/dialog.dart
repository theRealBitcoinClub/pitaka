  
import 'package:flutter/material.dart';
import 'package:easy_dialog/easy_dialog.dart'; 
import 'package:url_launcher/url_launcher.dart'; 


_launchURL() async {
  const url = 'https://play.google.com/store/apps/details?id=com.paytaca.app&hl=en';
  if (await canLaunch(url)) {
    await launch(url, forceSafariVC: false);
  } else {
    throw 'Could not launch $url';
  }
}

onDialogClose() {
  // Not use
}
  
// Alert dialog outdated app version
showOutdatedAppVersionDialog(context) {
  EasyDialog(
    title: Text(
      "Outdated App Version!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "The app version you're running is outdated. Update your app to continue using and enjoy the latest features.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 460,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              _launchURL();
            },
            child: new Text("Ok",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: new Text("Cancel",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          ],)
    ]
  ).show(context, onDialogClose);
}