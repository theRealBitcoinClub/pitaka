import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:overlay_support/overlay_support.dart';
import '../api/endpoints.dart';
import '../utils/dialogs.dart';
import '../utils/imagePickerHandler.dart';
import '../utils/frontImagePickerHandler.dart';
import '../utils/backImagePickerHandler.dart';


class VerifyIdentityComponent extends StatefulWidget {
  @override
  VerifyIdentityComponentState createState() => VerifyIdentityComponentState();
}

class VerifyIdentityComponentState extends State<VerifyIdentityComponent> 
    with TickerProviderStateMixin, ImagePickerListener, FrontImagePickerListener, 
    BackImagePickerListener {

  final _formKey = GlobalKey<FormState>();
  String _frontImageBase64;
  String _backImageBase64;
  String _imageBase64;
  String _documentType;
  bool _submitting = false;
  bool noSelfieErrorText = false;
  bool noFrontIdErrorText = false;
  bool noBackIdErrorText = false;
  File _image;
  File _frontImage;
  File _backImage;

  ImagePickerHandler imagePicker;
  FrontImagePickerHandler frontImagePicker;
  BackImagePickerHandler backImagePicker;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    imagePicker = ImagePickerHandler(this, _controller);
    imagePicker.init();

    frontImagePicker = FrontImagePickerHandler(this, _controller);
    frontImagePicker.init();

    backImagePicker = BackImagePickerHandler(this, _controller);
    backImagePicker.init();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Future takeASelfie() async {
  //   var image = await ImagePicker.pickImage(source: ImageSource.camera);

  //   setState(() {
  //     _selfieImage = image;
  //   });

  //   // Get the file path from the captured image
  //   var _selfieImagePath = _selfieImage.toString().split("'")[1];

  //   // Load it from my filesystem
  //   File _selfieImagefile = new File(_selfieImagePath); 

  //   // Convert image file to base64
  //   List<int> _selfieImageBytes = _selfieImagefile.readAsBytesSync();
  //   _selfieImageBase64 = base64Encode(_selfieImageBytes);
  //   print("The selfie image base64 format is:");
  //   print(_selfieImageBase64);
  // }

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
                    child: _image != null ?
                        Container(
                          height: 160.0,
                          width: 160.0,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: ExactAssetImage(_image.path),
                              fit: BoxFit.contain,
                            ),
                            border:
                                Border.all(color: Colors.red, width: 2.0),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(5.0)),
                          ),
                        )
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
                        onPressed: () => imagePicker.showDialog(context),
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
                      value: _documentType,
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
                            _documentType = val;
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
                    child: _frontImage != null ?
                        Container(
                          height: 160.0,
                          width: 160.0,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: ExactAssetImage(_frontImage.path),
                              fit: BoxFit.contain,
                            ),
                            border:
                                Border.all(color: Colors.red, width: 2.0),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(5.0)),
                          ),
                        )
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
                        onPressed: () => frontImagePicker.showDialog(context),
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
                    child: _backImage != null ?
                        Container(
                          height: 160.0,
                          width: 160.0,
                          decoration: BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: DecorationImage(
                              image: ExactAssetImage(_backImage.path),
                              fit: BoxFit.contain,
                            ),
                            border:
                                Border.all(color: Colors.red, width: 2.0),
                            borderRadius:
                                BorderRadius.all(const Radius.circular(5.0)),
                          ),
                        )
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
                        onPressed: () => backImagePicker.showDialog(context),
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
                      if (_image != null && _frontImage != null && _backImage != null
                          && _documentType != null) {
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
    // Set _submitting to true to show circular progress indicator
    setState(() {
      _submitting = true;
    });

    // Get the file path from the captured image
    var _imagePath = _image.toString().split("'")[1];
    var _frontImagePath = _frontImage.toString().split("'")[1];
    var _backImagePath = _backImage.toString().split("'")[1];

    // Load from filesystem
    File _imagefile = new File(_imagePath); 
    File _frontImagefile = new File(_frontImagePath);
    File _backImagefile = new File(_backImagePath);  

    // Convert image file to base64
    List<int> _imageBytes = _imagefile.readAsBytesSync();
    _imageBase64 = base64Encode(_imageBytes);

    List<int> _frontImageBytes = _frontImagefile.readAsBytesSync();
    _frontImageBase64 = base64Encode(_frontImageBytes);

    List<int> _backImageBytes = _backImagefile.readAsBytesSync();
    _backImageBase64 = base64Encode(_backImageBytes);


    // Create the payload
    var payload = {
      'front_image': _frontImageBase64,
      'back_image': _backImageBase64,
      'live_photo': _imageBase64,
      'document_type': _documentType,
    };

    var response = await verifyDocument(payload);
    
    if (response.success) {
      // When response is success, dismiss loading progress
      setState(() {
        _submitting = false;
      });
      // Show dialog
      showIdentitySubmitSuccesslDialog(context);
    }
  }

  @override
  userImage(File _image) {
    setState(() {
      this._image = _image;
    });
  }

  @override
  frontImage(File _frontImage) {
    setState(() {
      this._frontImage = _frontImage;
    });
  }

  @override
  backImage(File _backImage) {
    setState(() {
      this._backImage = _backImage;
    });
  }

}
