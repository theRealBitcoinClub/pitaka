import 'package:flutter/material.dart';
import '../views/app.dart';

Map inverse(Map f) {
  return f.map((k, v) => MapEntry(v, k));
}

BottomNavigationBar buildBottomNavigation(BuildContext context, String path) {
  var indexMap = new Map();
  indexMap[0] = "/home";
  indexMap[1] = "/send";
  indexMap[2] = "/receive";

  int _currentIndex = inverse(indexMap)[path];

  void onTabTapped(int index) {
    String destination = indexMap[index];
    Application.router.navigateTo(context, destination);
  }

  return BottomNavigationBar(
    currentIndex: _currentIndex,
    onTap: onTabTapped,
    items: [
      new BottomNavigationBarItem(
        icon: Icon(Icons.home),
        title: Text('Home'),
      ),
      new BottomNavigationBarItem(
        icon: Icon(Icons.send),
        title: Text('Send'),
      ),
      new BottomNavigationBarItem(
          icon: Icon(Icons.inbox), title: Text('Receive'))
    ],
  );
}
