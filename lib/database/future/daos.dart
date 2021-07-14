import 'package:floor/floor.dart';
import 'package:sealed_unions/union_2.dart';

import 'models.dart';
import '../models.dart';
import '../daos.dart';

/*

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

*/
