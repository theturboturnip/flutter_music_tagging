import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:collection/collection.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';

import 'android_device/android_device.dart';
import 'base.dart';

class MediaModuleHub extends Module {
  static MediaModuleHub _instance = MediaModuleHub._internal();

  factory MediaModuleHub() => _instance;

  MediaModuleHub._internal();

  final List<MediaModule> modules = [
    AndroidDeviceMedia(),
  ];

  @override
  List<ModularRoute> get routes =>
      modules.map((m) => MediaModuleRoute(m)).toList();
}

class MediaModuleHubRoute extends ModuleRoute {
  MediaModuleHubRoute()
      : super(MediaModule.routePrefix, module: MediaModuleHub());
}

class ModuleImportListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moduleList = MediaModule.knownMediaModules.values
        .where((m) => m.canImport)
        .sorted((a, b) => a.sortKey - b.sortKey)
        .toIList();

    return Scaffold(
      appBar: AppBar(title: const Text("Import from...")),
      body: ListView.builder(
        itemCount: moduleList.length,
        itemBuilder: (context, i) => Material(
          child: Card(
            child: InkWell(
              onTap: () {
                Modular.to.pushNamed(
                    '${MediaModule.routePrefix}/${moduleList[i].mediaModuleID}/import');
              },
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Import from ${moduleList[i].humanReadableName}',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
