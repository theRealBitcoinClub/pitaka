import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../components/home.dart';

var rootHandler = new Handler(
    handlerFunc: (BuildContext context, Map<String, List<String>> params) {
  return new HomeComponent();
});
