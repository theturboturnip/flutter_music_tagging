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
            'CREATE TABLE IF NOT EXISTS `RawSong` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `title` TEXT NOT NULL, `lengthMs` INTEGER NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawSongArtist` (`song_id` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`song_id`) REFERENCES `RawSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`artist_id`) REFERENCES `RawArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`song_id`, `artist_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbum` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `title` TEXT NOT NULL, `trackCount` INTEGER NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbumArtist` (`album_id` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `RawAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`artist_id`) REFERENCES `RawArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `artist_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawAlbumEntry` (`album_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, `index` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `RawAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`song_id`) REFERENCES `RawSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `index`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RawArtist` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `backend_id` TEXT NOT NULL, `unified_id` INTEGER, `name` TEXT NOT NULL, FOREIGN KEY (`unified_id`) REFERENCES `UnifiedArtist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedSong` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `lengthMs` INTEGER NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedAlbum` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `trackCount` INTEGER NOT NULL, `parent_tree_node_id` INTEGER, FOREIGN KEY (`parent_tree_node_id`) REFERENCES `DirTreeNode` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedAlbumEntry` (`album_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, `index` INTEGER NOT NULL, FOREIGN KEY (`album_id`) REFERENCES `UnifiedAlbum` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, FOREIGN KEY (`song_id`) REFERENCES `UnifiedSong` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`album_id`, `index`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `UnifiedArtist` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `DirTreeNode` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `parent_tree_node_id` INTEGER, `name` TEXT NOT NULL, FOREIGN KEY (`parent_tree_node_id`) REFERENCES `DirTreeNode` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');

        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongRawAlbumId` AS SELECT RawAlbumEntry.album_id as raw_album_id, RawSong.unified_id as unified_song_id FROM RawSong INNER JOIN RawAlbumEntry ON RawSong.id = RawAlbumEntry.song_id WHERE RawSong.unified_id NOT NULL');
        await database.execute(
            'CREATE VIEW IF NOT EXISTS `UnifiedSongUnifiedAlbumId` AS SELECT DISTINCT RawAlbum.unified_id as unified_album_id, UnifiedSongRawAlbumId.unified_song_id as unified_song_id FROM UnifiedSongRawAlbumId INNER JOIN RawAlbum ON UnifiedSongUnifiedAlbumId.rawAlbumId = RawAlbum.id WHERE RawAlbum.unified_id NOT NULL');

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
            row['id'] as int,
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
  Future<List<RawSong>> getRawIdsForUnifiedSong(int songId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawSong WHERE unified_id = ?1',
        mapper: (Map<String, Object?> row) => RawSong(
            row['id'] as int,
            _backendIdConverter.decode(row['backend_id'] as String),
            row['unified_id'] as int?,
            row['title'] as String,
            row['lengthMs'] as int),
        arguments: [songId]);
  }

  @override
  Future<List<RawAlbum>> getRawIdsForUnifiedAlbum(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RawAlbum WHERE unified_id = ?1',
        mapper: (Map<String, Object?> row) => RawAlbum(
            row['id'] as int,
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
            row['id'] as int,
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
        mapper: (Map<String, Object?> row) => RawSong(row['id'] as int, _backendIdConverter.decode(row['backend_id'] as String), row['unified_id'] as int?, row['title'] as String, row['lengthMs'] as int),
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
        'SELECT * FROM UnifiedAlbum INNER JOIN UnifiedSongUnifiedAlbumId ON UnifiedSongUnifiedAlbumId.unified_album_id = UnifiedAlbum.id WHERE UnifiedSongUnifiedAlbumId.unified_song_id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(row['id'] as int, row['title'] as String, row['trackCount'] as int, row['parent_tree_node_id'] as int?),
        arguments: [songId]);
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
        'SELECT * FROM DirTreeNode WHERE parentTreeNodeId = NULL',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int,
            row['name'] as String, row['parent_tree_node_id'] as int?));
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOfNull() async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedAlbum WHERE parentTreeNodeId = NULL',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?));
  }

  @override
  Future<List<DirTreeNode>> dirChildrenOf(int parentId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM DirTreeNode WHERE parentTreeNodeId = ?1',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int,
            row['name'] as String, row['parent_tree_node_id'] as int?),
        arguments: [parentId]);
  }

  @override
  Future<List<UnifiedAlbum>> albumChildrenOf(int parentId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM UnifiedAlbum WHERE parent_tree_node_id = ?1',
        mapper: (Map<String, Object?> row) => UnifiedAlbum(
            row['id'] as int,
            row['title'] as String,
            row['trackCount'] as int,
            row['parent_tree_node_id'] as int?),
        arguments: [parentId]);
  }

  @override
  Future<DirTreeNode?> getById(int id) async {
    return _queryAdapter.query('SELECT * FROM DirTreeNode WHERE id = ?1',
        mapper: (Map<String, Object?> row) => DirTreeNode(row['id'] as int,
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
}

// ignore_for_file: unused_element
final _backendIdConverter = BackendIdConverter();
