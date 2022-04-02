import 'dart:async';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:flutter_music_tagging/database/pre_import.dart';
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
  ImporterDao get importerDao;

  static Future<AppDatabase> getConnection() {
    return $FloorAppDatabase.databaseBuilder('app_database.db').build();
    // return $FloorAppDatabase.inMemoryDatabaseBuilder().build();
  }

  Future<void> deleteAll() async {
    IList<String> tables = [
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
    ].map((e) => e.toString()).toIList();
    for (var table in tables) {
      await database.delete(table, where: null);
    }
  }
}

abstract class DatabaseRepository {
  RawDataDao get rawDataDao;
  UnifiedDataDao get unifiedDataDao;
  DirDao get dirDao;
  TagDao get tagDao;
  ImporterDao get importerDao;
}
