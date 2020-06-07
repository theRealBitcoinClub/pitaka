import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/frontImagePickerHandler.dart';


class FrontImagePickerDialog extends StatelessWidget {

  FrontImagePickerHandler _frontListener;
  AnimationController _frontController;
  BuildContext context;

  FrontImagePickerDialog(this._frontListener, this._frontController);

  Animation<double> _drawerContentsOpacity;
  Animation<Offset> _drawerDetailsPosition;

  void initState() {
    _drawerContentsOpacity = CurvedAnimation(
      parent: ReverseAnimation(_frontController),
      curve: Curves.fastOutSlowIn,
    );
    _drawerDetailsPosition = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _frontController,
      curve: Curves.fastOutSlowIn,
    ));
  }

  getImage(BuildContext context) {
    if (_frontController == null ||
        _drawerDetailsPosition == null ||
        _drawerContentsOpacity == null) {
      return;
    }
    _frontController.forward();
    showDialog(
      context: context,
      builder: (BuildContext context) => SlideTransition(
            position: _drawerDetailsPosition,
            child: FadeTransition(
              opacity: ReverseAnimation(_drawerContentsOpacity),
              child: this,
            ),
          ),
    );
  }

  void dispose() {
    _frontController.dispose();
  }

  startTime() async {
    var _duration = Duration(milliseconds: 200);
    return new Timer(_duration, navigationPage);
  }

  void navigationPage() {
    Navigator.pop(context);
  }

  dismissDialog() {
    _frontController.reverse();
    startTime();
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Material(
        type: MaterialType.transparency,
        child: Opacity(
          opacity: 1.0,
          child: Container(
            padding: EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  onTap: () => _frontListener.openCamera(),
                  child: roundedButton(
                      "Take a Photo",
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFFF44336),
                      const Color(0xFFFFFFFF)),
                ),
                GestureDetector(
                  onTap: () => _frontListener.openGallery(),
                  child: roundedButton(
                      "Choose from Gallery",
                      EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                      const Color(0xFFF44336),
                      const Color(0xFFFFFFFF)),
                ),
                const SizedBox(height: 15.0),
                GestureDetector(
                  onTap: () => dismissDialog(),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    child: roundedButton(
                        "Cancel",
                        EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                        const Color(0xFFF44336),
                        const Color(0xFFFFFFFF)),
                  ),
                ),
              ],
            ),
          ),
        )
      );
  }

  Widget roundedButton(
      String buttonLabel, EdgeInsets margin, Color bgColor, Color textColor) {
    var loginBtn = Container(
      margin: margin,
      padding: EdgeInsets.all(15.0),
      alignment: FractionalOffset.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.all(const Radius.circular(5.0)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF696969),
            offset: Offset(1.0, 6.0),
            blurRadius: 0.001,
          ),
        ],
      ),
      child: Text(
        buttonLabel,
        style: TextStyle(
          color: textColor, 
          fontSize: 18.0, 
        ),
      ),
    );

    return loginBtn;
  }

}
