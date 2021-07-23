import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';
import 'package:rxdart/rxdart.dart';

class MusicTaggingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //onGenerateRoute: (settings) {},
      home: ImportPopulatePage(),
    );
  }
}

class ImportPopulatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Import Albums")),
      body: BlocProvider(
          create: (_) => ImportPopulateBloc(audioQuery: FlutterAudioQuery())
            ..add(RequestReloadAlbumsEvent()),
          child: SelectedAlbumsList()),
    );
  }
}

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
                context.read<ImportPopulateBloc>().add(event);
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
    // _scrollController.addListener(_onScroll);
    _importBloc = context.read<ImportPopulateBloc>();
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

        //   default:
        //     return const Center(child: CircularProgressIndicator());
        // }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // void _onScroll() {
  //   if (_isBottom) _postBloc.add(PostFetched());
  // }

  // bool get _isBottom {
  //   if (!_scrollController.hasClients) return false;
  //   final maxScroll = _scrollController.position.maxScrollExtent;
  //   final currentScroll = _scrollController.offset;
  //   return currentScroll >= (maxScroll * 0.9);
  // }
}

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

class AndroidAlbumInfo extends Equatable {
  final String title;
  final String artistName;
  final TypedBackendId id;

  AndroidAlbumInfo(this.id, this.title, this.artistName);

  @override
  List<Object?> get props => [title, artistName, id];
}

class ImportPopulateState {
  final IList<AndroidAlbumInfo>? availableAlbums;
  final ISet<TypedBackendId> selectedAlbums;

  ImportPopulateState.initial()
      : availableAlbums = null,
        selectedAlbums = <TypedBackendId>{}.lock;
  ImportPopulateState(this.availableAlbums, this.selectedAlbums);

  ImportPopulateState plus(TypedBackendId item) {
    return ImportPopulateState(availableAlbums, selectedAlbums.add(item));
  }

  ImportPopulateState minus(TypedBackendId item) {
    return ImportPopulateState(availableAlbums, selectedAlbums.remove(item));
  }

  ImportPopulateState withAlbums(IList<AndroidAlbumInfo> newAlbums) {
    return ImportPopulateState(
        newAlbums, selectedAlbums.intersection(newAlbums.map((e) => e.id)));
  }
}

class ImportPopulateBloc
    extends Bloc<ImportPopulateEvent, ImportPopulateState> {
  ImportPopulateBloc({required this.audioQuery})
      : super(ImportPopulateState.initial());

  final FlutterAudioQuery audioQuery;

  @override
  Stream<ImportPopulateState> mapEventToState(
      ImportPopulateEvent event) async* {
    if (event is SelectionEvent) {
      switch (event.type) {
        case SelectionEventType.Add:
          yield state.plus(event.item);
          break;
        case SelectionEventType.Remove:
          yield state.minus(event.item);
          break;
      }
    }
    // else if (event is ReceiveAlbumListEvent) {
    //   yield state.withAlbums(event.albums);
    // }
    else if (event is RequestReloadAlbumsEvent) {
      final albums = await _retrieveAndroidAlbums();
      yield state.withAlbums(albums);
    }
  }

  Future<IList<AndroidAlbumInfo>> _retrieveAndroidAlbums() async {
    final albums = await audioQuery.getAlbums();
    return albums
        .map((e) => AndroidAlbumInfo(
            TypedBackendId.from(StoredResourceType.Album, "android", e.id),
            e.title,
            e.artist))
        .toIList();
  }

  @override
  Stream<Transition<ImportPopulateEvent, ImportPopulateState>> transformEvents(
    Stream<ImportPopulateEvent> events,
    TransitionFunction<ImportPopulateEvent, ImportPopulateState> transitionFn,
  ) {
    return super.transformEvents(
      events, //.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }
}

// Don't need a repository yet
// class AndroidMusicRepository {
//   final _controller = StreamController<AuthenticationStatus>();

//   Stream<AuthenticationStatus> get status async* {
//     await Future<void>.delayed(const Duration(seconds: 1));
//     yield AuthenticationStatus.unauthenticated;
//     yield* _controller.stream;
//   }

//   Future<void> logIn({
//     required String username,
//     required String password,
//   }) async {
//     await Future.delayed(
//       const Duration(milliseconds: 300),
//       () => _controller.add(AuthenticationStatus.authenticated),
//     );
//   }

//   void logOut() {
//     _controller.add(AuthenticationStatus.unauthenticated);
//   }

//   void dispose() => _controller.close();
// }
