import 'package:floor/floor.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

import '../models.dart';

/*

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
], primaryKeys: [
  // Can only have one element linked to index X of playlist_id
  "playlist_id",
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
  // Can only have one element linked to index X of parent_folder_id
  "parent_folder_id",
  "index"
])
class FolderChild {
  @ColumnInfo(name: "parent_folder_id")
  final int parentFolderId;

  @ColumnInfo(name: "child_folder_id")
  final int? childFolderId;
  @ColumnInfo(name: "child_album_id")
  final int? childAlbumId;

  final int index;

  FolderChild(
      this.parentFolderId, this.childFolderId, this.childAlbumId, this.index);

  FolderChild.folder(this.parentFolderId, Folder folder, this.index)
      : this.childFolderId = folder.id,
        this.childAlbumId = null;
  FolderChild.album(this.parentFolderId, Album album, this.index)
      : this.childFolderId = null,
        this.childAlbumId = album.id;
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

  // Private constructor,
  // Inits child fields to null, takes a typesafe Tag
  TagChild._base(Tag tag,
      {this.childAlbumId,
      this.childFolderId,
      this.childPlaylistId,
      this.childSongId})
      : parentTagId = tag.id;
  // Type-safe constructors for each type
  TagChild.folder(Tag tag, Folder folder)
      : this._base(tag, childFolderId: folder.id);
  TagChild.album(Tag tag, Album album)
      : this._base(tag, childAlbumId: album.id);
  TagChild.playlist(Tag tag, Playlist playlist)
      : this._base(tag, childPlaylistId: playlist.id);
  TagChild.song(Tag tag, Song song) : this._base(tag, childSongId: song.id);
}

*/
