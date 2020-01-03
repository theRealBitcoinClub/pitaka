  
import 'package:flutter/material.dart';
import 'package:easy_dialog/easy_dialog.dart';  


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
              Navigator.of(context).pop();
            },
            child: new Text("OK",
              textScaleFactor: 1.2,
              textAlign: TextAlign.center,
            ),),
          ],)
    ]
  ).show(context, onDialogClose);
}