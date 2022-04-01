import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'raw_db.dart';
import 'unified_library_db.dart';
import 'folder_overlay_db.dart';
import 'tag_overlay_db.dart';

part 'database.g.dart'; // the generated code will be there

@TypeConverters([BackendIdConverter])
@Database(version: 1, entities: [
  RawSong,
  RawSongArtist,
  RawAlbum,
  RawAlbumArtist,
  RawAlbumEntry,
  RawArtist,
  UnifiedSong,
  UnifiedAlbum,
  UnifiedAlbumEntry,
  UnifiedArtist,
  DirTreeNode,
  Tag,
  TagDirJoin,
  TagAlbumJoin,
  TagArtistJoin,
  TagSongJoin,
], views: [
  UnifiedSongRawAlbumId,
  UnifiedSongUnifiedAlbumId,
  UnifiedSongRawArtistId,
  UnifiedSongUnifiedArtistId,
  UnifiedAlbumRawArtistId,
  UnifiedAlbumUnifiedArtistId,
])
abstract class AppDatabase extends FloorDatabase implements DatabaseRepository {
  RawDataDao get rawDataDao;
  UnifiedDataDao get unifiedDataDao;
  DirDao get dirDao;
  TagDao get tagDao;

  static Future<AppDatabase> getConnection() {
    return $FloorAppDatabase.databaseBuilder('app_database.db').build();
  }
}

abstract class DatabaseRepository {
  RawDataDao get rawDataDao;
  UnifiedDataDao get unifiedDataDao;
  DirDao get dirDao;
  TagDao get tagDao;
}
