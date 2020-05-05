import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import '../api/endpoints.dart';
import '../utils/image_picker_dialog.dart';
import '../utils/image_picker_handler.dart';


class VerifyIdentityComponent extends StatefulWidget {
  @override
  VerifyIdentityComponentState createState() => VerifyIdentityComponentState();
}

class VerifyIdentityComponentState extends State<VerifyIdentityComponent> 
    with TickerProviderStateMixin,ImagePickerListener {

  final _formKey = GlobalKey<FormState>();
  String _frontIdImageBase64;
  String _backIdImageBase64;
  String _selfieImageBase64;
  String _dropDownValue;
  bool _submitting = false;
  bool noSelfieErrorText = false;
  bool noFrontIdErrorText = false;
  bool noBackIdErrorText = false;
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Identity'),
      ),
      body: Builder(builder: (BuildContext context) {
        return Stack(children: _buildRegistrationForm(context));
      })
    );
  }

  List<Widget> _buildRegistrationForm(BuildContext context) {
    Form form = Form(
      key: _formKey,
      child: ListView(
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
                        Visibility(
                          visible: noSelfieErrorText,
                          child: Center(
                            child: Text(
                              "Selfie picture is required!",
                              style: TextStyle(color: Colors.red,),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
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
            FormField(
              validator: (value){
                if (value == null) {
                  return 'This field is required.';
                } else {
                  return null;
                }
              },
              builder: (FormFieldState state) {
                return InputDecorator(
                  decoration: InputDecoration(
                    errorText: state.errorText,
                  ),
                  child: new DropdownButtonHideUnderline(
                    child: DropdownButton(
                      hint: Text('Select ID Type'),
                      iconEnabledColor: Colors.red,
                      value: _dropDownValue,
                      isExpanded: true,
                      isDense: true,
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
                  )
                );
              }
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
                        Visibility(
                          visible: noFrontIdErrorText,
                          child: Center(
                            child: Text(
                              "Front ID picture is required!",
                              style: TextStyle(color: Colors.red,),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
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
                        Visibility(
                          visible: noBackIdErrorText,
                          child: Center(
                            child: Text(
                              "Back ID picture is required!",
                              style: TextStyle(color: Colors.red,),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        )
                  ),
                  SizedBox(height: 5.0),
                  Padding(
                    padding: EdgeInsets.only(left: 22.0, right: 22.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: FlatButton(
                        color: Colors.red,
                        splashColor: Colors.red[100],
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
                  splashColor: Colors.red[100],
                  child: Text(
                    "Submit",
                    style: TextStyle(color: Colors.white,),
                  ),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {}
                      if (_selfieImage != null && _frontIdImage != null && _backIdImage != null
                          && _dropDownValue != null) {
                        _sendToServer();
                      } else {
                        setState(() {
                          noSelfieErrorText = true;
                          noFrontIdErrorText = true;
                          noBackIdErrorText = true;                          
                        });
                        showSimpleNotification(
                          Text("Please correct errors below."),
                          background: Colors.red[600],
                        );
                      }
                  }
                ),
              ),
          ],
      ),
    );

    var ws = new List<Widget>();
    ws.add(form);

    if (_submitting) {
      var modal = new Stack(
        children: [
          new Opacity(
            opacity: 0.8,
            child: const ModalBarrier(dismissible: false, color: Colors.grey),
          ),
          new Center(
            child: new CircularProgressIndicator(),
          ),
        ],
      );
      ws.add(modal);
    }

    return ws;

  }

  _sendToServer() async {
    setState(() {
      _submitting = true;
    });

    // Create the payload
    var payload = {
      'front_image': _frontIdImageBase64,
      'back_image': _backIdImageBase64,
      'live_photo': _selfieImageBase64,
      'document_type': _dropDownValue,
    };

  var response = await verifyDocument(payload);
    
    if (response.success) {
      // When response is success, dismiss loading progress
      setState(() {
        _submitting = false;
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
