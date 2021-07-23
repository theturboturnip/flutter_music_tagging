import 'package:flutter/material.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'ui/ui.dart';

class MusicTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImportPopulatePage(),
      initialRoute: "/",
    ).modular();
  }
}
