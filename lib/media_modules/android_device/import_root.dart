import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:flutter_music_tagging/database/database.dart';
import 'package:flutter_music_tagging/database/pre_import.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart' as AndroidAudio;

import 'common.dart';
import 'import_populate.dart';

class ImportRootState extends Equatable {
  final ISet<AndroidAlbumInfo> selectedRoots;

  ImportRootState.initial() : selectedRoots = ISet<AndroidAlbumInfo>();
  ImportRootState({required this.selectedRoots});

  ImportRootState withRoots(ISet<AndroidAlbumInfo> newRoots) {
    return ImportRootState(selectedRoots: newRoots);
  }

  Future<void> importRootsToDatabase() async {
    // Generate ImportData from AndroidAlbumInfo
    final androidQ = AndroidAudio.FlutterAudioQuery();
    final db = AppDatabase.getConnection();

    // TODO how tf do you get artists

    // Generate list of songs
    // Foreach album, look up its songs, then convert to ImportSong
    IMap<BackendId, IList<AndroidAudio.SongInfo>> albumAndroidTracklists =
        IMap.fromEntries(
            await Future.wait(this.selectedRoots.map((album) async => MapEntry(
                  album.id.id,
                  (await androidQ.getSongsFromAlbum(
                          albumId: album.id.id.backendId))
                      .toIList(),
                ))));
    IList<ImportSong> songList = albumAndroidTracklists
        .mapTo((key, value) => value)
        .expand((element) => element)
        .map((androidSong) => ImportSong(BackendId("android", androidSong.id),
            androidSong.title, 0, <BackendId>[].toIList()))
        .toIList();
    IMap<BackendId, ImportSong> songs = IMap.fromEntries(
        songList.map((song) => MapEntry(song.backendId, song)));

    IMap<BackendId, ImportAlbum> albums =
        IMap.fromEntries(this.selectedRoots.map((androidInfo) => MapEntry(
              androidInfo.id.id,
              ImportAlbum(
                  androidInfo.id.id,
                  androidInfo.title,
                  albumAndroidTracklists[androidInfo.id.id]!
                      .map(
                          (androidSong) => BackendId("android", androidSong.id))
                      .toIList(),
                  <BackendId>[].toIList()),
            )));

    var data = ImportData(songs, albums, <BackendId, ImportArtist>{}.toIMap());

    await (await db).importerDao.importData(data);
  }

  @override
  List<Object?> get props => [selectedRoots];
}

abstract class ImportRootEvent extends Equatable {}

class ImportRootSetRoots extends ImportRootEvent {
  final ISet<AndroidAlbumInfo> newRoots;

  ImportRootSetRoots(this.newRoots);

  @override
  List<Object?> get props => [newRoots];
}

class ImportRootBloc extends Bloc<ImportRootEvent, ImportRootState> {
  ImportRootBloc() : super(ImportRootState.initial()) {
    on<ImportRootSetRoots>(
        (event, emit) => emit(state.withRoots(event.newRoots)));
  }
}

class ImportModule extends Module {
  List<Bind> get binds => [
        // Note - "Singleton" here means "created when the module is entered,
        // destroyed when the module is exited,
        //always the same value for any children that access it".
        // not "created once, never destroyed ever".
        Bind.singleton((i) => ImportRootBloc()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute("/", child: (_, __) => ImportRootPage()),
        // ChildRoute("/select_roots", child: (_, __) => ImportPopulatePage())
        ModuleRoute("/select_roots", module: ImportPopulateModule())
      ];
}

class ImportRootPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => Modular.get<ImportRootBloc>(),
        child: BlocBuilder<ImportRootBloc, ImportRootState>(
            builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text("Import Music")),
            body: ListView.builder(
              itemCount: state.selectedRoots.length,
              itemBuilder: (context, i) => Container(
                padding: EdgeInsets.all(8),
                child: Row(
                  children: [
                    Text(state.selectedRoots[i].title),
                    Text(state.selectedRoots[i].artistName)
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Modular.to.pushNamed("select_roots"),
              child: const Icon(Icons.add),
              tooltip: 'Create',
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              child: Row(
                children: [
                  TextButton(
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) => WillPopScope(
                            child: AlertDialog(
                                content: const Text("Importing...")),
                            onWillPop: () async => false),
                        barrierDismissible: false,
                      );
                      await state.importRootsToDatabase();
                      Modular.to.popUntil(ModalRoute.withName('/home'));
                    },
                    child: const Text("Import"),
                  )
                ],
              ),
              shape: const CircularNotchedRectangle(),
            ),
          );
        }));
  }
}
