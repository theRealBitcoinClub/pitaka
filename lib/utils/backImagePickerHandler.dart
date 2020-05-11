import 'dart:io';
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
    _backListener.backImage(backImage);
  }

  openGallery() async {
    backImagePicker.dismissDialog();
    var backImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    _backListener.backImage(backImage);
  }

  void init() {
    backImagePicker = BackImagePickerDialog(this, _backController);
    backImagePicker.initState();
  }

  showDialog(BuildContext context) {
    backImagePicker.getImage(context);
  }
}

abstract class BackImagePickerListener {
  backImage(File _backImage);
}
