import 'package:flutter_modular/flutter_modular.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_music_tagging/database/tag_overlay_db.dart';
import 'package:flutter/material.dart';

import 'database/database.dart';
import 'database/folder_overlay_db.dart';
import 'database/unified_library_db.dart';

enum ViewableNodeType { Directory, Artist, Album, Song }

IconData nodeIcon(ViewableNodeType nodeType) {
  switch (nodeType) {
    case ViewableNodeType.Directory:
      return Icons.folder;
    case ViewableNodeType.Artist:
      return Icons.person;
    case ViewableNodeType.Album:
      return Icons.album;
    case ViewableNodeType.Song:
      return Icons.music_note;
  }
}

String nodeUrlString(ViewableNodeType nodeType) {
  switch (nodeType) {
    case ViewableNodeType.Directory:
      return "dir";
    case ViewableNodeType.Artist:
      return "artist";
    case ViewableNodeType.Album:
      return "album";
    case ViewableNodeType.Song:
      return "song";
  }
}

ViewableNodeType fromUrlString(String s, ViewableNodeType defaultType) {
  return {
        "dir": ViewableNodeType.Directory,
        "artist": ViewableNodeType.Artist,
        "album": ViewableNodeType.Album,
        "song": ViewableNodeType.Song,
      }[s] ??
      defaultType;
}

String reduceTagNames(IList<Tag> tags) {
  String? reduced = tags.fold(null, (String? previousValue, tag) {
    if (previousValue == null)
      return tag.name;
    else
      return previousValue + ", " + tag.name;
  });
  if (reduced == null) {
    return "";
  } else {
    return reduced;
  }
}

// TODO extend equatable?
class HierarchyTagSet {
  final String origin;
  final IList<Tag> tags;

  const HierarchyTagSet(this.origin, this.tags);
}

// TODO extend equatable?
class HierarchyNodeInfo {
  final String title;
  final IList<Tag> directTags;
  final IList<HierarchyTagSet> indirectTags;

  const HierarchyNodeInfo(this.title, this.directTags, this.indirectTags);
}

// TODO extend equatable?
class HierarchyChildNodeInfo {
  final int sqlId;
  final ViewableNodeType nodeType;
  final String title;
  final String subtitle;
  final IList<Tag> tags;

  const HierarchyChildNodeInfo(
      this.sqlId, this.nodeType, this.title, this.subtitle, this.tags);
}

class HierarchyViewState {
  final int? sqlId;
  final ViewableNodeType nodeType;
  final HierarchyNodeInfo? nodeInfo;
  final IList<HierarchyChildNodeInfo>? childInfos;

  const HierarchyViewState.initial(this.sqlId, this.nodeType)
      : nodeInfo = null,
        childInfos = null;
  const HierarchyViewState(
      this.sqlId, this.nodeType, this.nodeInfo, this.childInfos);

  HierarchyViewState withNodeInfo(HierarchyNodeInfo nodeInfo) {
    return HierarchyViewState(
        this.sqlId, this.nodeType, nodeInfo, this.childInfos);
  }

  HierarchyViewState withChildInfos(IList<HierarchyChildNodeInfo> childInfos) {
    return HierarchyViewState(
        this.sqlId, this.nodeType, this.nodeInfo, childInfos);
  }
}

abstract class HierarchyViewEvent extends Equatable {}

class HierarchyViewLoadInfo extends HierarchyViewEvent {
  final HierarchyNodeInfo newInfo;

  HierarchyViewLoadInfo(this.newInfo);

  @override
  List<Object?> get props => [newInfo];
}

class HierarchyViewLoadChildInfo extends HierarchyViewEvent {
  final IList<HierarchyChildNodeInfo> newChildInfos;

  HierarchyViewLoadChildInfo(this.newChildInfos);

  @override
  List<Object?> get props => [newChildInfos];
}

Future<HierarchyNodeInfo?> getNodeInfo(
    DatabaseRepository db, int sqlId, ViewableNodeType nodeType) async {
  switch (nodeType) {
    case ViewableNodeType.Directory:
      {
        var dir = await db.dirDao.getById(sqlId);
        if (dir == null) {
          return null;
        }
        var tags = await db.tagDao.getDirDirectTags(sqlId);

        // TODO - indirect tags from parent directories

        return HierarchyNodeInfo(
            dir.name, tags.toIList(), <HierarchyTagSet>[].toIList());
      }
    case ViewableNodeType.Artist:
      {
        var artist = await db.unifiedDataDao.getUnifiedArtist(sqlId);
        if (artist == null) {
          return null;
        }
        var tags = await db.tagDao.getDirDirectTags(sqlId);

        return HierarchyNodeInfo(
            artist.title, tags.toIList(), <HierarchyTagSet>[].toIList());
      }
    case ViewableNodeType.Album:
      {
        var album = await db.unifiedDataDao.getUnifiedAlbum(sqlId);
        if (album == null) {
          return null;
        }
        var tags = await db.tagDao.getDirDirectTags(sqlId);

        // TODO indirect tags from directories

        return HierarchyNodeInfo(
            album.title, tags.toIList(), <HierarchyTagSet>[].toIList());
      }
    case ViewableNodeType.Song:
      {
        var song = await db.unifiedDataDao.getUnifiedSong(sqlId);
        if (song == null) {
          return null;
        }
        var tags = await db.tagDao.getSongDirectTags(sqlId);

        // TODO - indirect tags from albums, artists, directories

        return HierarchyNodeInfo(
            song.title, tags.toIList(), <HierarchyTagSet>[].toIList());
      }
  }
}

Future<IList<HierarchyChildNodeInfo>> getChildInfos(
    DatabaseRepository db, int? parentSqlId, ViewableNodeType nodeType) async {
  debugPrint(nodeType.toString());
  switch (nodeType) {
    case ViewableNodeType.Directory:
      {
        List<DirTreeNode> childDirs;
        if (parentSqlId == null) {
          childDirs = await db.dirDao.dirChildrenOfNull();
        } else {
          childDirs = await db.dirDao.dirChildrenOf(parentSqlId);
        }
        var childDirInfo = childDirs.map((dir) async => HierarchyChildNodeInfo(
            dir.id,
            ViewableNodeType.Directory,
            dir.name,
            "",
            (await db.tagDao.getDirDirectTags(dir.id)).toIList()));

        List<UnifiedAlbum> childAlbums;
        if (parentSqlId == null) {
          childAlbums = await db.dirDao.albumChildrenOfNull();
        } else {
          childAlbums = await db.dirDao.albumChildrenOf(parentSqlId);
        }
        var childAlbumInfo = childAlbums.map((album) async =>
            HierarchyChildNodeInfo(
                album.id,
                ViewableNodeType.Album,
                album.title,
                "",
                (await db.tagDao.getAlbumDirectTags(album.id)).toIList()));

        var allChildInfo = await Future.wait(childDirInfo);
        allChildInfo.addAll(await Future.wait(childAlbumInfo));
        return allChildInfo.toIList();
      }
    case ViewableNodeType.Artist:
      {
        if (parentSqlId == null) return <HierarchyChildNodeInfo>[].toIList();

        var childAlbums =
            await db.unifiedDataDao.getArtistsAlbums([parentSqlId]);
        var childAlbumInfo = childAlbums.map((album) async =>
            HierarchyChildNodeInfo(
                album.id,
                ViewableNodeType.Album,
                album.title,
                "",
                (await db.tagDao.getAlbumDirectTags(album.id)).toIList()));
        return (await Future.wait(childAlbumInfo)).toIList();
      }

    case ViewableNodeType.Album:
      {
        if (parentSqlId == null) return <HierarchyChildNodeInfo>[].toIList();

        var childSongs = await db.unifiedDataDao.getAlbumSongs(parentSqlId);
        var childSongInfos = childSongs.map((song) async =>
            HierarchyChildNodeInfo(song.id, ViewableNodeType.Song, song.title,
                "", (await db.tagDao.getSongDirectTags(song.id)).toIList()));
        return (await Future.wait(childSongInfos)).toIList();
      }

    case ViewableNodeType.Song:
      {
        return <HierarchyChildNodeInfo>[].toIList();
      }
  }
}

class HierarchyViewBloc extends Bloc<HierarchyViewEvent, HierarchyViewState> {
  HierarchyViewBloc(
      DatabaseRepository db, int? sqlId, ViewableNodeType nodeType)
      : super(HierarchyViewState.initial(sqlId, nodeType)) {
    on<HierarchyViewLoadInfo>(
        (event, emit) => state.withNodeInfo(event.newInfo));
    on<HierarchyViewLoadChildInfo>(
        (event, emit) => state.withChildInfos(event.newChildInfos));

    // TODO - schedule DB operations
    // if sqlId != null, look up NodeInfo and push HierarchyViewLoadInfo
    // look up childInfos and push HierarchyViewLoadChildInfo
    if (sqlId != null) {
      getNodeInfo(db, sqlId, nodeType).then((value) {
        if (value != null) {
          this.add(HierarchyViewLoadInfo(value));
        }
      });
    }
    getChildInfos(db, sqlId, nodeType);
  }
}

class HierarchyNodeInfoHeaderWidget extends StatelessWidget {
  final ViewableNodeType nodeType;
  final HierarchyNodeInfo nodeInfo;

  const HierarchyNodeInfoHeaderWidget(
      {required this.nodeType, required this.nodeInfo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var tagSets = [
      Text(reduceTagNames(nodeInfo.directTags)),
    ];
    tagSets.addAll(nodeInfo.indirectTags
        .map((elem) => Text(elem.origin + ": " + reduceTagNames(elem.tags))));
    return Column(
        children: <Widget>[
              Row(
                children: [
                  Icon(nodeIcon(this.nodeType), size: 200),
                  SizedBox(
                    width: 12.0,
                  ),
                  Text(
                    this.nodeInfo.title,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ],
              )
            ] +
            tagSets);
  }
}

class HierarchyChildNodeInfoWidget extends StatelessWidget {
  final HierarchyChildNodeInfo childInfo;
  const HierarchyChildNodeInfoWidget({required this.childInfo, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            child: Icon(nodeIcon(this.childInfo.nodeType), size: 30),
            width: 40,
            height: 40),
        SizedBox(width: 12.0),
        Column(
          children: [
            Text(this.childInfo.title),
            Text(this.childInfo.subtitle),
            Text(reduceTagNames(this.childInfo.tags))
          ],
        )
      ],
    );
  }
}

class LibraryModule extends Module {
  List<Bind> get binds => [];

  @override
  List<ModularRoute> get routes => [
        ChildRoute("/", child: (_, __) => HierarchyNavRoot(), children: [
          ChildRoute("/root/dir",
              child: (context, args) => HierarchyNodePage(
                  nodeType: ViewableNodeType.Directory, sqlId: null)),
          ChildRoute("/root/artist",
              child: (context, args) => HierarchyNodePage(
                  nodeType: ViewableNodeType.Artist, sqlId: null)),
          ChildRoute("/root/song",
              child: (context, args) => HierarchyNodePage(
                  nodeType: ViewableNodeType.Song, sqlId: null)),
          // ChildRoute("/item/:type/:id",
          //     child: (context, args) => HierarchyNodePage(
          //         nodeType: fromUrlString(
          //             args.params['type'], ViewableNodeType.Directory),
          //         sqlId: int.tryParse(args.params['id']))),
        ]),
      ];
}

class HierarchyNodePage extends StatelessWidget {
  final ViewableNodeType nodeType;
  final int? sqlId;

  HierarchyNodePage({required this.nodeType, required this.sqlId, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: true,
      create: (_) => HierarchyViewBloc(
          ReadContext(context).read<DatabaseRepository>(),
          this.sqlId,
          this.nodeType),
      child: BlocBuilder<HierarchyViewBloc, HierarchyViewState>(
          builder: (context, state) {
        var children = <Widget>[];

        var nodeInfo = state.nodeInfo;
        if (nodeInfo != null) {
          children.add(HierarchyNodeInfoHeaderWidget(
              nodeType: state.nodeType, nodeInfo: nodeInfo));
        }
        var childInfos = state.childInfos;
        if (childInfos != null) {
          children.addAll(childInfos.map(
              (element) => HierarchyChildNodeInfoWidget(childInfo: element)));
        }
        return Column(
          children: children,
        );
      }),
    );
  }
}

class HierarchyNavRoot extends StatefulWidget {
  @override
  HierarchyNavRootState createState() => HierarchyNavRootState();
}

class HierarchyNavRootState extends State<HierarchyNavRoot> {
  int currentIndex = 0;
  AppDatabase? db;

  @override
  void initState() {
    super.initState();
    currentIndex = 0;
    db = null;
    AppDatabase.getConnection().then((newDb) => setState(() {
          db = newDb;
        }));
  }

  @override
  Widget build(BuildContext context) {
    var db = this.db;
    if (db == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Browse Library")),
        body: CircularProgressIndicator(value: null),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Directory)),
                label: "Directory"),
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Artist)), label: "Artist"),
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Song)), label: "Song"),
          ],
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text("Browse Library")),
        body: RepositoryProvider<DatabaseRepository>(
          create: (context) => db,
          child: RouterOutlet(),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (id) {
            setState(() => {currentIndex = id});

            // Modular.to.popUntil((route) {
            //   debugPrint(route.settings.name);
            //   return route.settings.name == "/";
            // });

            // debugPrint(Modular.to.navigateHistory
            //     .map((e) => e.name)
            //     .toList()
            //     .toString());

            switch (id) {
              case 0:
                // Modular.to
                //     .pushNamedAndRemoveUntil("dir", ModalRoute.withName("/"));
                Modular.to.pushReplacementNamed("dir");
                break;
              case 1:
                // Modular.to.pushNamedAndRemoveUntil(
                //     "artist", ModalRoute.withName("/"));
                Modular.to.pushReplacementNamed("artist");
                break;
              case 2:
                // Modular.to
                //     .pushNamedAndRemoveUntil("song", ModalRoute.withName("/"));
                Modular.to.pushReplacementNamed("song");
                break;
              default:
                // Modular.to
                //     .pushNamedAndRemoveUntil("dir", ModalRoute.withName("/"));
                Modular.to.pushReplacementNamed("dir");
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Directory)),
                label: "Directory"),
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Artist)), label: "Artist"),
            BottomNavigationBarItem(
                icon: Icon(nodeIcon(ViewableNodeType.Song)), label: "Song"),
          ],
        ),
      );
    }
  }
}
