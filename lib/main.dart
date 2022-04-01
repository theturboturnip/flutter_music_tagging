// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:splashscreen/splashscreen.dart';

import 'media_modules/hub.dart';
import 'permissions.dart';

class MusicTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/splash",
    ).modular();
  }
}

class AppModule extends Module {
  // Provide a list of dependencies to inject into your project
  @override
  List<Bind> get binds => [];

  // Provide all the routes for your module
  @override
  List<ModularRoute> get routes => [
        // Top-level route hub for all connected media modules
        MediaModuleHubRoute(),

        ChildRoute("/splash", child: (_, args) => SplashWidget()),
        ModuleRoute("/permissions", module: PermissionModule()),
        ChildRoute("/home", child: (_, args) => HomeWidget()),
        ChildRoute("/import", child: (_, args) => ModuleImportListWidget()),
      ];
}

class SplashWidget extends StatefulWidget {
  @override
  _SplashState createState() => new _SplashState();
}

class _SplashState extends State<SplashWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(lookupPermissions);
  }

  void lookupPermissions(Duration timestamp) async {
    var route = "/permissions";
    if (await hasAllPermissions()) {
      route = "/home";
    }
    Modular.to.navigate(route);
  }

  @override
  Widget build(BuildContext context) {
    return new SplashScreen(
        title: new Text(
          'TurnipTagging',
          style: new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        loaderColor: Colors.red);
  }
}

class HomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Turnip Tagging")),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                Modular.to.navigate('/import');
              },
              child: const Text("Import Music"),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(ModularApp(module: AppModule(), child: MusicTaggingApp()));
}
