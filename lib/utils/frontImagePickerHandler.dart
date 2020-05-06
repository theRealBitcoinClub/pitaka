import 'dart:io';
import 'dart:async';
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
    loadImage(frontImage);
  }

  openGallery() async {
    frontImagePicker.dismissDialog();
    var frontImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    loadImage(frontImage);
  }

  void init() {
    frontImagePicker = FrontImagePickerDialog(this, _frontController);
    frontImagePicker.initState();
  }

  Future loadImage(File frontImage) async {
    _frontListener.frontImage(frontImage);
  }

  showDialog(BuildContext context) {
    frontImagePicker.getImage(context);
  }
}

abstract class FrontImagePickerListener {
  frontImage(File _frontImage);
}
