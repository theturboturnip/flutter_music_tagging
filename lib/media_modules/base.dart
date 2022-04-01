import 'package:flutter_modular/flutter_modular.dart';

enum MediaModuleProvides { Import, ImportAndExport }

abstract class MediaModule extends Module {
  static final String routePrefix = "/modules";
  static final Map<String, MediaModule> knownMediaModules = Map();

  MediaModuleProvides providing;
  bool get canImport =>
      (providing == MediaModuleProvides.Import) ||
      (providing == MediaModuleProvides.ImportAndExport);

  MediaModule(this.providing) : super() {
    final id = mediaModuleID;
    assert(!knownMediaModules.containsKey(id));
    knownMediaModules[id] = this;
  }

  int get sortKey => 0;
  String get mediaModuleID;
  String get humanReadableName;
}

ModuleRoute mediaModuleRoute<T extends MediaModule>(T mediaModule) {
  return ModuleRoute(mediaModule.mediaModuleID, module: mediaModule);
}
