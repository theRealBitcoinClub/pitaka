import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import '../router/routes.dart';

class AppComponent extends StatefulWidget {
  @override
  State createState() {
    return new AppComponentState();
  }
}

class Application {
  static Router router;
}

class AppComponentState extends State<AppComponent> {
  static bool debugMode = false;

  AppComponentState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
  }

  @override
  Widget build(BuildContext context) {
    final app = new MaterialApp(
      title: 'Paytaca',
      debugShowCheckedModeBanner: debugMode,
      theme: new ThemeData(
        primarySwatch: Colors.red,
      ),
      onGenerateRoute: Application.router.generator,
    );
    return app;
  }
}
