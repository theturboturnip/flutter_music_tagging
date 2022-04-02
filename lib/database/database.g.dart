// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$AppDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  /// Adds migrations to the builder.
  _$AppDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$AppDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RawDataDao? _rawDataDaoInstance;

  UnifiedDataDao? _unifiedDataDaoInstance;

  DirDao? _dirDaoInstance;

  TagDao? _tagDaoInstance;

  ImporterDao? _importerDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawSong` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `title` TEXT NOT NULL, `lengthMs` INTEGER NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawSongArtist` (`song_id` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`song_id`) REFERENCES `RawSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`artist_id`) REFERENCES `RawArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`song_id`, `artist_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbum` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `title` TEXT NOT NULL, `trackCount` INTEGER NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbumArtist` (`album_id` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `RawAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`artist_id`) REFERENCES `RawArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `artist_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbumEntry` (`album_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, `index` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `RawAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`song_id`) REFERENCES `RawSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `index`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawArtist` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `name` TEXT NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedSong` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `lengthMs` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedAlbum` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL, `trackCount` INTEGER NOT NULL, `parent_tree_node_id` INTEGER, FOREIGN KEY (`parent_tree_node_id`) REFERENCES `DirTreeNode` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedAlbumEntry` (`album_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, `index` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `UnifiedAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`song_id`) REFERENCES `UnifiedSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `index`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedArtist` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `title` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DirTreeNode` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `parent_tree_node_id` INTEGER, `name` TEXT NOT NULL, FOREIGN KEY (`parent_tree_node_id`) REFERENCES `DirTreeNode` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Tag` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `name` TEXT NOT NULL, `hexRGBA` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagDirJoin` (`tag_id` INTEGER NOT NULL, `dir_id` INTEGER NOT NULL, FOREIGN KEY (`tag_id`) REFERENCES `Tag` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`dir_id`) REFERENCES `DirTreeNode` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`tag_id`, `dir_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagAlbumJoin` (`tag_id` INTEGER NOT NULL, `album_id` INTEGER NOT NULL, FOREIGN KEY (`tag_id`) REFERENCES `Tag` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`album_id`) REFERENCES `UnifiedAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`tag_id`, `album_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagArtistJoin` (`tag_id` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`tag_id`) REFERENCES `Tag` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`artist_id`) REFERENCES `UnifiedArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`tag_id`, `artist_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `TagSongJoin` (`tag_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, FOREIGN KEY (`tag_id`) REFERENCES `Tag` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`song_id`) REFERENCES `UnifiedSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`tag_id`, `song_id`))');

        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongRawAlbumId` AS SELECT RawAlbumEntry.album_id as raw_album_id, RawSong.unified_id as unified_song_id FROM RawSong INNER JOIN RawAlbumEntry ON RawSong.id = RawAlbumEntry.song_id WHERE RawSong.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongUnifiedAlbumId` AS SELECT DISTINCT RawAlbum.unified_id as unified_album_id, UnifiedSongRawAlbumId.unified_song_id as unified_song_id FROM UnifiedSongRawAlbumId INNER JOIN RawAlbum ON UnifiedSongUnifiedAlbumId.raw_album_id = RawAlbum.id WHERE RawAlbum.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongRawArtistId` AS SELECT RawSongArtist.artist_id as raw_artist_id, RawSong.unified_id as unified_song_id FROM RawSong INNER JOIN RawSongArtist ON RawSong.id = RawSongArtist.song_id WHERE RawSong.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongUnifiedArtistId` AS SELECT DISTINCT RawArtist.unified_id as unified_artist_id, UnifiedSongRawArtistId.unified_song_id as unified_song_id FROM UnifiedSongRawArtistId INNER JOIN RawArtist ON UnifiedSongRawArtistId.raw_artist_id = RawArtist.id WHERE RawArtist.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedAlbumRawArtistId` AS SELECT RawAlbumArtist.artist_id as raw_artist_id, RawAlbum.unified_id as unified_album_id FROM RawAlbum INNER JOIN RawAlbumArtist ON RawAlbum.id = RawAlbumArtist.album_id WHERE RawAlbum.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedAlbumUnifiedArtistId` AS SELECT DISTINCT RawArtist.unified_id as unified_artist_id, UnifiedAlbumRawArtistId.unified_album_id as unified_album_id FROM UnifiedAlbumRawArtistId INNER JOIN RawArtist ON UnifiedAlbumRawArtistId.raw_artist_id = RawArtist.id WHERE RawArtist.unified_id NOT NULL');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  RawDataDao get rawDataDao {
    return _rawDataDaoInstance ??= _$RawDataDao(database, changeListener);
  }

  @override
  UnifiedDataDao get unifiedDataDao {
    return _unifiedDataDaoInstance ??=
        _$UnifiedDataDao(database, changeListener);
  }

  @override
  DirDao get dirDao {
    return _dirDaoInstance ??= _$DirDao(database, changeListener);
  }

  @override
  TagDao get tagDao {
    return _tagDaoInstance ??= _$TagDao(database, changeListener);
  }

  @override
  ImporterDao get importerDao {
    return _importerDaoInstance ??= _$ImporterDao(database, changeListener);
  }
}

class _$RawDataDao extends RawDataDao {
  _$RawDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<RawAlbum?> getRawAlbum(int id) async {
    return _queryAdapter.query('SELECT * FROM RawAlbum where albumId = ?1',
        mapper: (Map<String, Object?> row) => RawAlbum(
            row['id'] as int?,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['title'] as String,
            row['trackCount'] as int),
        arguments: [id]);
  }
}

class _$UnifiedDataDao extends UnifiedDataDao {
  _$UnifiedDataDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<UnifiedSong?> getUnifiedSong(int songId) async {
    return _queryAdapter.query('SELECT * FROM UnifiedSong WHERE id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedSong(
            row['id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [songId]);
  }

  @override
  Future<UnifiedAlbum?> getUnifiedAlbum(int albumId) async {
    return _queryAdapter.query('SELECT * FROM UnifiedAlbum WHERE id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int?,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?),
        arguments: [albumId]);
  }

  @override
  Future<UnifiedArtist?> getUnifiedArtist(int artistId) async {
    return _queryAdapter.query('SELECT * FROM UnifiedArtist WHERE id = ?1',
        mapper: (Map<String, Object?> row) =>
            UnifiedArtist(row['id'] as int?, row['title'] as String),
        arguments: [artistId]);
  }

  @override
  Future<List<RawSong>> getRawIdsForUnifiedSong(int songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawSong WHERE unified_id = ?1',
        mapper: (Map<String, Object?> row) => RawSong(
            row['id'] as int?,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['title'] as String,
            row['lengthMs'] as int),
        arguments: [songId]);
  }

  @override
  Future<List<RawSong>> getRawIdsForUnifiedSongsInBackend(
      List<int> songIds, String backendType) async {
    const offset = 2;
    final _sqliteVariablesForSongIds =
        Iterable<String>.generate(songIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM RawSong WHERE unified_id IN (' +
            _sqliteVariablesForSongIds +
            ') AND backendId LIKE ?1 || \'\$%\'',
        mapper: (Map<String, Object?> row) => RawSong(
            row['id'] as int?,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['title'] as String,
            row['lengthMs'] as int),
        arguments: [backendType, ...songIds]);
  }

  @override
  Future<List<RawAlbum>> getRawIdsForUnifiedAlbum(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawAlbum WHERE unified_id = ?1',
        mapper: (Map<String, Object?> row) => RawAlbum(
            row['id'] as int?,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['title'] as String,
            row['trackCount'] as int),
        arguments: [albumId]);
  }

  @override
  Future<List<RawArtist>> getRawIdsForUnifiedArtist(int artistId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawArtist WHERE unified_id = ?1',
        mapper: (Map<String, Object?> row) => RawArtist(
            row['id'] as int?,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['name'] as String),
        arguments: [artistId]);
  }

  @override
  Future<List<UnifiedAlbumEntry>> getUnifiedAlbumEntries(int unifiedId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedAlbumEntry WHERE album_id = ?1 ORDER BY UnifiedAlbumEntry.index',
        mapper: (Map<String, Object?> row) => UnifiedAlbumEntry(row['album_id'] as int, row['song_id'] as int, row['index'] as int),
        arguments: [unifiedId]);
  }

  @override
  Future<List<RawSong>> getRawAlbumSongs(int rawId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawSong INNER JOIN RawAlbumEntry ON RawSong.id = RawAlbumEntry.song_id WHERE RawAlbumEntry.album_id = ?1 ORDER BY RawAlbumEntry.index',
        mapper: (Map<String, Object?> row) => RawSong(row['id'] as int?, _backendIdConverter.decode(row['backend_id'] as String), row['unified_id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [rawId]);
  }

  @override
  Future<void> internal_unifyRawSongs(List<int> rawIds, int unifiedId) async {
    const offset = 2;
    final _sqliteVariablesForRawIds =
        Iterable<String>.generate(rawIds.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedSong SET unified_id = ?1 WHERE id IN (' +
            _sqliteVariablesForRawIds +
            ')',
        arguments: [unifiedId, ...rawIds]);
  }

  @override
  Future<void> internal_unifyRawAlbums(List<int> rawIds, int unifiedId) async {
    const offset = 2;
    final _sqliteVariablesForRawIds =
        Iterable<String>.generate(rawIds.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedAlbum SET unified_id = ?1 WHERE id IN (' +
            _sqliteVariablesForRawIds +
            ')',
        arguments: [unifiedId, ...rawIds]);
  }

  @override
  Future<void> internal_unifyRawArtists(List<int> rawIds, int unifiedId) async {
    const offset = 2;
    final _sqliteVariablesForRawIds =
        Iterable<String>.generate(rawIds.length, (i) => '?${i + offset}')
            .join(',');
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedArtist SET unified_id = ?1 WHERE id IN (' +
            _sqliteVariablesForRawIds +
            ')',
        arguments: [unifiedId, ...rawIds]);
  }

  @override
  Future<void> deleteUnreferencedUnifiedSongs() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM UnifiedSong usong WHERE NOT EXISTS (SELECT 1 FROM RawSong rsong where rsong.unified_id = usong.id)');
  }

  @override
  Future<void> deleteUnreferencedUnifiedAlbums() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM UnifiedAlbum ualbum WHERE NOT EXISTS (SELECT 1 FROM RawAlbum ralbum where ralbum.unified_id = ualbum.id)');
  }

  @override
  Future<void> deleteUnreferencedUnifiedArtists() async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM UnifiedArtist uartist WHERE NOT EXISTS (SELECT 1 FROM RawArtist rartist where rartist.unified_id = uartist.id)');
  }

  @override
  Future<void> updateSongTitle(int songId, String newTitle) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedSong SET title = ?2 WHERE id = ?1',
        arguments: [songId, newTitle]);
  }

  @override
  Future<void> updateAlbumTitle(int albumId, String newTitle) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedAlbum SET title = ?2 WHERE id = ?1',
        arguments: [albumId, newTitle]);
  }

  @override
  Future<void> updateArtistTitle(int artistId, String newTitle) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE UnifiedArtist SET title = ?2 WHERE id = ?1',
        arguments: [artistId, newTitle]);
  }

  @override
  Future<List<UnifiedAlbum>> getSongAlbumIds(int songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedAlbum INNER JOIN UnifiedSongUnifiedAlbumId ON UnifiedSongUnifiedAlbumId.unified_album_id = UnifiedAlbum.id WHERE UnifiedSongUnifiedAlbumId.unified_song_id IN ?1',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(row['id'] as int?, row['title'] as String, row['trackCount'] as int, row['parent_tree_node_id'] as int?),
        arguments: [songId]);
  }

  @override
  Future<List<UnifiedArtist>> getSongArtistIds(int songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedArtist INNER JOIN UnifiedSongUnifiedArtistId ON UnifiedSongUnifiedArtistId.unified_artist_id = UnifiedArtist.id WHERE UnifiedSongUnifiedArtistId.unified_song_id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedArtist(row['id'] as int?, row['title'] as String),
        arguments: [songId]);
  }

  @override
  Future<List<UnifiedSong>> getArtistsSongs(List<int> artistIds) async {
    const offset = 1;
    final _sqliteVariablesForArtistIds =
        Iterable<String>.generate(artistIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM UnifiedSong INNER JOIN UnifiedSongUnifiedArtistId ON UnifiedSongUnifiedArtistId.unified_song_id = UnifiedSong.id WHERE UnifiedSongUnifiedArtistId.unified_artist_id IN (' +
            _sqliteVariablesForArtistIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedSong(row['id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [...artistIds]);
  }

  @override
  Future<List<UnifiedArtist>> getAlbumArtistIds(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedArtist INNER JOIN UnifiedAlbumUnifiedArtistId ON UnifiedAlbumUnifiedArtistId.unified_artist_id = UnifiedArtist.id WHERE UnifiedAlbumUnifiedArtistId.unified_album_id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedArtist(row['id'] as int?, row['title'] as String),
        arguments: [albumId]);
  }

  @override
  Future<List<UnifiedAlbum>> getArtistsAlbums(List<int> artistIds) async {
    const offset = 1;
    final _sqliteVariablesForArtistIds =
        Iterable<String>.generate(artistIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM UnifiedAlbum INNER JOIN UnifiedAlbumUnifiedArtistId ON UnifiedAlbumUnifiedArtistId.unified_album_id = UnifiedAlbum.id WHERE UnifiedAlbumUnifiedArtistId.unified_artist_id IN (' +
            _sqliteVariablesForArtistIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(row['id'] as int?, row['title'] as String, row['trackCount'] as int, row['parent_tree_node_id'] as int?),
        arguments: [...artistIds]);
  }

  @override
  Future<List<UnifiedSong>> getAlbumsSongs(List<int> albumIds) async {
    const offset = 1;
    final _sqliteVariablesForAlbumIds =
        Iterable<String>.generate(albumIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedSong INNER JOIN UnifiedAlbumEntry ON UnifiedAlbumEntry.song_id = UnifiedSong.id WHERE UnifiedAlbumEntry.album_id IN (' +
            _sqliteVariablesForAlbumIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedSong(row['id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [...albumIds]);
  }

  @override
  Future<List<UnifiedSong>> getAlbumSongs(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedSong INNER JOIN UnifiedAlbumEntry ON UnifiedAlbumEntry.song_id = UnifiedSong.id WHERE UnifiedAlbumEntry.album_id = ?1 ORDER BY UnifiedAlbumEntry.index',
        mapper: (Map<String, Object?> row) => UnifiedSong(row['id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [albumId]);
  }

  @override
  Future<void> unifyRawSongs(List<int> rawIds, int unifiedId) async {
    if (database is sqflite.Transaction) {
      await super.unifyRawSongs(rawIds, unifiedId);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.unifiedDataDao
            .unifyRawSongs(rawIds, unifiedId);
      });
    }
  }

  @override
  Future<bool> canUnifyRawAlbums(List<int> rawIds, int unifiedId) async {
    if (database is sqflite.Transaction) {
      return super.canUnifyRawAlbums(rawIds, unifiedId);
    } else {
      return (database as sqflite.Database)
          .transaction<bool>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.unifiedDataDao
            .canUnifyRawAlbums(rawIds, unifiedId);
      });
    }
  }

  @override
  Future<bool> tryUnifyRawAlbums(List<int> rawIds, int unifiedId) async {
    if (database is sqflite.Transaction) {
      return super.tryUnifyRawAlbums(rawIds, unifiedId);
    } else {
      return (database as sqflite.Database)
          .transaction<bool>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.unifiedDataDao
            .tryUnifyRawAlbums(rawIds, unifiedId);
      });
    }
  }

  @override
  Future<void> unifyRawArtists(List<int> rawIds, int unifiedId) async {
    if (database is sqflite.Transaction) {
      await super.unifyRawArtists(rawIds, unifiedId);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.unifiedDataDao
            .unifyRawArtists(rawIds, unifiedId);
      });
    }
  }
}

class _$DirDao extends DirDao {
  _$DirDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database),
        _dirTreeNodeInsertionAdapter = InsertionAdapter(
            database,
            'DirTreeNode',
            (DirTreeNode item) => <String, Object?>{
                  'id': item.id,
                  'parent_tree_node_id': item.parentTreeNodeId,
                  'name': item.name
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<DirTreeNode> _dirTreeNodeInsertionAdapter;

  @override
  Future<List<DirTreeNode>> dirChildrenOfNull() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM DirTreeNode WHERE parent_tree_node_id = NULL',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int?,
            row['name'] as String, row['parent_tree_node_id'] as int?));
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOfNull() async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM UnifiedAlbum WHERE parent_tree_node_id = NULL',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int?,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?));
  }

  @override
  Future<List<DirTreeNode>> dirChildrenOf(int parentId) async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM DirTreeNode WHERE parent_tree_node_id = ?1',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int?,
            row['name'] as String, row['parent_tree_node_id'] as int?),
        arguments: [parentId]);
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOf(int parentId) async {
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM UnifiedAlbum WHERE parent_tree_node_id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int?,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?),
        arguments: [parentId]);
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOfList(List<int> parentIds) async {
    const offset = 1;
    final _sqliteVariablesForParentIds =
        Iterable<String>.generate(parentIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT DISTINCT * FROM UnifiedAlbum WHERE parent_tree_node_id IN (' +
            _sqliteVariablesForParentIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int?,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?),
        arguments: [...parentIds]);
  }

  @override
  Future<DirTreeNode?> getById(int id) async {
    return _queryAdapter.query('SELECT * FROM DirTreeNode WHERE id = ?1',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int?,
            row['name'] as String, row['parent_tree_node_id'] as int?),
        arguments: [id]);
  }

  @override
  Future<void> _insertTreeNodeUnchecked(DirTreeNode node) async {
    await _dirTreeNodeInsertionAdapter.insert(node, OnConflictStrategy.abort);
  }

  @override
  Future<bool> chainIsAcyclic(DirTreeNode notInsertedNode) async {
    if (database is sqflite.Transaction) {
      return super.chainIsAcyclic(notInsertedNode);
    } else {
      return (database as sqflite.Database)
          .transaction<bool>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.dirDao.chainIsAcyclic(notInsertedNode);
      });
    }
  }

  @override
  Future<bool> insertTreeNode(DirTreeNode notInsertedNode) async {
    if (database is sqflite.Transaction) {
      return super.insertTreeNode(notInsertedNode);
    } else {
      return (database as sqflite.Database)
          .transaction<bool>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.dirDao.insertTreeNode(notInsertedNode);
      });
    }
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOfBfs(
      List<DirTreeNode> initialNodes) async {
    if (database is sqflite.Transaction) {
      return super.albumChildrenOfBfs(initialNodes);
    } else {
      return (database as sqflite.Database)
          .transaction<List<UnifiedAlbum>>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.dirDao.albumChildrenOfBfs(initialNodes);
      });
    }
  }
}

class _$TagDao extends TagDao {
  _$TagDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  @override
  Future<List<DirTreeNode>> getDirectlyTaggedDirs(List<int> tagIds) async {
    const offset = 1;
    final _sqliteVariablesForTagIds =
        Iterable<String>.generate(tagIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM DirTreeNode INNER JOIN TagDirJoin ON TagDirJoin.dir_id = DirTreeNode.id WHERE TagDirJoin.tag_id IN (' +
            _sqliteVariablesForTagIds +
            ')',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int?, row['name'] as String, row['parent_tree_node_id'] as int?),
        arguments: [...tagIds]);
  }

  @override
  Future<List<Tag>> getDirDirectTags(int dirId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Tag INNER JOIN TagDirJoin ON TagDirJoin.tag_id = Tag.id WHERE TagDirJoin.dir_id = ?1',
        mapper: (Map<String, Object?> row) => Tag(row['id'] as int?, row['name'] as String, row['hexRGBA'] as int),
        arguments: [dirId]);
  }

  @override
  Future<List<UnifiedAlbum>> getDirectlyTaggedAlbums(List<int> tagIds) async {
    const offset = 1;
    final _sqliteVariablesForTagIds =
        Iterable<String>.generate(tagIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedAlbum INNER JOIN TagAlbumJoin ON TagAlbumJoin.album_id = UnifiedAlbum.id WHERE TagAlbumJoin.tag_id IN (' +
            _sqliteVariablesForTagIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(row['id'] as int?, row['title'] as String, row['trackCount'] as int, row['parent_tree_node_id'] as int?),
        arguments: [...tagIds]);
  }

  @override
  Future<List<Tag>> getAlbumDirectTags(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Tag INNER JOIN TagAlbumJoin ON TagAlbumJoin.tag_id = Tag.id WHERE TagAlbumJoin.album_id = ?1',
        mapper: (Map<String, Object?> row) => Tag(row['id'] as int?, row['name'] as String, row['hexRGBA'] as int),
        arguments: [albumId]);
  }

  @override
  Future<List<UnifiedArtist>> getDirectlyTaggedArtists(List<int> tagIds) async {
    const offset = 1;
    final _sqliteVariablesForTagIds =
        Iterable<String>.generate(tagIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedArtist INNER JOIN TagArtistJoin ON TagArtistJoin.artist_id = UnifiedArtist.id WHERE TagArtistJoin.tag_id IN (' +
            _sqliteVariablesForTagIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedArtist(row['id'] as int?, row['title'] as String),
        arguments: [...tagIds]);
  }

  @override
  Future<List<Tag>> getArtistDirectTags(int artistId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Tag INNER JOIN TagArtistJoin ON TagArtistJoin.tag_id = Tag.id WHERE TagArtistJoin.artist_id = ?1',
        mapper: (Map<String, Object?> row) => Tag(row['id'] as int?, row['name'] as String, row['hexRGBA'] as int),
        arguments: [artistId]);
  }

  @override
  Future<List<UnifiedSong>> getDirectlyTaggedSongs(List<int> tagIds) async {
    const offset = 1;
    final _sqliteVariablesForTagIds =
        Iterable<String>.generate(tagIds.length, (i) => '?${i + offset}')
            .join(',');
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedSong INNER JOIN TagSongJoin ON TagSongJoin.song_id = UnifiedSong.id WHERE TagSongJoin.tag_id IN (' +
            _sqliteVariablesForTagIds +
            ')',
        mapper: (Map<String, Object?> row) => UnifiedSong(row['id'] as int?, row['title'] as String, row['lengthMs'] as int),
        arguments: [...tagIds]);
  }

  @override
  Future<List<Tag>> getSongDirectTags(int songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Tag INNER JOIN TagSongJoin ON TagSongJoin.tag_id = Tag.id WHERE TagSongJoin.song_id = ?1',
        mapper: (Map<String, Object?> row) => Tag(row['id'] as int?, row['name'] as String, row['hexRGBA'] as int),
        arguments: [songId]);
  }

  @override
  Future<Set<int>> getAllTaggedUnifiedSongIds(
      UnifiedDataDao unifiedDataDao, DirDao dirDao, List<int> tagIds) async {
    if (database is sqflite.Transaction) {
      return super.getAllTaggedUnifiedSongIds(unifiedDataDao, dirDao, tagIds);
    } else {
      return (database as sqflite.Database)
          .transaction<Set<int>>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.tagDao
            .getAllTaggedUnifiedSongIds(unifiedDataDao, dirDao, tagIds);
      });
    }
  }
}

class _$ImporterDao extends ImporterDao {
  _$ImporterDao(this.database, this.changeListener)
      : _unifiedSongInsertionAdapter = InsertionAdapter(
            database,
            'UnifiedSong',
            (UnifiedSong item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'lengthMs': item.lengthMs
                }),
        _unifiedAlbumInsertionAdapter = InsertionAdapter(
            database,
            'UnifiedAlbum',
            (UnifiedAlbum item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'trackCount': item.trackCount,
                  'parent_tree_node_id': item.parentTreeNodeId
                }),
        _unifiedAlbumEntryInsertionAdapter = InsertionAdapter(
            database,
            'UnifiedAlbumEntry',
            (UnifiedAlbumEntry item) => <String, Object?>{
                  'album_id': item.albumId,
                  'song_id': item.songId,
                  'index': item.index
                }),
        _unifiedArtistInsertionAdapter = InsertionAdapter(
            database,
            'UnifiedArtist',
            (UnifiedArtist item) =>
                <String, Object?>{'id': item.id, 'title': item.title});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final InsertionAdapter<UnifiedSong> _unifiedSongInsertionAdapter;

  final InsertionAdapter<UnifiedAlbum> _unifiedAlbumInsertionAdapter;

  final InsertionAdapter<UnifiedAlbumEntry> _unifiedAlbumEntryInsertionAdapter;

  final InsertionAdapter<UnifiedArtist> _unifiedArtistInsertionAdapter;

  @override
  Future<List<int>> insertUnifiedSongs(List<UnifiedSong> songs) {
    return _unifiedSongInsertionAdapter.insertListAndReturnIds(
        songs, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertUnifiedAlbums(List<UnifiedAlbum> albums) {
    return _unifiedAlbumInsertionAdapter.insertListAndReturnIds(
        albums, OnConflictStrategy.abort);
  }

  @override
  Future<void> insertUnifiedAlbumEntries(
      List<UnifiedAlbumEntry> albumEntries) async {
    await _unifiedAlbumEntryInsertionAdapter.insertList(
        albumEntries, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> insertUnifiedArtists(List<UnifiedArtist> artists) {
    return _unifiedArtistInsertionAdapter.insertListAndReturnIds(
        artists, OnConflictStrategy.abort);
  }

  @override
  Future<void> importData(ImportData toImport) async {
    if (database is sqflite.Transaction) {
      await super.importData(toImport);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.importerDao.importData(toImport);
      });
    }
  }
}

// ignore_for_file: unused_element
final _backendIdConverter = BackendIdConverter();
