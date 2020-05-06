import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../utils/imagePickerDialog.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerHandler {
  ImagePickerDialog imagePicker;
  AnimationController _controller;
  ImagePickerListener _listener;

  ImagePickerHandler(this._listener, this._controller);

  openCamera() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    loadImage(image);
  }

  openGallery() async {
    imagePicker.dismissDialog();
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    loadImage(image);
  }

  void init() {
    imagePicker = ImagePickerDialog(this, _controller);
    imagePicker.initState();
  }

  Future loadImage(File image) async {
    _listener.userImage(image);
  }

  showDialog(BuildContext context) {
    imagePicker.getImage(context);
  }
}

abstract class ImagePickerListener {
  userImage(File _image);
}
