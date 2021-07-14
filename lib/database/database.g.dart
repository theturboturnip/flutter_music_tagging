// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

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

  SongDao? _songDaoInstance;

  AlbumDao? _albumDaoInstance;

  ArtistDao? _artistDaoInstance;

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback? callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
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
            'CREATE TABLE IF NOT EXISTS `Song` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `lengthMs` INTEGER NOT NULL, `album_id` INTEGER, FOREIGN KEY (`album_id`) REFERENCES `Album` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Song_BackendRow` (`base_id` INTEGER NOT NULL, `backend_id` TEXT NOT NULL, FOREIGN KEY (`base_id`) REFERENCES `Song` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`base_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Album` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `title` TEXT NOT NULL, `trackCount` INTEGER NOT NULL, `artist_id` INTEGER NOT NULL, FOREIGN KEY (`artist_id`) REFERENCES `Artist` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Album_BackendRow` (`base_id` INTEGER NOT NULL, `backend_id` TEXT NOT NULL, PRIMARY KEY (`base_id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `AlbumEntry` (`album_id` INTEGER NOT NULL, `song_id` INTEGER NOT NULL, `index` INTEGER NOT NULL, PRIMARY KEY (`album_id`, `index`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Artist` (`id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `name` TEXT NOT NULL)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Artist_BackendRow` (`base_id` INTEGER NOT NULL, `backend_id` TEXT NOT NULL, FOREIGN KEY (`base_id`) REFERENCES `Album` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`base_id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  SongDao get songDao {
    return _songDaoInstance ??= _$SongDao(database, changeListener);
  }

  @override
  AlbumDao get albumDao {
    return _albumDaoInstance ??= _$AlbumDao(database, changeListener);
  }

  @override
  ArtistDao get artistDao {
    return _artistDaoInstance ??= _$ArtistDao(database, changeListener);
  }
}

class _$SongDao extends SongDao {
  _$SongDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _songInsertionAdapter = InsertionAdapter(
            database,
            'Song',
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'lengthMs': item.lengthMs,
                  'album_id': item.albumId
                },
            changeListener),
        _song_BackendRowInsertionAdapter = InsertionAdapter(
            database,
            'Song_BackendRow',
            (Song_BackendRow item) => <String, Object?>{
                  'base_id': item.baseId,
                  'backend_id': _backendIdConverter.encode(item.backendId)
                }),
        _songUpdateAdapter = UpdateAdapter(
            database,
            'Song',
            ['id'],
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'lengthMs': item.lengthMs,
                  'album_id': item.albumId
                },
            changeListener),
        _songDeletionAdapter = DeletionAdapter(
            database,
            'Song',
            ['id'],
            (Song item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'lengthMs': item.lengthMs,
                  'album_id': item.albumId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Song> _songInsertionAdapter;

  final InsertionAdapter<Song_BackendRow> _song_BackendRowInsertionAdapter;

  final UpdateAdapter<Song> _songUpdateAdapter;

  final DeletionAdapter<Song> _songDeletionAdapter;

  @override
  Future<List<Song>> getSongsByKeyword(String keyword) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Song where instr(title, ?) > 0',
        arguments: [keyword],
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Stream<List<Song>> listenForSongsByKeyword(String keyword) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM Song where instr(title, ?) > 0',
        arguments: [keyword],
        queryableName: 'Song',
        isView: false,
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Stream<List<Song>> listenForAllSongs() {
    return _queryAdapter.queryListStream('SELECT * FROM Song ORDER BY title',
        queryableName: 'Song',
        isView: false,
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Future<List<int>> insertValues(List<Song> values) {
    return _songInsertionAdapter.insertListAndReturnIds(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<void> _insertBackendElems(List<Song_BackendRow> values) async {
    await _song_BackendRowInsertionAdapter.insertList(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateValues(List<Song> values) {
    return _songUpdateAdapter.updateListAndReturnChangedRows(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteValues(List<Song> values) async {
    await _songDeletionAdapter.deleteList(values);
  }

  @override
  Future<void> insertBackendMappings(Song item, List<BackendId> items) async {
    if (database is sqflite.Transaction) {
      await super.insertBackendMappings(item, items);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.songDao.insertBackendMappings(item, items);
      });
    }
  }
}

class _$AlbumDao extends AlbumDao {
  _$AlbumDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _albumInsertionAdapter = InsertionAdapter(
            database,
            'Album',
            (Album item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'trackCount': item.trackCount,
                  'artist_id': item.artistId
                }),
        _albumEntryInsertionAdapter = InsertionAdapter(
            database,
            'AlbumEntry',
            (AlbumEntry item) => <String, Object?>{
                  'album_id': item.albumId,
                  'song_id': item.songId,
                  'index': item.index
                }),
        _album_BackendRowInsertionAdapter = InsertionAdapter(
            database,
            'Album_BackendRow',
            (Album_BackendRow item) => <String, Object?>{
                  'base_id': item.baseId,
                  'backend_id': _backendIdConverter.encode(item.backendId)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Album> _albumInsertionAdapter;

  final InsertionAdapter<AlbumEntry> _albumEntryInsertionAdapter;

  final InsertionAdapter<Album_BackendRow> _album_BackendRowInsertionAdapter;

  @override
  Future<Album?> getAlbum(int id) async {
    return _queryAdapter.query('SELECT * FROM Album where albumId = ?',
        arguments: [id],
        mapper: (Map<String, Object?> row) => Album(
            row['id'] as int,
            row['title'] as String,
            row['trackCount'] as int,
            row['artist_id'] as int));
  }

  @override
  Future<List<Song>> getAlbumSongs(int albumId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM Song INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id WHERE AlbumEntries.album_id = ? ORDER BY AlbumEntries.index',
        arguments: [albumId],
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Stream<List<Song>> listenForAlbumSongs(int albumId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM Song INNER JOIN AlbumEntries ON AlbumEntries.song_id = Song.id WHERE AlbumEntries.album_id = ? ORDER BY AlbumEntries.index',
        arguments: [albumId],
        queryableName: 'Song',
        isView: false,
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Stream<List<Song>> listenForAllAlbums() {
    return _queryAdapter.queryListStream('SELECT * FROM Song ORDER BY title',
        queryableName: 'Song',
        isView: false,
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Future<void> deleteGroupEntries(int baseId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE * FROM AlbumEntry where albumId = ?',
        arguments: [baseId]);
  }

  @override
  Future<int> _insertBase(Album base) {
    return _albumInsertionAdapter.insertAndReturnId(
        base, OnConflictStrategy.abort);
  }

  @override
  Future<List<int>> _insertEntries(List<AlbumEntry> entries) {
    return _albumEntryInsertionAdapter.insertListAndReturnIds(
        entries, OnConflictStrategy.abort);
  }

  @override
  Future<void> _insertBackendElems(List<Album_BackendRow> values) async {
    await _album_BackendRowInsertionAdapter.insertList(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<int> insertGroup(Album base_noId, List<Song> referenced) async {
    if (database is sqflite.Transaction) {
      return super.insertGroup(base_noId, referenced);
    } else {
      return (database as sqflite.Database)
          .transaction<int>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.albumDao.insertGroup(base_noId, referenced);
      });
    }
  }

  @override
  Future<void> updateGroup(Album base, List<Song> referenced) async {
    if (database is sqflite.Transaction) {
      await super.updateGroup(base, referenced);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.albumDao.updateGroup(base, referenced);
      });
    }
  }

  @override
  Future<void> insertBackendMappings(Album item, List<BackendId> items) async {
    if (database is sqflite.Transaction) {
      await super.insertBackendMappings(item, items);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.albumDao.insertBackendMappings(item, items);
      });
    }
  }
}

class _$ArtistDao extends ArtistDao {
  _$ArtistDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _artistInsertionAdapter = InsertionAdapter(
            database,
            'Artist',
            (Artist item) =>
                <String, Object?>{'id': item.id, 'name': item.name}),
        _artist_BackendRowInsertionAdapter = InsertionAdapter(
            database,
            'Artist_BackendRow',
            (Artist_BackendRow item) => <String, Object?>{
                  'base_id': item.baseId,
                  'backend_id': _backendIdConverter.encode(item.backendId)
                }),
        _artistUpdateAdapter = UpdateAdapter(
            database,
            'Artist',
            ['id'],
            (Artist item) =>
                <String, Object?>{'id': item.id, 'name': item.name}),
        _artistDeletionAdapter = DeletionAdapter(
            database,
            'Artist',
            ['id'],
            (Artist item) =>
                <String, Object?>{'id': item.id, 'name': item.name});

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Artist> _artistInsertionAdapter;

  final InsertionAdapter<Artist_BackendRow> _artist_BackendRowInsertionAdapter;

  final UpdateAdapter<Artist> _artistUpdateAdapter;

  final DeletionAdapter<Artist> _artistDeletionAdapter;

  @override
  Stream<List<Song>> listenForAllArtists() {
    return _queryAdapter.queryListStream('SELECT * FROM Song ORDER BY title',
        queryableName: 'Song',
        isView: false,
        mapper: (Map<String, Object?> row) => Song(
            row['id'] as int,
            row['title'] as String,
            row['lengthMs'] as int,
            row['album_id'] as int?));
  }

  @override
  Future<List<int>> insertValues(List<Artist> values) {
    return _artistInsertionAdapter.insertListAndReturnIds(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<void> _insertBackendElems(List<Artist_BackendRow> values) async {
    await _artist_BackendRowInsertionAdapter.insertList(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateValues(List<Artist> values) {
    return _artistUpdateAdapter.updateListAndReturnChangedRows(
        values, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteValues(List<Artist> values) async {
    await _artistDeletionAdapter.deleteList(values);
  }

  @override
  Future<void> insertBackendMappings(Artist item, List<BackendId> items) async {
    if (database is sqflite.Transaction) {
      await super.insertBackendMappings(item, items);
    } else {
      await (database as sqflite.Database)
          .transaction<void>((transaction) async {
        final transactionDatabase = _$AppDatabase(changeListener)
          ..database = transaction;
        await transactionDatabase.artistDao.insertBackendMappings(item, items);
      });
    }
  }
}

// ignore_for_file: unused_element
final _backendIdConverter = BackendIdConverter();
