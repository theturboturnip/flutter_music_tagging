import 'package:floor/floor.dart';
import 'package:sealed_unions/union_2.dart';

import 'models.dart';
import 'package:flutter_music_tagging/ext.dart';

abstract class BaseMutableDao<T> {
  @insert
  Future<List<T>> insertValues(List<T> values);

  // Returns number of updated values
  @update
  Future<int> updateValues(List<T> values);

  @delete
  Future<void> deleteValues(List<T> values);
}

abstract class BaseOrderedGroupDao<T, TEntry, TReferenced> {
  TEntry generateEntry(T base, int index, TReferenced referenced);
  Future<void> deleteGroupEntries(T base);

  @insert
  Future<T> _insertBase(T base);
  @insert
  Future<List<TEntry>> _insertEntries(List<TEntry> entries);

  @transaction
  Future<T> insertGroup(T base_noIndex, List<TReferenced> referenced) async {
    T base = await _insertBase(base_noIndex);
    await _insertEntries(
        referenced.mapIndexed((r, i) => generateEntry(base, i, r)).toList());

    return base;
  }

  @transaction
  Future<void> updateGroup(T base, List<TReferenced> referenced) async {
    await deleteGroupEntries(base);
    await _insertEntries(
        referenced.mapIndexed((r, i) => generateEntry(base, i, r)).toList());
  }
}

@dao
abstract class SongDao extends BaseMutableDao<Song> {
  // TODO - find queries
}

// Album
@dao
abstract class AlbumDao extends BaseOrderedGroupDao<Album, AlbumEntry, Song> {
  @Query("SELECT * FROM Album where albumId = :id")
  Future<Album> getAlbum(int id);

  @Query("SELECT * FROM Song "
      "INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id "
      "WHERE AlbumEntries.album_id = :album.id "
      "ORDER BY AlbumEntries.index")
  Future<List<Song>> getAlbumSongs(Album album);

  @Query("SELECT * FROM Song "
      "INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id "
      "WHERE AlbumEntries.album_id = :album.id "
      "ORDER BY AlbumEntries.index")
  Stream<List<Song>> listenForAlbumSongs(Album album);

  @override
  AlbumEntry generateEntry(Album base, int index, Song referenced) {
    return AlbumEntry(base.id, referenced.id, index);
  }

  @override
  @Query("DELETE * FROM AlbumEntry where albumId = :base.id")
  Future<void> deleteGroupEntries(Album base);
}

// Artist
@dao
abstract class ArtistDao extends BaseMutableDao<Artist> {
  // TODO - find queries
}

// Playlist
@dao
abstract class PlaylistDao
    extends BaseOrderedGroupDao<Playlist, PlaylistEntry, Song> {
  // TODO - find queries

  @override
  PlaylistEntry generateEntry(Playlist base, int index, Song referenced) {
    return PlaylistEntry(index, base.id, referenced.id);
  }

  @override
  @Query("DELETE * FROM PlaylistEntry where playlist_id = :base.id")
  Future<void> deleteGroupEntries(Playlist base);
}

// Folder
@dao
abstract class FolderDao
    extends BaseOrderedGroupDao<Folder, FolderChild, Union2<Folder, Album>> {
  // TODO - find queries

  @override
  FolderChild generateEntry(
      Folder base, int index, Union2<Folder, Album> referenced) {
    return referenced.join(
        (folder) => FolderChild.folder(base.id, folder, index),
        (album) => FolderChild.album(base.id, album, index));
  }

  @override
  @Query("DELETE * FROM FolderChild where parent_folder_id = :base.id")
  Future<void> deleteGroupEntries(Folder base);
}

// Tag
@dao
abstract class TagDao {
  // TODO - find queries
  // TODO - functions for songs/albums/playlists/folders directly tagged, then functions for indirect tags?
}
