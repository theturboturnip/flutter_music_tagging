import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'raw_db.dart';
import 'unified_library_db.dart';
import 'folder_overlay_db.dart';

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
], views: [
  UnifiedSongRawAlbumId,
  UnifiedSongUnifiedAlbumId,
  UnifiedSongRawArtistId,
  UnifiedSongUnifiedArtistId,
  UnifiedAlbumRawArtistId,
  UnifiedAlbumUnifiedArtistId,
])
abstract class AppDatabase extends FloorDatabase {
  RawDataDao get rawDataDao;
  UnifiedDataDao get unifiedDataDao;
  DirDao get dirDao;
}
