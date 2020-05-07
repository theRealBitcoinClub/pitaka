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
    loadImage(selfieImage);
  }

  openGallery() async {
    selfieImagePicker.dismissDialog();
    var selfieImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    loadImage(selfieImage);
  }

  void init() {
    selfieImagePicker = SelfieImagePickerDialog(this, _selfieController);
    selfieImagePicker.initState();
  }

  Future loadImage(File selfieImage) async {
    _selfieListener.selfieImage(selfieImage);
  }

  showDialog(BuildContext context) {
    selfieImagePicker.getImage(context);
  }
}

abstract class SelfieImagePickerListener {
  selfieImage(File _selfieImage);
}
