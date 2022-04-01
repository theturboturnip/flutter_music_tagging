import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart' as AndroidAudio;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:collection/collection.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'common.dart';
import 'import_root.dart';

///
/// BLOC EVENTS
///

abstract class ImportPopulateEvent extends Equatable {}

enum SelectionEventType { Add, Remove }

class SelectionEvent extends ImportPopulateEvent {
  final SelectionEventType type;
  final TypedBackendId item;

  SelectionEvent(this.type, this.item);
  SelectionEvent.add(this.item) : type = SelectionEventType.Add;
  SelectionEvent.remove(this.item) : type = SelectionEventType.Remove;

  @override
  List<Object?> get props => [type, item];
}

class SelectionGroupEvent extends ImportPopulateEvent {
  final SelectionEventType type;

  SelectionGroupEvent.add() : type = SelectionEventType.Add;
  SelectionGroupEvent.remove() : type = SelectionEventType.Remove;

  @override
  List<Object?> get props => [type];
}

enum AlbumSortType { TitleAsc, TitleDesc }

class ResortEvent extends ImportPopulateEvent {
  final AlbumSortType type;
  ResortEvent(this.type);

  @override
  List<Object?> get props => [type];
}

class ReceiveAlbumListEvent extends ImportPopulateEvent {
  final IList<AndroidAlbumInfo> albums;
  ReceiveAlbumListEvent(this.albums);

  @override
  List<Object?> get props => [albums];
}

class RequestReloadAlbumsEvent extends ImportPopulateEvent {
  @override
  List<Object?> get props => [];
}

///
/// BLOC STATE
///

class ImportPopulateState {
  final IList<AndroidAlbumInfo>? availableAlbums;
  final ISet<TypedBackendId> selectedAlbums;

  bool get hasSelectedAll => (availableAlbums == null
      ? false
      : availableAlbums!.length == selectedAlbums.length);

  ISet<AndroidAlbumInfo> get selectedAlbumsAsAlbums => availableAlbums == null
      ? ISet()
      : availableAlbums!.where((e) => selectedAlbums.contains(e.id)).toISet();

  ImportPopulateState.initial(ISet<TypedBackendId> selectedItems)
      : availableAlbums = null,
        selectedAlbums = selectedItems;
  ImportPopulateState(this.availableAlbums, this.selectedAlbums);

  ImportPopulateState plus(TypedBackendId item) {
    return ImportPopulateState(availableAlbums, selectedAlbums.add(item));
  }

  ImportPopulateState minus(TypedBackendId item) {
    return ImportPopulateState(availableAlbums, selectedAlbums.remove(item));
  }

  ImportPopulateState selectingAll() {
    return ImportPopulateState(
        availableAlbums, availableAlbums?.map((e) => e.id).toISet() ?? ISet());
  }

  ImportPopulateState selectingNone() {
    return ImportPopulateState(availableAlbums, ISet());
  }

  ImportPopulateState withAlbums(IList<AndroidAlbumInfo> newAlbums,
      {AlbumSortType sortType = AlbumSortType.TitleAsc}) {
    return ImportPopulateState(
        newAlbums.sorted(albumSortingFunction(sortType)).toIList(),
        selectedAlbums.intersection(newAlbums.map((e) => e.id)));
  }

  ImportPopulateState resorted(AlbumSortType sortType) {
    return ImportPopulateState(
        availableAlbums?.sorted(albumSortingFunction(sortType)).toIList(),
        selectedAlbums);
  }

  int Function(AndroidAlbumInfo, AndroidAlbumInfo) albumSortingFunction(
      AlbumSortType sortType) {
    switch (sortType) {
      case AlbumSortType.TitleAsc:
        return (a, b) => a.title.compareTo(b.title);
      case AlbumSortType.TitleDesc:
        return (b, a) => a.title.compareTo(b.title);
    }
  }
}

///
/// BLOC
///

class ImportPopulateBloc
    extends Bloc<ImportPopulateEvent, ImportPopulateState> {
  ImportPopulateBloc(
      {required this.audioQuery, required ISet<TypedBackendId> alreadySelected})
      : super(ImportPopulateState.initial(alreadySelected)) {
    on<SelectionEvent>((event, emit) {
      switch (event.type) {
        case SelectionEventType.Add:
          emit(state.plus(event.item));
          break;
        case SelectionEventType.Remove:
          emit(state.minus(event.item));
          break;
      }
    });
    on<SelectionGroupEvent>((event, emit) {
      switch (event.type) {
        case SelectionEventType.Add:
          emit(state.selectingAll());
          break;
        case SelectionEventType.Remove:
          emit(state.selectingNone());
          break;
      }
    });
    on<ResortEvent>((event, emit) => emit(state.resorted(event.type)));
    on<RequestReloadAlbumsEvent>((event, emit) async {
      final albums = await _retrieveAndroidAlbums();
      emit(state.withAlbums(albums));
    });
  }

  final AndroidAudio.FlutterAudioQuery audioQuery;

  Future<IList<AndroidAlbumInfo>> _retrieveAndroidAlbums() async {
    final albums = await audioQuery.getAlbums();
    return albums
        .map((e) => AndroidAlbumInfo(
            TypedBackendId.from(StoredResourceType.Album, "android", e.id),
            e.title,
            e.artist))
        .toIList();
  }
}

///
/// WIDGETS
///

class SelectedAlbumsList extends StatefulWidget {
  @override
  _SelectedAlbumsListState createState() => _SelectedAlbumsListState();
}

class AlbumListItem extends StatelessWidget {
  final AndroidAlbumInfo album;
  final bool selected;

  AlbumListItem({Key? key, required this.album, required this.selected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final event = selected
        ? SelectionEvent.remove(album.id)
        : SelectionEvent.add(album.id);
    return Material(
      child: ListTile(
        // leading: Text('${this.album.title}', style: textTheme.caption),
        title: Text(album.title),
        isThreeLine: false,
        subtitle: Text(album.artistName),
        dense: false,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: selected,
              onChanged: (bool? selected) {
                ReadContext(context).read<ImportPopulateBloc>().add(event);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedAlbumsListState extends State<SelectedAlbumsList> {
  final _scrollController = ScrollController();
  late ImportPopulateBloc _importBloc;

  @override
  void initState() {
    super.initState();
    _importBloc = ReadContext(context).read<ImportPopulateBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImportPopulateBloc, ImportPopulateState>(
      builder: (context, state) {
        if (state.availableAlbums == null) {
          return const Center(child: Text("Looking for albums..."));
        } else if (state.availableAlbums!.isEmpty) {
          return const Center(child: Text("No albums found :-("));
        } else {
          return ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              final album = state.availableAlbums![index];
              bool selected = state.selectedAlbums.contains(album.id);
              return AlbumListItem(album: album, selected: selected);
            },
            itemCount: state.availableAlbums!.length,
            controller: _scrollController,
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

///
/// MODULE
///

class ImportPopulateModule extends Module {
  List<Bind> get binds => [
        // TODO - this is supposed to bring the parent scope ImportRootBloc into this scope. May be unnecessary
        Bind((i) => i.get<ImportRootBloc>()),
        Bind.factory((i) => ImportPopulateBloc(
            audioQuery: AndroidAudio.FlutterAudioQuery(),
            alreadySelected: i
                .get<ImportRootBloc>()
                .state
                .selectedRoots
                .map((e) => e.id)
                .toISet())
          ..add(RequestReloadAlbumsEvent())),
      ];

  @override
  List<ModularRoute> get routes =>
      [ChildRoute("/", child: (_, __) => ImportPopulatePage())];
}

class ImportPopulatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => Modular.get<ImportPopulateBloc>(),
      child: BlocBuilder<ImportPopulateBloc, ImportPopulateState>(
        builder: (context, state) => WillPopScope(
          onWillPop: () async {
            // Set the root bloc's selected data when we leave
            Modular.get<ImportRootBloc>().add(
              ImportRootSetRoots(state.selectedAlbumsAsAlbums),
            );
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Import Albums"),
              actions: [
                PopupMenuButton<AlbumSortType>(
                  icon: Icon(Icons.sort_sharp),
                  onSelected: (sortType) => ReadContext(context)
                      .read<ImportPopulateBloc>()
                      .add(ResortEvent(sortType)),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<AlbumSortType>>[
                    const PopupMenuItem<AlbumSortType>(
                      value: AlbumSortType.TitleAsc,
                      child: Text('Title (Ascending)'),
                    ),
                    const PopupMenuItem<AlbumSortType>(
                      value: AlbumSortType.TitleDesc,
                      child: Text('Title (Descending)'),
                    ),
                  ],
                ),
                Checkbox(
                  // If selected all, true => checked
                  // Otherwise, if not empty => partially checked
                  // Otherwise, must be empty => not checked
                  value: state.hasSelectedAll
                      ? true
                      : (state.selectedAlbums.isNotEmpty ? null : false),
                  tristate: true,
                  onChanged: (bool? selected) {
                    // If original value was false, selected = true
                    // If original value was true, selected = null
                    // If original value was null, selected = false

                    // => if selected = null, original value was true => we should deselect.
                    // otherwise, we are partially full or empty => we should select all.
                    switch (selected) {
                      case true:
                        // original was false => empty => select all
                        ReadContext(context)
                            .read<ImportPopulateBloc>()
                            .add(SelectionGroupEvent.add());
                        break;
                      case false:
                        // orignal was null => partially full => select all
                        ReadContext(context)
                            .read<ImportPopulateBloc>()
                            .add(SelectionGroupEvent.add());
                        break;
                      case null:
                        // original was true => full => deselect all
                        ReadContext(context)
                            .read<ImportPopulateBloc>()
                            .add(SelectionGroupEvent.remove());
                        break;
                    }
                  },
                ),
              ],
            ),
            body: SelectedAlbumsList(),
          ),
        ),
      ),
    );
  }
}
