import 'package:floor/floor.dart';

import 'folder_overlay_db.dart';
import 'raw_db.dart';
import 'unified_library_db.dart';

@entity
class Tag {
  @PrimaryKey(autoGenerate: true)
  final int id;
  final String name;
  final int hexRGBA;

  Tag(this.id, this.name, this.hexRGBA);
  Tag.fromNew(this.name, this.hexRGBA) : this.id = 0;
}

@Entity(foreignKeys: [
  ForeignKey(childColumns: ["tag_id"], parentColumns: ["id"], entity: Tag),
  ForeignKey(
      childColumns: ["dir_id"], parentColumns: ["id"], entity: DirTreeNode),
], primaryKeys: [
  // Can only have one element linking tag X and directory Y
  "tag_id",
  "dir_id"
])
class TagDirJoin {
  @ColumnInfo(name: "tag_id")
  final int tagId;
  @ColumnInfo(name: "dir_id")
  final int dirId;

  TagDirJoin(this.tagId, this.dirId);
}

@Entity(foreignKeys: [
  ForeignKey(childColumns: ["tag_id"], parentColumns: ["id"], entity: Tag),
  ForeignKey(
      childColumns: ["album_id"], parentColumns: ["id"], entity: UnifiedAlbum),
], primaryKeys: [
  // Can only have one element linking tag X and album Y
  "tag_id",
  "album_id"
])
class TagAlbumJoin {
  @ColumnInfo(name: "tag_id")
  final int tagId;
  @ColumnInfo(name: "album_id")
  final int albumId;

  TagAlbumJoin(this.tagId, this.albumId);
}

@Entity(foreignKeys: [
  ForeignKey(childColumns: ["tag_id"], parentColumns: ["id"], entity: Tag),
  ForeignKey(
      childColumns: ["artist_id"],
      parentColumns: ["id"],
      entity: UnifiedArtist),
], primaryKeys: [
  // Can only have one element linking tag X and artist Y
  "tag_id",
  "artist_id"
])
class TagArtistJoin {
  @ColumnInfo(name: "tag_id")
  final int tagId;
  @ColumnInfo(name: "artist_id")
  final int artistId;

  TagArtistJoin(this.tagId, this.artistId);
}

@Entity(foreignKeys: [
  ForeignKey(childColumns: ["tag_id"], parentColumns: ["id"], entity: Tag),
  ForeignKey(
      childColumns: ["song_id"], parentColumns: ["id"], entity: UnifiedSong),
], primaryKeys: [
  // Can only have one element linking tag X and song Y
  "tag_id",
  "song_id"
])
class TagSongJoin {
  @ColumnInfo(name: "tag_id")
  final int tagId;
  @ColumnInfo(name: "song_id")
  final int songId;

  TagSongJoin(this.tagId, this.songId);
}

@dao
abstract class TagDao {
  @Query("SELECT * FROM DirTreeNode "
      "INNER JOIN TagAlbumJoin ON TagAlbumJoin.dir_id = DirTreeNode.id "
      "WHERE TagAlbumJoin.tag_id IN (:tagIds)")
  Future<List<DirTreeNode>> getDirectlyTaggedDirs(List<int> tagIds);
  @Query("SELECT * FROM UnifiedAlbum "
      "INNER JOIN TagAlbumJoin ON TagAlbumJoin.album_id = UnifiedAlbum.id "
      "WHERE TagAlbumJoin.tag_id IN (:tagIds)")
  Future<List<UnifiedAlbum>> getDirectlyTaggedAlbums(List<int> tagIds);
  @Query("SELECT * FROM UnifiedArtist "
      "INNER JOIN TagArtistJoin ON TagArtistJoin.artist_id = UnifiedArtist.id "
      "WHERE TagArtistJoin.tag_id IN (:tagIds)")
  Future<List<UnifiedArtist>> getDirectlyTaggedArtists(List<int> tagIds);
  @Query("SELECT * FROM UnifiedSong "
      "INNER JOIN TagSongJoin ON TagSongJoin.song_id = UnifiedSong.id "
      "WHERE TagSongJoin.tag_id IN (:tagIds)")
  Future<List<UnifiedSong>> getDirectlyTaggedSongs(List<int> tagIds);

  @transaction
  Future<Set<int>> getAllTaggedUnifiedSongIds(
      UnifiedDataDao unifiedDataDao, DirDao dirDao, List<int> tagIds) async {
    var dirs = await getDirectlyTaggedDirs(tagIds);
    var artists = await getDirectlyTaggedArtists(tagIds);
    var artistIds = artists.map((artist) => artist.id).toList(growable: false);
    var albums = await getDirectlyTaggedAlbums(tagIds) +
        await dirDao.albumChildrenOfBfs(dirs) +
        await unifiedDataDao.getArtistsAlbums(artistIds);
    var albumIds = albums.map((album) => album.id).toList(growable: false);
    var songs = await getDirectlyTaggedSongs(tagIds) +
        await unifiedDataDao.getAlbumSongs(albumIds) +
        await unifiedDataDao.getArtistsSongs(artistIds);

    return songs.map((song) => song.id).toSet();
  }

  Future<List<RawSong>> getAllTaggedRawSongIds(UnifiedDataDao unifiedDataDao,
      DirDao dirDao, List<int> tagIds, String backendType) async {
    var unifiedSongIds =
        (await getAllTaggedUnifiedSongIds(unifiedDataDao, dirDao, tagIds))
            .toList(growable: false);
    return await unifiedDataDao.getRawIdsForUnifiedSongsInBackend(
        unifiedSongIds, backendType);
  }
}
