/*
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:tuple/tuple.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MusicTaggingApp());
}

class Routes {
  static const String home = "/";
  static const String importAndroid = "/import";
  static const String importAndroidSong = "/import/songs";
  static const String importAndroidAlbums = "/import/albums";
  static const String importAndroidArtists = "/import/artists";
}

class MusicTaggingApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MusicTaggingAppState();
}

class _MusicTaggingAppState extends State<MusicTaggingApp> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Tagging App',
      initialRoute: '/',
      routes: {
        Routes.home: (context) => MusicTaggingHomePage(),
        Routes.importAndroid: (context) => MusicTaggingImportPage(),
      },
    );
  }
}

class MusicTaggingHomePage extends StatelessWidget {
  MusicTaggingHomePage({Key? key, this.title}) : super(key: key);

  final String? title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text("Import from Android Media"),
              onPressed: () =>
                  Navigator.pushNamed(context, Routes.importAndroid),
            )
          ],
        ),
      ),
    );
  }
}

class MusicTaggingImportAlbumPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Import Albums")));
  }
}

class MusicTaggingImportPage extends StatelessWidget {
  MusicTaggingImportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Import Data")),
      body: ChangeNotifierProvider(
          create: (context) => PendingImportModel(),
          child: Column(
            children: [
              Consumer<PendingImportModel>(
                builder: (context, pending, child) => ElevatedButton(
                  child: Text("Import Albums"),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      // Doesn't need a ChangeNotifierProvider,
                      // because the state of the album import screen doesn't
                      // change based on it
                      builder: (context) => Provider<PendingImportModel>(
                        create: (context) => pending,
                        builder: (context, child) =>
                            MusicTaggingImportAlbumPage(),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: MusicTaggingCurrentImportList(),
              ),
            ],
          )),
    );
  }

  // @override
  // State<StatefulWidget> createState() => _MusicTaggingImportPageState();
}

class MusicTaggingCurrentImportList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<PendingImportModel>(
      builder: (context, pending, child) => ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: pending.items.length,
        itemBuilder: (context, index) => pending.items[index].build(),
      ),
    );
  }
}

enum MappedItemType { Song, Artist, Album }

class ItemPendingImport {
  final MappedItemType mappedType;
  final BackendId backendId;
  // The Database ID of the item this will be merged into
  // i.e. may want to merge the imported "Utada Hikaru" artist
  // with the pre-existing "Hikaru Udata" artist.
  final int? mergeInto;
  final String? mergeIntoName;
  final String name;

  ItemPendingImport(this.mappedType,
      {required this.backendId,
      required this.name,
      this.mergeInto,
      this.mergeIntoName});

  Widget build() {
    return Container(
      height: 50,
      color: Colors.amber[100],
      child: Center(child: Text(name)),
    );
  }
}

class SongPendingImport extends ItemPendingImport {
  SongPendingImport.asNew(BackendId backendId, String name)
      : super(MappedItemType.Song, backendId: backendId, name: name);
  SongPendingImport.asMerged(
      BackendId backendId, int mergeInto, String mergeIntoName, String name)
      : super(MappedItemType.Song,
            backendId: backendId,
            mergeInto: mergeInto,
            mergeIntoName: mergeIntoName,
            name: name);
}

class PendingImportModel extends ChangeNotifier {
  final List<ItemPendingImport> _items = [];

  UnmodifiableListView<ItemPendingImport> get items =>
      UnmodifiableListView(_items);

  void addAll(Iterable<ItemPendingImport> items) {
    _items.addAll(items);
    notifyListeners();
  }

  void removeByBackendId(BackendId id) {
    _items.removeWhere((element) => element.backendId == id);
    notifyListeners();
  }
}
*/
