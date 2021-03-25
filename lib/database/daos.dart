import 'package:floor/floor.dart';

import 'models.dart';
import 'package:flutter_music_tagging/ext.dart';

import 'models.dart';
import 'models.dart';
import 'models.dart';
import 'models.dart';

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

  @insert
  Future<T> _insertBase(T base);
  @insert
  Future<List<TEntry>> _insertEntries(List<TEntry> entries);

  Future<T> insertGroup(T base_noIndex, List<TReferenced> referenced) async {
    T base = await _insertBase(base_noIndex);
    await _insertEntries(
        referenced.mapIndexed((r, i) => generateEntry(base, i, r)).toList());

    return base;
  }
}

@dao
abstract class SongDao {
  // TODO - find queries
}

// Album
@dao
abstract class AlbumDao extends BaseOrderedGroupDao<Album, AlbumEntry, Song> {
  // TODO - find queries

  @override
  AlbumEntry generateEntry(Album base, int index, Song referenced) {
    return AlbumEntry(base.id, referenced.id, index);
  }
}

// Artist
@dao
abstract class ArtistDao {
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
}

// Folder
@dao
abstract class FolderDao {
  // TODO - find queries
}

// Tag
@dao
abstract class TagDao {
  // TODO - find queries
  // TODO - functions for songs/albums/playlists/folders directly tagged, then functions for indirect tags?
}
