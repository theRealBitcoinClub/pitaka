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
        icon: Icon(Icons.account_balance_wallet),
        title: Text('Accounts'),
      ),
      new BottomNavigationBarItem(
        icon: Icon(Icons.send),
        title: Text('Pay'),
      ),
      new BottomNavigationBarItem(
          icon: Icon(Icons.inbox), title: Text('QR Code'))
    ],
  );
}
