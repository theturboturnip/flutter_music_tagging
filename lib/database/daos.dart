import 'package:floor/floor.dart';

import 'backend_id.dart';
import 'models.dart';
import 'package:flutter_music_tagging/ext.dart';

// Abstract class with function annotations that will
// automatically generate correct insert/update/delete
abstract class BaseMutableDao<T> {
  @insert
  Future<List<T>> insertValues(List<T> values);

  // Returns number of updated values
  @update
  Future<int> updateValues(List<T> values);

  @delete
  Future<void> deleteValues(List<T> values);
}

abstract class BaseMutableBackendedDao<T, TBackendElem extends BackendRow<T>> {
  TBackendElem generateRow(T item, BackendId id);

  @insert
  Future<void> _insertBackendElems(List<TBackendElem>);

  @transaction
  Future<void> insertBackendMappings(T item, List<BackendId> items) {
    return _insertBackendElems(items.map((e) => generateRow(item, e)));
  }

  // TODO - need update-y functions, delete-y functions
}

// Abstract class with function annotations that will
// automatically generate correct insert/update functions for
// "ordered-groups".
// e.g. T = Album, TReferenced = Song, TEntry = AlbumEntry
// will generate insertGroup(Album, List<Song>) that automatically
// creates correct AlbumEntry rows.
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
abstract class SongDao extends BaseMutableDao<Song> with BaseMutableBackendedDao<Song, Song_BackendRow> {
  Song_BackendRow generateRow(Song item, BackendId id) {
    return Song_BackendRow(item.id, id);
  }

  // TODO - more queries for selecting songs

  @Query("SELECT * FROM Song where instr(title, :keyword) > 0")
  Future<List<Song>> getSongsByKeyword(String keyword);

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllSongs();
}

// Album
@dao
abstract class AlbumDao extends BaseOrderedGroupDao<Album, AlbumEntry, Song> with BaseMutableBackendedDao<Album, Album_BackendRow> {
  Album_BackendRow generateRow(Album item, BackendId id) {
    return Album_BackendRow(item.id, id);
  }
  
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

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllAlbums();

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
abstract class ArtistDao extends BaseMutableDao<Artist> with BaseMutableBackendedDao<Artist, Artist_BackendRow> {
  Artist_BackendRow generateRow(Artist item, BackendId id) {
    return Artist_BackendRow(item.id, id);
  }

  // TODO - find queries

  @Query("SELECT * FROM Song ORDER BY title")
  Stream<List<Song>> listenForAllArtists();
}
