import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import "package:hex/hex.dart";
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:local_auth/local_auth.dart';
import 'package:scanbot_sdk/common_data.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:scanbot_sdk/scanbot_sdk_ui.dart';
import 'package:scanbot_sdk/scanbot_sdk_models.dart';
import 'package:scanbot_sdk/document_scan_data.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/dialogs.dart';
import './../api/endpoints.dart';
import './../utils/helpers.dart';
import '../utils/globals.dart' as globals;
import '../views/app.dart';

const SCANBOT_SDK_LICENSE_KEY =
  "eV1Zf7LUb4lYV7gKEx2akrpqgmGtiA" +
  "PSeoarA1NdoYZAqPnsRTLphoMkecn0" +
  "koVs2ij0qQjvJGVAPN3+BescgZ84X6" +
  "upjZuQBEbFpde0dc7Kht+0mNA6qYBX" +
  "7k+VQdsbFa8lXgeaa4k3oqLE0qq9zE" +
  "3JU/KWUASoLnPuGvWNqy1xllnuj6Bj" +
  "dRZv8gWlWAW3d/2KyL/rIh6etv7tAS" +
  "FhZQQg4Zhb/usWHC3PkrALKHjIlrQK" +
  "kXkPNeIx/tY8wSrRMHE942RxWgYlWl" +
  "vqlTsIR7v+LC4B/RzW1TMu+/DaKKJa" +
  "7tefAz6qxfEhGmzMP1APnY4m3NQ9Ea" +
  "/+EErqxOoDMw==\nU2NhbmJvdFNESw" +
  "pjb20ucGF5dGFjYS5hcHAKMTU5MDcx" +
  "MDM5OQo1OTAKMw==\n";

class VerifyIdentityComponent extends StatefulWidget {
  VerifyIdentityComponent({Key key, this.title}) : super(key: key);

  final String title;

  @override
  VerifyIdentityComponentState createState() =>
      VerifyIdentityComponentState();
}

class VerifyIdentityComponentState extends State<VerifyIdentityComponent> {

  Image currentPreviewImage;

  void scanDocument() async {
    if (!await checkLicenseStatus()) { return; }

    var config = DocumentScannerConfiguration(
      multiPageEnabled: false,
      bottomBarBackgroundColor: Colors.blueAccent,
      cancelButtonTitle: "Cancel",
      // see further configs ...
    );
    var result = await ScanbotSdkUi.startDocumentScanner(config);

    if (result.operationResult == OperationResult.SUCCESS) {
      // get and use the scanned images as pages: result.pages[n] ...
      displayPageImage(result.pages[0]);
    }
  }

  void displayPageImage(Page page) {
    setState(() {
      currentPreviewImage = Image.file(
          File.fromUri(page.documentPreviewImageFileUri), width: 300, height: 300);
    });
  }

  @override
  Widget build(BuildContext context) {
    ScanbotSdk.initScanbotSdk(ScanbotSdkConfig(
      loggingEnabled: true,
      licenseKey: SCANBOT_SDK_LICENSE_KEY,
    ));
    // This method is rerun every time setState is called.
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Identity'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text("Scan a Document"),
              onPressed: scanDocument,
            ),
            if (currentPreviewImage != null) ... [
              Text("Document image:"),
              currentPreviewImage,
            ],
            // or alternatively via short inline condition:
            // currentPreviewImage ?? Text("Image place holder"),
          ],
        ),
      ),
    );
  }

  Future<bool> checkLicenseStatus() async {
    var result = await ScanbotSdk.getLicenseStatus();
    if (result.isLicenseValid) {
      return true;
    }
    await showAlertDialog(message: 'Scanbot SDK trial period or license has expired.');
    return false;
  }

  Future<void> showAlertDialog({String title = 'Info', String message}) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
