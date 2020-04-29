import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:scanbot_sdk/common_data.dart';
import 'package:scanbot_sdk/scanbot_sdk.dart';
import 'package:scanbot_sdk/scanbot_sdk_ui.dart';
import 'package:scanbot_sdk/scanbot_sdk_models.dart';
import 'package:scanbot_sdk/document_scan_data.dart';
import '../utils/globals.dart' as globals;
import '../api/endpoints.dart';


class VerifyIdentityComponent extends StatefulWidget {
  @override
  VerifyIdentityComponentState createState() => VerifyIdentityComponentState();
}

class VerifyIdentityComponentState extends State<VerifyIdentityComponent> {
  Image currentPreviewImageFront;
  Image currentPreviewImageBack;
  String base64ImageFront;
  String base64ImageBack;
  bool _loading = false;

  var config = DocumentScannerConfiguration(
    multiPageEnabled: false,
    bottomBarBackgroundColor: Colors.redAccent,
    cancelButtonTitle: "Cancel",
    polygonColor: Colors.redAccent,
    shutterButtonAutoOuterColor: Colors.red[600],
    shutterButtonManualOuterColor: Colors.red[600],
    orientationLockMode: CameraOrientationMode.PORTRAIT,
    maxNumberOfPages: 1,
    cameraPreviewMode: CameraPreviewMode.FILL_IN,
  );

  void scanDocumentFront() async {
    if (!await checkLicenseStatus()) {
      return;
    }

    var result1 = await ScanbotSdkUi.startDocumentScanner(config);

    if (result1.operationResult == OperationResult.SUCCESS) {
      // get and use the scanned images as pages: result.pages[n] ...
      displayPageImageFront(result1.pages[0]);
    }
  }

 void scanDocumentBack() async {
    if (!await checkLicenseStatus()) {
      return;
    }

    var result2 = await ScanbotSdkUi.startDocumentScanner(config);

    if (result2.operationResult == OperationResult.SUCCESS) {
      // get and use the scanned images as pages: result.pages[n] ...
      displayPageImageBack(result2.pages[0]);
    }
  }

  void displayPageImageFront(Page page) {
    setState(() {
      currentPreviewImageFront = Image.file(
        File.fromUri(page.documentPreviewImageFileUri),
        width: 300,
        height: 200,
      );
    });
    // Get the file path from the captured image
    var imageFrontPath = currentPreviewImageFront.image.toString().split('"')[1];

    // Load it from my filesystem
    File imagefileFront = new File(imageFrontPath); 

    // Convert image file to base64
    List<int> imageBytesFront = imagefileFront.readAsBytesSync();
    base64ImageFront = base64Encode(imageBytesFront);
    print("The front image base64 format is:");
    print(base64ImageFront);
  }

  void displayPageImageBack(Page page) {
    setState(() {
      currentPreviewImageBack = Image.file(
        File.fromUri(page.documentPreviewImageFileUri),
        width: 300,
        height: 200,
      );
    });

    // Get the file path from the captured image
    var imageFrontPath = currentPreviewImageBack.image.toString().split('"')[1];

    // Load it from my filesystem
    File imagefileFront = new File(imageFrontPath); 

    // Convert image file to base64
    List<int> imageBytesFront = imagefileFront.readAsBytesSync();
    base64ImageFront = base64Encode(imageBytesFront);
    print("The back image base64 format is:");
    print(base64ImageFront);
  }

  @override
  Widget build(BuildContext context) {
    ScanbotSdk.initScanbotSdk(ScanbotSdkConfig(
      loggingEnabled: true,
      licenseKey: globals.SCANBOT_SDK_LICENSE_KEY,
    ));
    // This method is rerun every time setState is called.
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Identity'),
      ),
      body: ListView(
        padding: EdgeInsets.all(12.0),
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 10.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(
                  "Scan your ID",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Container(
              height: 320.0,
              width: 350.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          "Front Image",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),                                                         
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 200.0,
                    width: 290,                                      
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child:
                      currentPreviewImageFront != null ?
                        currentPreviewImageFront
                      :
                        Container(),
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        child: Text(
                          "Scan Front ID Image",
                          style: TextStyle(color: Colors.white,),
                        ),
                        onPressed: scanDocumentFront,
                      ),
                    ),
                  ),
                ]
              ),
            ),

            SizedBox(height: 20.0),
            Container(
              height: 320.0,
              width: 350.0,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(3.0),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        child: Text(
                          "Back Image",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),                                                         
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    height: 200.0,
                    width: 290,                                      
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(3.0),
                    ),
                    child:
                      currentPreviewImageBack != null ?
                        currentPreviewImageBack
                      :
                        Container(),
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        child: Text(
                          "Scan Back ID Image",
                          style: TextStyle(color: Colors.white,),
                        ),
                        onPressed: scanDocumentBack,
                      ),
                    ),
                  ),
                ]
              ),
            ),
            SizedBox(height: 10.0),
            // Padding(
            //   padding: EdgeInsets.only(left: 22.0, right: 22.0),
              SizedBox(
                width: double.infinity,
                child: FlatButton(
                  color: Colors.red,
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white,),
                  ),
                  onPressed: _sendToServer,
                ),
              ),
            // or alternatively via short inline condition:
            // currentPreviewImage ?? Text("Image place holder"),
          ],
      ),
    );
  }

  _sendToServer() async {
    setState(() {
      _loading = true;
    });

    // Create the payload
    var payload = {
      'front_image': base64ImageFront,
      'back_image': base64ImageBack,
    };

   var response = await verifyDocument(payload);
    
    if (response.success) {
      // When response is success, dismiss loading progress
      setState(() {
        _loading = false;
      });
    }
  }

  Future<bool> checkLicenseStatus() async {
    var result = await ScanbotSdk.getLicenseStatus();
    if (result.isLicenseValid) {
      return true;
    }
    await showAlertDialog(
        message: 'Scanbot SDK trial period or license has expired.');
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
