import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['album_id'],
      parentColumns: ['id'],
      entity: Album,
    )
  ],
)
class Song {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final BackendId backendId;

  final String title;
  final int lengthMs;

  @ColumnInfo(name: "album_id")
  final int? albumId;

  // Used to create from SQL-version
  Song(this.id, this.backendId, this.title, this.lengthMs, this.albumId);
  // Used to create from Dart/Flutter side
  Song.fromNew(this.backendId, this.title, this.lengthMs, this.albumId)
      : this.id = 0;
}

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['artist_id'],
      parentColumns: ['id'],
      entity: Artist,
    ),
  ],
)
class Album {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final BackendId backendId;

  final String title;
  final int trackCount;

  @ColumnInfo(name: "artist_id")
  final int artistId;

  Album(this.id, this.backendId, this.title, this.trackCount, this.artistId);
  // Used to create from Dart/Flutter side
  Album.fromNew(this.backendId, this.title, this.trackCount, this.artistId)
      : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['album_id'],
    parentColumns: ['id'],
    entity: Album,
  ),
  ForeignKey(
    childColumns: ['song_id'],
    parentColumns: ['id'],
    entity: Song,
  )
], primaryKeys: [
  // Can only have one element linked to index X of album_id
  "album_id",
  "index"
])
class AlbumEntry {
  @ColumnInfo(name: "album_id")
  final int albumId;
  @ColumnInfo(name: "song_id")
  final int songId;

  final int index;

  AlbumEntry(this.albumId, this.songId, this.index);
}

// Per-backend artist
// Could be remapped later?
@entity
class Artist {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final BackendId backendId;

  final String name;

  Artist(this.id, this.backendId, this.name);
  // Used to create from Dart/Flutter side
  Artist.fromNew(this.backendId, this.name) : this.id = 0;
}
