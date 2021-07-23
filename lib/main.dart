// @dart=2.9

import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:rxdart/rxdart.dart';

import 'main_apps.dart';

class Routes {
  static const Home = "/";
  static const Import = "$PrefixImport$ImportBase";

  static const PrefixImport = "/import";

  static const ImportBase = "/populate";
  static const ImportAlbums = "/propose_merge";
}

void main() {
  runApp(MusicTaggingApp());
}
