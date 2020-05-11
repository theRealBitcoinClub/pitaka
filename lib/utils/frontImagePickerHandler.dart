import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/frontImagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';


class FrontImagePickerHandler {
  FrontImagePickerDialog frontImagePicker;
  AnimationController _frontController;
  FrontImagePickerListener _frontListener;

  FrontImagePickerHandler(this._frontListener, this._frontController);

  openCamera() async {
    frontImagePicker.dismissDialog();
    var frontImage = await ImagePicker.pickImage(source: ImageSource.camera);
    _frontListener.frontImage(frontImage);
  }

  openGallery() async {
    frontImagePicker.dismissDialog();
    var frontImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    _frontListener.frontImage(frontImage);
  }

  void init() {
    frontImagePicker = FrontImagePickerDialog(this, _frontController);
    frontImagePicker.initState();
  }

  showDialog(BuildContext context) {
    frontImagePicker.getImage(context);
  }
}

abstract class FrontImagePickerListener {
  frontImage(File _frontImage);
}
