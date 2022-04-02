// Classes used to describe data structures before getting imported into the database.

import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:floor/floor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:flutter_music_tagging/database/raw_db.dart';
import 'package:flutter_music_tagging/ext.dart';

import 'unified_library_db.dart';

// Unified data model that backends convert their data into before importing.
// This allows e.g. pre-import unification checks to be implemented in one place

class ImportSong {
  final BackendId backendId;
  final String title;
  final int lengthMs;

  final IList<BackendId> artistIds;

  ImportSong(this.backendId, this.title, this.lengthMs, this.artistIds);
}

class ImportAlbum {
  final BackendId backendId;
  final String title;
  final IList<BackendId> songIds;
  final IList<BackendId> artistIds;

  ImportAlbum(this.backendId, this.title, this.songIds, this.artistIds);
}

class ImportArtist {
  final BackendId backendId;
  final String title;

  ImportArtist(this.backendId, this.title);
}

class ImportData {
  final IMap<BackendId, ImportSong> songs;
  final IMap<BackendId, ImportAlbum> albums;
  final IMap<BackendId, ImportArtist> artists;

  ImportData(this.songs, this.albums, this.artists);
}

@dao
abstract class ImporterDao {
  @insert
  Future<List<int>> insertUnifiedSongs(List<UnifiedSong> songs);
  @insert
  Future<List<int>> insertUnifiedAlbums(List<UnifiedAlbum> albums);
  @insert
  Future<void> insertUnifiedAlbumEntries(List<UnifiedAlbumEntry> albumEntries);
  @insert
  Future<List<int>> insertUnifiedArtists(List<UnifiedArtist> artists);

  @transaction
  Future<void> importData(ImportData toImport) async {
    // Create Unified songs
    var newUnifiedSongs = toImport.songs
        .mapTo(
          (key, value) =>
              MapEntry(key, UnifiedSong.fromNew(value.title, value.lengthMs)),
        )
        .toIList();
    var unifiedSongIds = await insertUnifiedSongs(
        newUnifiedSongs.map((entry) => entry.value).toList());
    assert(newUnifiedSongs.length == unifiedSongIds.length);
    var songBackendToUnifiedId = Map.fromEntries(newUnifiedSongs
        .mapIndexed((songKV, i) => MapEntry(songKV.key, unifiedSongIds[i])));

    // Create unified albums
    var newUnifiedAlbums = toImport.albums
        .mapTo(
          (key, value) => MapEntry(key,
              UnifiedAlbum.fromNew(value.title, value.songIds.length, null)),
        )
        .toIList();
    var unifiedAlbumIds = await insertUnifiedAlbums(
        newUnifiedAlbums.map((entry) => entry.value).toList());
    debugPrint(newUnifiedAlbums.toString());
    debugPrint(unifiedAlbumIds.toString());
    assert(newUnifiedAlbums.length == unifiedAlbumIds.length);
    var albumBackendToUnifiedId = Map.fromEntries(newUnifiedAlbums
        .mapIndexed((albumKV, i) => MapEntry(albumKV.key, unifiedAlbumIds[i])));

    // Create unified album-song links
    // Take Map<BackendID, unified ID>, map to Iterable<Iterable<UnifiedAlbumEntry>>
    // and flatten to Iterable<UnifiedAlbumEntry>
    var unifiedAlbumEntries = albumBackendToUnifiedId
        .mapTo((albumBackendId, albumUnifiedId) => toImport
            .albums[albumBackendId]!.songIds
            .mapIndexed((songBackendId, i) => UnifiedAlbumEntry(
                albumUnifiedId, songBackendToUnifiedId[songBackendId]!, i)))
        .expand((entry) => entry)
        .toList(growable: false);
    await insertUnifiedAlbumEntries(unifiedAlbumEntries);

    // Create unified artists
    var newUnifiedArtists = toImport.artists
        .mapTo(
          (key, value) => MapEntry(key, UnifiedArtist.fromNew(value.title)),
        )
        .toIList();
    var unifiedArtistIds = await insertUnifiedArtists(
        newUnifiedArtists.map((entry) => entry.value).toList());
    assert(newUnifiedArtists.length == unifiedArtistIds.length);
    var artistBackendToUnifiedId = Map.fromEntries(newUnifiedArtists.mapIndexed(
        (artistKV, i) => MapEntry(artistKV.key, unifiedArtistIds[i])));

    /// TODO add raw elements, mapping to the new unified counterparts
    /// raw songs
    /// raw albums
    /// raw song-album links
    /// raw artists
    /// raw song-artist links
    /// raw album-artist links
  }
}
