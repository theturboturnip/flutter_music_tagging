import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

// TODO - Change to use backendId as primary key where applicable

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
  "album_id",
  "song_id"
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

@entity
class Playlist {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final BackendId backendId;

  final String name;
  final int trackCount;

  Playlist(this.id, this.backendId, this.name, this.trackCount);
  // Used to create from Dart/Flutter side
  Playlist.fromNew(this.backendId, this.name, this.trackCount) : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['playlist_id'],
    parentColumns: ['id'],
    entity: Playlist,
  ),
  ForeignKey(
    childColumns: ['song_id'],
    parentColumns: ['id'],
    entity: Song,
  )
],
    // Songs can repeat in a playlist, so just (playlist, song) isn't unique
    primaryKeys: [
      "playlist_id",
      "song_id",
      "index"
    ])
class PlaylistEntry {
  @ColumnInfo(name: "playlist_id")
  final int playlistId;
  @ColumnInfo(name: "song_id")
  final int songId;

  final int index;

  PlaylistEntry(this.index, this.playlistId, this.songId);
}

@entity
class Folder {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  Folder(this.id, this.name);
  // Used to create from Dart/Flutter side
  Folder.fromNew(this.name) : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['parent_folder_id'],
    parentColumns: ['id'],
    entity: Folder,
  ),
  ForeignKey(
    childColumns: ['child_folder_id'],
    parentColumns: ['id'],
    entity: Folder,
  ),
  ForeignKey(
    childColumns: ['child_album_id'],
    parentColumns: ['id'],
    entity: Album,
  )
], primaryKeys: [
  "parent_folder_id",
  "child_folder_id",
  "child_album_id"
])
class FolderChild {
  @ColumnInfo(name: "parent_folder_id")
  final int parentFolderId;

  @ColumnInfo(name: "child_folder_id")
  final int? childFolderId;
  @ColumnInfo(name: "child_album_id")
  final int? childAlbumId;

  final int order;

  FolderChild(
      this.parentFolderId, this.childFolderId, this.childAlbumId, this.order);
}

@entity
class Tag {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  Tag(this.id, this.name);
  // Used to create from Dart/Flutter side
  Tag.fromNew(this.name) : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['parent_tag_id'],
    parentColumns: ['id'],
    entity: Tag,
  ),
  ForeignKey(
    childColumns: ['child_folder_id'],
    parentColumns: ['id'],
    entity: Folder,
  ),
  ForeignKey(
    childColumns: ['child_album_id'],
    parentColumns: ['id'],
    entity: Album,
  ),
  ForeignKey(
    childColumns: ['child_playlist_id'],
    parentColumns: ['id'],
    entity: Playlist,
  ),
  ForeignKey(
    childColumns: ['child_song_id'],
    parentColumns: ['id'],
    entity: Song,
  ),
], primaryKeys: [
  "parent_folder_id",
  "child_folder_id",
  "child_album_id",
  "child_playlist_id",
  "child_song_id"
])
class TagChild {
  @ColumnInfo(name: "parent_tag_id")
  final int parentTagId;

  @ColumnInfo(name: "child_folder_id")
  final int? childFolderId;
  @ColumnInfo(name: "child_album_id")
  final int? childAlbumId;
  @ColumnInfo(name: "child_playlist_id")
  final int? childPlaylistId;
  @ColumnInfo(name: "child_song_id")
  final int? childSongId;

  TagChild(this.parentTagId, this.childFolderId, this.childAlbumId,
      this.childPlaylistId, this.childSongId);
}
