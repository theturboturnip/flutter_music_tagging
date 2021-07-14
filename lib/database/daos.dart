import 'package:floor/floor.dart';

import 'backend_id.dart';
import 'models.dart';
import 'package:flutter_music_tagging/ext.dart';

// Abstract class with function annotations that will
// automatically generate correct insert/update/delete
abstract class BaseMutableDao<T> {
  @insert
  Future<List<int>> insertValues(List<T> values);

  // Returns number of updated values
  @update
  Future<int> updateValues(List<T> values);

  @delete
  Future<void> deleteValues(List<T> values);
}

abstract class BaseMutableBackendedDao<T, TBackendElem> {
  TBackendElem generateRow(T item, BackendId id);

  @insert
  Future<void> _insertBackendElems(List<TBackendElem> values);

  @transaction
  Future<void> insertBackendMappings(T item, List<BackendId> items) {
    return _insertBackendElems(items.map((e) => generateRow(item, e)).toList());
  }

  // TODO - need update-y functions, delete-y functions
}

// Abstract class with function annotations that will
// automatically generate correct insert/update functions for
// "ordered-groups".
// e.g. T = Album, TReferenced = Song, TEntry = AlbumEntry
// will generate insertGroup(Album, List<Song>) that automatically
// creates correct AlbumEntry rows.
// abstract class BaseOrderedGroupDao<T, TEntry, TReferenced> {
//   TEntry generateEntry(int baseId, int index, TReferenced referenced);
//   Future<void> deleteGroupEntries(T base);

//   @insert
//   Future<int> _insertBase(T base);
//   @insert
//   Future<List<int>> _insertEntries(List<TEntry> entries);

//   @transaction
//   Future<int> insertGroup(T base_noId, List<TReferenced> referenced) async {
//     int baseId = await _insertBase(base_noId);
//     await _insertEntries(
//         referenced.mapIndexed((r, i) => generateEntry(baseId, i, r)).toList());

//     return baseId;
//   }

//   @transaction
//   Future<void> updateGroup(
//       T base, int baseId, List<TReferenced> referenced) async {
//     await deleteGroupEntries(base);
//     await _insertEntries(
//         referenced.mapIndexed((r, i) => generateEntry(baseId, i, r)).toList());
//   }
// }

@dao
abstract class SongDao extends BaseMutableDao<Song>
    with BaseMutableBackendedDao<Song, Song_BackendRow> {
  Song_BackendRow generateRow(Song item, BackendId id) {
    return Song_BackendRow(item.id, id);
  }

  // TODO - more queries for selecting songs

  @Query("SELECT * FROM Song where instr(title, :keyword) > 0")
  Future<List<Song>> getSongsByKeyword(String keyword);
  @Query("SELECT * FROM Song where instr(title, :keyword) > 0")
  Stream<List<Song>> listenForSongsByKeyword(String keyword);

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllSongs();
}

// Album
@dao
abstract class AlbumDao
    extends BaseMutableBackendedDao<Album, Album_BackendRow> {
  Album_BackendRow generateRow(Album item, BackendId id) {
    return Album_BackendRow(item.id, id);
  }

  @Query("SELECT * FROM Album where albumId = :id")
  Future<Album?> getAlbum(int id);

  @Query("SELECT * FROM Song "
      "INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id "
      "WHERE AlbumEntries.album_id = :albumId "
      "ORDER BY AlbumEntries.index")
  Future<List<Song>> getAlbumSongs(int albumId);

  @Query("SELECT * FROM Song "
      "INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id "
      "WHERE AlbumEntries.album_id = :albumId "
      "ORDER BY AlbumEntries.index")
  Stream<List<Song>> listenForAlbumSongs(int albumId);

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllAlbums();

  @insert
  Future<int> _insertBase(Album base);
  @insert
  Future<List<int>> _insertEntries(List<AlbumEntry> entries);

  @transaction
  Future<int> insertGroup(Album base_noId, List<Song> referenced) async {
    int baseId = await _insertBase(base_noId);
    await _insertEntries(
        referenced.mapIndexed((r, i) => generateEntry(baseId, i, r)).toList());

    return baseId;
  }

  @transaction
  Future<void> updateGroup(Album base, List<Song> referenced) async {
    await deleteGroupEntries(base.id);
    await _insertEntries(
        referenced.mapIndexed((r, i) => generateEntry(base.id, i, r)).toList());
  }

  AlbumEntry generateEntry(int baseId, int index, Song referenced) {
    return AlbumEntry(baseId, referenced.id, index);
  }

  @Query("DELETE * FROM AlbumEntry where albumId = :baseId")
  Future<void> deleteGroupEntries(int baseId);
}

// Artist
@dao
abstract class ArtistDao extends BaseMutableDao<Artist>
    with BaseMutableBackendedDao<Artist, Artist_BackendRow> {
  Artist_BackendRow generateRow(Artist item, BackendId id) {
    return Artist_BackendRow(item.id, id);
  }

  // TODO - find queries

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllArtists();
}
