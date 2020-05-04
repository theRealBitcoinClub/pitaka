import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api/endpoints.dart';
import '../utils/image_picker_dialog.dart';
import '../utils/image_picker_handler.dart';


class VerifyIdentityComponent extends StatefulWidget {
  @override
  VerifyIdentityComponentState createState() => VerifyIdentityComponentState();
}

class VerifyIdentityComponentState extends State<VerifyIdentityComponent> 
    with TickerProviderStateMixin,ImagePickerListener {
  Image currentPreviewImageFront;
  Image currentPreviewImageBack;
  Image currentPreviewImageSelfie;
  String _frontIdImageBase64;
  String _backIdImageBase64;
  String _selfieImageBase64;
  String _dropDownValue;
  bool _loading = false;

  File _selfieImage;
  File _backIdImage;
  File _frontIdImage;

  File _image;

  AnimationController _controller;
  //ImagePickerHandler imagePicker;

  ImagePickerDialog imagePicker;

  Future scanFrontID() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _frontIdImage = image;
    });

    // Get the file path from the captured image
    var _frontIdImagePath = _frontIdImage.toString().split("'")[1];

    // Load it from my filesystem
    File _frontIdImagefile = new File(_frontIdImagePath); 

    // Convert image file to base64
    List<int> _frontIdImageBytes = _frontIdImagefile.readAsBytesSync();
    _frontIdImageBase64 = base64Encode(_frontIdImageBytes);
    print("The front image base64 format is:");
    print(_frontIdImageBase64);
  }

  Future scanBackID() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _backIdImage = image;
    });

    // Get the file path from the captured image
    var _backIdImagePath = _backIdImage.toString().split("'")[1];

    // Load it from my filesystem
    File _backIdImagefile = new File(_backIdImagePath); 

    // Convert image file to base64
    List<int> _backIdImageBytes = _backIdImagefile.readAsBytesSync();
    _backIdImageBase64 = base64Encode(_backIdImageBytes);
    print("The back image base64 format is:");
    print(_backIdImageBase64);
  }

  Future takeASelfie() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _selfieImage = image;
    });

    // Get the file path from the captured image
    var _selfieImagePath = _selfieImage.toString().split("'")[1];

    // Load it from my filesystem
    File _selfieImagefile = new File(_selfieImagePath); 

    // Convert image file to base64
    List<int> _selfieImageBytes = _selfieImagefile.readAsBytesSync();
    _selfieImageBase64 = base64Encode(_selfieImageBytes);
    print("The selfie image base64 format is:");
    print(_selfieImageBase64);
  }

  @override
  Widget build(BuildContext context) {
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
                  "Take a Selfie",
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
                          "Selfie Image",
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
                    child: _selfieImage != null ?
                        Image.file(_selfieImage)
                      :
                        Container()
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        child: Text(
                          "Take a Picture of your Face",
                          style: TextStyle(color: Colors.white,),
                        ),
                        onPressed: takeASelfie,
                      ),
                    ),
                  ),
                ]
              ),
            ),
            SizedBox(height: 30.0),
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
            SizedBox(height: 10.0),
            DropdownButton(
              hint: _dropDownValue == null ? 
                Text(
                  'Select ID Type',
                  style: TextStyle(fontWeight: FontWeight.bold,),
                )
                : 
                Text(
                  _dropDownValue,
                  style: TextStyle(color: Colors.red),
                ),
              isExpanded: true,
              iconSize: 30.0,
              items: [
                'DrivingLicense', 
                'IdentityCard', 
                'Passport',
                'VoterID'
              ].map(
                (val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text(val),
                  );
                },
              ).toList(),
              onChanged: (val) {
                setState(
                  () {
                    _dropDownValue = val;
                  },
                );
              },
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
                    child: _frontIdImage != null ?
                        Image.file(_frontIdImage)
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
                        onPressed: scanFrontID,
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
                    child: _backIdImage != null ?
                        Image.file(_backIdImage)
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
                        onPressed: scanBackID,
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
      'front_image': _frontIdImageBase64,
      'back_image': _backIdImageBase64,
      'live_photo': _selfieImageBase64,
      'document_type': "DrivingLicense",
    };

   var response = await verifyDocument(payload);
    
    if (response.success) {
      // When response is success, dismiss loading progress
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

}
