import 'package:flutter/material.dart';
import '../components/drawer.dart';


class SettingsComponent extends StatefulWidget {
  @override
  State createState() => new SettingsComponentState();
  }

class SettingsComponentState extends State<SettingsComponent> {
  String path = '/settings';

  Widget bodyFunc() {
    return new Container(
      constraints: BoxConstraints.expand(
        height: Theme.of(context).textTheme.display1.fontSize * 1.1 + 200.0,
      ),
      padding: const EdgeInsets.all(8.0),
      color: Colors.blue[600],
      alignment: Alignment.center,
      child: Text('Hello World',
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white)),
      transform: Matrix4.rotationZ(0.1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),

      ),
      body: bodyFunc(),
      drawer: buildDrawer(context),
    );
  }
}