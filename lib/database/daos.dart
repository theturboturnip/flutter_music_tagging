import 'package:floor/floor.dart';

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
