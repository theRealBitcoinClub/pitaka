import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/selfieImagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';

class SelfieImagePickerHandler {
  SelfieImagePickerDialog selfieImagePicker;
  AnimationController _selfieController;
  SelfieImagePickerListener _selfieListener;

  SelfieImagePickerHandler(this._selfieListener, this._selfieController);

  openCamera() async {
    selfieImagePicker.dismissDialog();
    var selfieImage = await ImagePicker.pickImage(source: ImageSource.camera);
    _selfieListener.selfieImage(selfieImage);
  }

  openGallery() async {
    selfieImagePicker.dismissDialog();
    var selfieImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    _selfieListener.selfieImage(selfieImage);
  }

  void init() {
    selfieImagePicker = SelfieImagePickerDialog(this, _selfieController);
    selfieImagePicker.initState();
  }

  showDialog(BuildContext context) {
    selfieImagePicker.getImage(context);
  }
}

abstract class SelfieImagePickerListener {
  selfieImage(File _selfieImage);
}
