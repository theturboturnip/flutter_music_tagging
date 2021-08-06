import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_music_tagging/media_modules/base.dart';

import 'import_root.dart';

class AndroidDeviceMedia extends MediaModule {
  AndroidDeviceMedia() : super(MediaModuleProvides.Import);

  @override
  List<ModularRoute> get routes => [
        ModuleRoute("/import", module: ImportModule()),
        // ChildRoute("/export/:id",
        //     child: (_, args) => ExportPage(args.params['id'])),
      ];

  @override
  String get mediaModuleID => "android";

  @override
  String get humanReadableName => "Android Media";
}
