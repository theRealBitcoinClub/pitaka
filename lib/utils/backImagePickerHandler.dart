import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/backImagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';


class BackImagePickerHandler {
  BackImagePickerDialog backImagePicker;
  AnimationController _backController;
  BackImagePickerListener _backListener;

  BackImagePickerHandler(this._backListener, this._backController);

  openCamera() async {
    backImagePicker.dismissDialog();
    var backImage = await ImagePicker.pickImage(source: ImageSource.camera);
    loadImage(backImage);
  }

  openGallery() async {
    backImagePicker.dismissDialog();
    var backImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    loadImage(backImage);
  }

  void init() {
    backImagePicker = BackImagePickerDialog(this, _backController);
    backImagePicker.initState();
  }

  Future loadImage(File backImage) async {
    _backListener.backImage(backImage);
  }

  showDialog(BuildContext context) {
    backImagePicker.getImage(context);
  }
}

abstract class BackImagePickerListener {
  backImage(File _backImage);
}
