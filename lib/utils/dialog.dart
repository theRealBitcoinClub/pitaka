  
import 'package:flutter/material.dart';
import 'package:easy_dialog/easy_dialog.dart'; 
import 'package:url_launcher/url_launcher.dart'; 
import 'package:flutter/services.dart';


// Function that will redirect to Google Play Store 
// to download the latest version of Paytaca app 
_launchURL() async {
  const url = 'https://play.google.com/store/apps/details?id=com.paytaca.app&hl=en';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

onDialogClose() {
  // Not use
}
  
// Alert dialog for outdated app version
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
    height: 160,
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
              SystemNavigator.pop();
            },
            child: new Text("Ok",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              SystemNavigator.pop();
            },
            child: new Text("Cancel",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          ],)
    ]
  ).show(context, onDialogClose);
}

// Function that will redirect to Google Play Store 
// to download the latest version of Paytaca app 
_launchPaytacaURL() async {
  const url = 'https://www.paytaca.com/';
  if (await canLaunch(url)) {
    await launch(url, forceWebView: true);
  } else {
    throw 'Could not launch $url';
  }
}

// Alert dialog for unregistered device ID
showUnregisteredUdidDialog(context) {
  EasyDialog(
    title: Text(
      "Unregistered Device ID!",
      style: TextStyle(fontWeight: FontWeight.bold),
      textScaleFactor: 1.2,
    ),
    description: Text(
      "Your phone might have been compromised! Please contact Paytaca for assistance and support.",
      textScaleFactor: 1.1,
      textAlign: TextAlign.center,
    ),
    height: 160,
    closeButton: false,
    contentList: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new FlatButton(
            padding: EdgeInsets.all(8),
            textColor: Colors.lightBlue,
            onPressed: () {
              _launchPaytacaURL();
              SystemNavigator.pop();
            },
            child: new Text("Ok",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      )
    ]
  ).show(context, onDialogClose);
}