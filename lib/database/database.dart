import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'daos.dart';
import 'models.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters([BackendIdConverter])
@Database(version: 1, entities: [
  Song,
  Song_BackendRow,
  Album,
  Album_BackendRow,
  AlbumEntry,
  Artist,
  Artist_BackendRow
])
abstract class AppDatabase extends FloorDatabase {
  SongDao get songDao;
  AlbumDao get albumDao;
  ArtistDao get artistDao;
}
