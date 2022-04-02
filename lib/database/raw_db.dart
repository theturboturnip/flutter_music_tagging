import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

import 'unified_library_db.dart';

/// This file contains Entities and DAOs for "raw" data - media metadata as
/// imported from a single backend.

@Entity(foreignKeys: [
  ForeignKey(
      childColumns: ['unified_id'], parentColumns: ['id'], entity: UnifiedSong)
])
class RawSong {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "backend_id")
  final BackendId backendId;

  @ColumnInfo(name: "unified_id")
  final int? unifiedId;

  final String title;
  final int lengthMs;

  // Used to create from SQL-version
  RawSong(this.id, this.backendId, this.unifiedId, this.title, this.lengthMs);
  // Used to create from Dart/Flutter side
  RawSong.fromNew(this.backendId, this.unifiedId, this.title, this.lengthMs)
      : this.id = null;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['song_id'],
    parentColumns: ['id'],
    entity: RawSong,
  ),
  ForeignKey(
    childColumns: ['artist_id'],
    parentColumns: ['id'],
    entity: RawArtist,
  )
], primaryKeys: [
  // Can only have one element linking song X and artist Y
  "song_id",
  "artist_id"
])
class RawSongArtist {
  @ColumnInfo(name: "song_id")
  final int songId;
  @ColumnInfo(name: "artist_id")
  final int artistId;

  RawSongArtist(this.songId, this.artistId);
}

@Entity(foreignKeys: [
  ForeignKey(
      childColumns: ['unified_id'], parentColumns: ['id'], entity: UnifiedAlbum)
])
class RawAlbum {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "backend_id")
  final BackendId backendId;

  @ColumnInfo(name: "unified_id")
  final int? unifiedId;

  final String title;
  final int trackCount;

  RawAlbum(
      this.id, this.backendId, this.unifiedId, this.title, this.trackCount);
  // Used to create from Dart/Flutter side
  RawAlbum.fromNew(this.backendId, this.unifiedId, this.title, this.trackCount)
      : this.id = null;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['album_id'],
    parentColumns: ['id'],
    entity: RawAlbum,
  ),
  ForeignKey(
    childColumns: ['song_id'],
    parentColumns: ['id'],
    entity: RawSong,
  )
], primaryKeys: [
  // Can only have one element linked to index X of album_id
  "album_id",
  "index"
])
class RawAlbumEntry {
  @ColumnInfo(name: "album_id")
  final int albumId;
  @ColumnInfo(name: "song_id")
  final int songId;

  final int index;

  RawAlbumEntry(this.albumId, this.songId, this.index);
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['album_id'],
    parentColumns: ['id'],
    entity: RawAlbum,
  ),
  ForeignKey(
    childColumns: ['artist_id'],
    parentColumns: ['id'],
    entity: RawArtist,
  )
], primaryKeys: [
  // Can only have one element linking album X and artist Y
  "album_id",
  "artist_id"
])
class RawAlbumArtist {
  @ColumnInfo(name: "album_id")
  final int albumId;
  @ColumnInfo(name: "artist_id")
  final int artistId;

  RawAlbumArtist(this.albumId, this.artistId);
}

@Entity(foreignKeys: [
  ForeignKey(
      childColumns: ['unified_id'],
      parentColumns: ['id'],
      entity: UnifiedArtist)
])
class RawArtist {
  @PrimaryKey(autoGenerate: true)
  final int? id;

  @ColumnInfo(name: "backend_id")
  final BackendId backendId;

  @ColumnInfo(name: "unified_id")
  final int? unifiedId;

  final String name;

  RawArtist(this.id, this.backendId, this.unifiedId, this.name);
  // Used to create from Dart/Flutter side
  RawArtist.fromNew(this.backendId, this.unifiedId, this.name) : this.id = null;
}

@dao
abstract class RawDataDao {
  @Query("SELECT * FROM RawAlbum where albumId = :id")
  Future<RawAlbum?> getRawAlbum(int id);
}
