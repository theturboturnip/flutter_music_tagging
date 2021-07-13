import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

// TODO - We need to change how backend IDs work.
// Before, I had 1:1 Song:BackendID
// but this has a problem when multiple services can have the same song
// e.g. I could have a CD that's also available on Spotify.
// Those should be treated as the same song by the app.
// => there's a 1:Many Song:BackendID mapping, and this also holds for Albums + Artists.
// Additionally, for each backend, there may exist multiple items -> same artist

abstract class BackendRow<T> {
  @PrimaryKey()
  @ColumnInfo(name: "base_id")
  final int baseId;

  @ColumnInfo(name: "backend_id")
  final BackendId backendId;

  BackendRow(this.baseId, this.backendId);
}

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

  final String title;
  final int lengthMs;

  @ColumnInfo(name: "album_id")
  final int? albumId;

  // Used to create from SQL-version
  Song(this.id, this.title, this.lengthMs, this.albumId);
  // Used to create from Dart/Flutter side
  Song.fromNew(this.title, this.lengthMs, this.albumId) : this.id = 0;
}

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['base_id'],
      parentColumns: ['id'],
      entity: Song,
    )
  ],
)
class Song_BackendRow extends BackendRow<Song> {
  Song_BackendRow(int baseId, BackendId backendId) : super(baseId, backendId);
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

  final String title;
  final int trackCount;

  @ColumnInfo(name: "artist_id")
  final int artistId;

  Album(this.id, this.title, this.trackCount, this.artistId);
  // Used to create from Dart/Flutter side
  Album.fromNew(this.title, this.trackCount, this.artistId) : this.id = 0;
}

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['base_id'],
      parentColumns: ['id'],
      entity: Album,
    )
  ],
)
class Album_BackendRow extends BackendRow<Album> {
  Album_BackendRow(int baseId, BackendId backendId) : super(baseId, backendId);
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

@entity
class Artist {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  Artist(this.id, this.name);
  // Used to create from Dart/Flutter side
  Artist.fromNew(this.name) : this.id = 0;
}

@Entity(
  foreignKeys: [
    ForeignKey(
      childColumns: ['base_id'],
      parentColumns: ['id'],
      entity: Album,
    )
  ],
)
class Artist_BackendRow extends BackendRow<Artist> {
  Artist_BackendRow(int baseId, BackendId backendId) : super(baseId, backendId);
}
