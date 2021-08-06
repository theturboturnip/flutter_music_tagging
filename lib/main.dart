// @dart=2.9

import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'media_modules/hub.dart';

class MusicTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: "/",
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

        // TODO - / route should be a title page or something?
        ChildRoute("/", child: (_, args) => HomeWidget()),
        ChildRoute("/import", child: (_, args) => ModuleImportListWidget()),
      ];
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
              onPressed: () => Modular.to.pushNamed('/import'),
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
