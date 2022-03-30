import 'package:collection/collection.dart';
import 'package:floor/floor.dart';

import 'raw_db.dart';

/// This contains Entities/DAOs used to interface with the Unified library
/// The Unified library merges multiple songs/albums/artists that are (usually)
/// from different backends under single instances.
///
/// The relationship of many:1 RawSong:UnifiedSong is clear.
/// This also extends to RawAlbum:UnifiedAlbum and RawArtist:UnifiedArtist.
/// Each UnifiedX contains a user-customizable name.
/// UnifiedSongs *should* have similar length values to constituent RawSongs.
/// UnifiedAlbums *must* have the same number of tracks as constituent RawAlbums.
/// UnifiedAlbums *must* have the same track orders i.e. UnifiedSong #i of a UnifiedAlbum
/// should contain RawSong #i for all constituent RawAlbums.
///     forall RawAlbums in each UnifiedAlbum,
///         unified(RawAlbum.songs) == UnifiedAlbum.songs
///
/// Because a Song may appear in multiple Albums
/// (e.g. a single may appear in a single album and a compilation album),
/// there is a many:1 RawSong:RawAlbum relation,
/// and therefore a many:1 UnifiedSong:UnifiedAlbum relation.
/// This is derived automatically:
/// foreach UnifiedSong,
///     UnifiedSong.albums = set of unified(album)
///                          foreach album foreach mapped RawSong
///
/// Artists derive something similar:
/// foreach UnifiedSong,
///     UnifiedSong.artists = set of unified(artist)
///                           foreach artist foreach mapped RawSong
/// foreach UnifiedAlbum,
///     UnifiedAlbum.artists = set of unified(artist)
///                            foreach artist foreach mapped RawAlbum

@entity
class UnifiedSong {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String title;
  final int lengthMs;

  // Used to create from SQL-version
  UnifiedSong(this.id, this.title, this.lengthMs);
  // Used to create from Dart/Flutter side
  UnifiedSong.fromNew(this.title, this.lengthMs) : this.id = 0;
}

@entity
class UnifiedArtist {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String name;

  // Used to create from SQL-version
  UnifiedArtist(this.id, this.name);
  // Used to create from Dart/Flutter side
  UnifiedArtist.fromNew(this.name) : this.id = 0;
}

@entity
class UnifiedAlbum {
  @PrimaryKey(autoGenerate: true)
  final int id;

  final String title;
  final int trackCount;

  // Used to create from SQL-version
  UnifiedAlbum(this.id, this.title, this.trackCount);
  // Used to create from Dart/Flutter side
  UnifiedAlbum.fromNew(this.title, this.trackCount) : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['album_id'],
    parentColumns: ['id'],
    entity: UnifiedAlbum,
  ),
  ForeignKey(
    childColumns: ['song_id'],
    parentColumns: ['id'],
    entity: UnifiedSong,
  )
], primaryKeys: [
  // Can only have one element linked to index X of album_id
  "album_id",
  "index"
])
class UnifiedAlbumEntry {
  @ColumnInfo(name: "album_id")
  final int albumId;
  @ColumnInfo(name: "song_id")
  final int songId;

  final int index;

  UnifiedAlbumEntry(this.albumId, this.songId, this.index);
}

// Map a UnifiedSong ID to the IDs of RawAlbums that contain any of the
// raw constituent songs
@DatabaseView("SELECT RawAlbumEntry.album_id as raw_album_id, "
    "RawSong.unified_id as unified_song_id "
    "FROM RawSong "
    "INNER JOIN RawAlbumEntry ON RawSong.id = RawAlbumEntry.song_id "
    "WHERE RawSong.unified_id NOT NULL")
class UnifiedSongRawAlbumId {
  @ColumnInfo(name: "raw_album_id")
  final int rawAlbumId;
  @ColumnInfo(name: "unified_song_id")
  final int unifiedSongId;

  UnifiedSongRawAlbumId(this.unifiedSongId, this.rawAlbumId);
}

// Map a UnifiedSong ID to UnifiedAlbum IDs,
// where each UnifiedAlbum's has at least one Raw equivalent containing
// at least one of the UnifiedSong's Raw equivalents.
// UnifiedSong.albums = set of unified(album)
//    foreach album containing any mapped RawSong
@DatabaseView("SELECT DISTINCT RawAlbum.unified_id as unified_album_id, "
    "UnifiedSongRawAlbumId.unified_song_id as unified_song_id "
    "FROM UnifiedSongRawAlbumId "
    "INNER JOIN RawAlbum ON UnifiedSongUnifiedAlbumId.rawAlbumId = RawAlbum.id "
    "WHERE RawAlbum.unified_id NOT NULL")
class UnifiedSongUnifiedAlbumId {
  @ColumnInfo(name: "unified_album_id")
  final int unifiedAlbumId;
  @ColumnInfo(name: "unified_song_id")
  final int unifiedSongId;

  UnifiedSongUnifiedAlbumId(this.unifiedSongId, this.unifiedAlbumId);
}

/*
  /// foreach UnifiedSong,
  ///     UnifiedSong.albums = set of unified(album)
  ///                          foreach album foreach mapped RawSong
  @Query("SELECT * FROM UnifiedAlbum INNER JOIN UnifiedSongUnifiedAlbumId ON UnifiedSongUnifiedAlbumId.unified_album_id = UnifiedAlbum.id WHERE UnifiedSongUnifiedAlbumId.unified_song_id = :songId")
  Future<List<UnifiedAlbum>> getSongAlbumIds(int songId);

  /// foreach UnifiedSong,
  ///     UnifiedSong.artists = set of unified(artist)
  ///                           foreach artist foreach mapped RawSong
  ///
  /// - "set" -> use DISTINCT to remove dupes
  /// - unified(artist) "SELECT unified_id FROM RawArtist"
  /// - foreach artist of RawSong "INNER JOIN (RawSongArtist INNER JOIN RawSong ON RawSongArtist.songId = RawSong.id"
  /// - foreach mapped RawSong from UnifiedSong "WHERE RawSong.unifiedId = :songId"
  @Query("SELECT DISTINCT unified_id FROM RawArtist INNER JOIN "
      "(RawSongArtist INNER JOIN RawSong ON RawSongArtist.song_id = RawSong.id WHERE RawSong.unified_id = :songId) raw_song_artists "
      "on RawArtist.id = raw_song_artists.artist_id")
  Future<List<int>> getSongArtistIds(int songId);

  /// foreach UnifiedAlbum,
  ///     UnifiedAlbum.artists = set of unified(artist)
  ///                            foreach artist foreach mapped RawAlbum
  /// As above, for album artists
  @Query("SELECT DISTINCT unified_id FROM RawArtist INNER JOIN "
      "(RawAlbumArtist INNER JOIN RawAlbum ON RawAlbumArtist.album_id = RawAlbum.id WHERE RawAlbum.unified_id = :albumId) raw_album_artists "
      "on RawArtist.id = raw_album_artists.artist_id")
  Future<List<int>> getAlbumArtistIds(int albumId);
*/

@dao
abstract class UnifiedDataDao {
  @Query("SELECT * FROM RawSong WHERE unified_id = :songId")
  Future<List<RawSong>> getRawIdsForUnifiedSong(int songId);
  @Query("SELECT * FROM RawAlbum WHERE unified_id = :albumId")
  Future<List<RawAlbum>> getRawIdsForUnifiedAlbum(int albumId);
  @Query("SELECT * FROM RawArtist WHERE unified_id = :artistId")
  Future<List<RawArtist>> getRawIdsForUnifiedArtist(int artistId);

  @Query("SELECT * FROM UnifiedAlbumEntry "
      "WHERE album_id = :unifiedId "
      "ORDER BY UnifiedAlbumEntry.index")
  Future<List<UnifiedAlbumEntry>> getUnifiedAlbumEntries(int unifiedId);
  @Query("SELECT * FROM RawSong "
      "INNER JOIN RawAlbumEntry ON RawSong.id = RawAlbumEntry.song_id "
      "WHERE RawAlbumEntry.album_id = :rawId "
      "ORDER BY RawAlbumEntry.index")
  Future<List<RawSong>> getRawAlbumSongs(int rawId);

  @Query("UPDATE UnifiedSong SET unified_id = :unifiedId WHERE id IN (:rawIds)")
  Future<void> internal_unifyRawSongs(List<int> rawIds, int unifiedId);
  @Query(
      "UPDATE UnifiedAlbum SET unified_id = :unifiedId WHERE id IN (:rawIds)")
  Future<void> internal_unifyRawAlbums(List<int> rawIds, int unifiedId);
  @Query(
      "UPDATE UnifiedArtist SET unified_id = :unifiedId WHERE id IN (:rawIds)")
  Future<void> internal_unifyRawArtists(List<int> rawIds, int unifiedId);

  @transaction
  Future<void> unifyRawSongs(List<int> rawIds, int unifiedId) async {
    await internal_unifyRawSongs(rawIds, unifiedId);
    await deleteUnreferencedUnifiedSongs();
  }

  // Checks if a set of raw albums have the same unified songs as a unified album.
  // i.e.
  ///     forall RawAlbums in selection,
  ///         unified(RawAlbum.songs) == UnifiedAlbum.songs
  @transaction
  Future<bool> canUnifyRawAlbums(List<int> rawIds, int unifiedId) async {
    // Check the albums have the same unified songs
    List<int> unifiedSongIds = (await getUnifiedAlbumEntries(unifiedId))
        .map((entry) => entry.songId)
        .toList();
    for (int i = 0; i < rawIds.length; i++) {
      List<int?> rawSongIds = (await getRawAlbumSongs(rawIds[i]))
          .map((rsong) => rsong.unifiedId)
          .toList();
      if (!ListEquality().equals(unifiedSongIds, rawSongIds)) {
        return false;
      }
    }
    return true;
  }

  // Merge a set of Raw albums into a single Unified album.
  // Cleans up newly-orphaned unified albums.
  // Checks that the albums all have the same unified songs.
  // If they do, returns true and does the unification
  // If they don't, return false
  @transaction
  Future<bool> tryUnifyRawAlbums(List<int> rawIds, int unifiedId) async {
    if (await canUnifyRawAlbums(rawIds, unifiedId)) {
      await internal_unifyRawAlbums(rawIds, unifiedId);
      return true;
    } else {
      return false;
    }
  }

  @transaction
  Future<void> unifyRawArtists(List<int> rawIds, int unifiedId) async {
    await internal_unifyRawArtists(rawIds, unifiedId);
    await deleteUnreferencedUnifiedArtists();
  }

  // Delete any UnifiedSongs that no longer have mapped RawSongs, for consistency.
  // TODO - could do this with a trigger: https://stackoverflow.com/a/63944296
  @Query("DELETE FROM UnifiedSong usong WHERE NOT EXISTS "
      "(SELECT 1 FROM RawSong rsong where rsong.unified_id = usong.id)")
  Future<void> deleteUnreferencedUnifiedSongs();
  @Query("DELETE FROM UnifiedAlbum ualbum WHERE NOT EXISTS "
      "(SELECT 1 FROM RawAlbum ralbum where ralbum.unified_id = ualbum.id)")
  Future<void> deleteUnreferencedUnifiedAlbums();
  @Query("DELETE FROM UnifiedArtist uartist WHERE NOT EXISTS "
      "(SELECT 1 FROM RawArtist rartist where rartist.unified_id = uartist.id)")
  Future<void> deleteUnreferencedUnifiedArtists();

  @Query("UPDATE UnifiedSong SET title = :newTitle WHERE id = :songId")
  Future<void> updateSongTitle(int songId, String newTitle);
  @Query("UPDATE UnifiedAlbum SET title = :newTitle WHERE id = :albumId")
  Future<void> updateAlbumTitle(int albumId, String newTitle);
  @Query("UPDATE UnifiedArtist SET title = :newTitle WHERE id = :artistId")
  Future<void> updateArtistTitle(int artistId, String newTitle);

  /// foreach UnifiedSong,
  ///     UnifiedSong.albums = set of unified(album)
  ///                          foreach album foreach mapped RawSong
  @Query(
      "SELECT * FROM UnifiedAlbum INNER JOIN UnifiedSongUnifiedAlbumId ON UnifiedSongUnifiedAlbumId.unified_album_id = UnifiedAlbum.id WHERE UnifiedSongUnifiedAlbumId.unified_song_id = :songId")
  Future<List<UnifiedAlbum>> getSongAlbumIds(int songId);
}