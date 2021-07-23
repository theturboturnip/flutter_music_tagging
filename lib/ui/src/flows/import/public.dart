import 'package:flutter/material.dart';
import 'package:flutter_audio_query/flutter_audio_query.dart' as AndroidAudio;
import 'package:flutter_bloc/flutter_bloc.dart';

import 'import_populate.dart';

class ImportPopulatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ImportPopulateBloc(audioQuery: AndroidAudio.FlutterAudioQuery())
            ..add(RequestReloadAlbumsEvent()),
      child: BlocBuilder<ImportPopulateBloc, ImportPopulateState>(
        builder: (context, state) => Scaffold(
          appBar: AppBar(
            title: const Text("Import Albums"),
            actions: [
              PopupMenuButton<AlbumSortType>(
                icon: Icon(Icons.sort_sharp),
                onSelected: (sortType) => context
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
                      context
                          .read<ImportPopulateBloc>()
                          .add(SelectionGroupEvent.add());
                      break;
                    case false:
                      // orignal was null => partially full => select all
                      context
                          .read<ImportPopulateBloc>()
                          .add(SelectionGroupEvent.add());
                      break;
                    case null:
                      // original was true => full => deselect all
                      context
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
    );
  }
}
