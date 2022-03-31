import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'common.dart';
import 'import_populate.dart';

class ImportRootState extends Equatable {
  final ISet<AndroidAlbumInfo> selectedRoots;

  ImportRootState.initial() : selectedRoots = ISet<AndroidAlbumInfo>();
  ImportRootState({required this.selectedRoots});

  ImportRootState withRoots(ISet<AndroidAlbumInfo> newRoots) {
    return ImportRootState(selectedRoots: newRoots);
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
    return Scaffold(
      appBar: AppBar(title: const Text("Import Music")),
      body: BlocProvider(
        create: (_) => Modular.get<ImportRootBloc>(),
        child: BlocBuilder<ImportRootBloc, ImportRootState>(
          builder: (context, state) {
            return ListView.builder(
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
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Modular.to.pushNamed("select_roots"),
        child: const Icon(Icons.add),
        tooltip: 'Create',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          children: [
            // TextButton(
            //   onPressed: () {},
            //   child: const Text("Merge Dupes"),
            // ),
            // const Spacer(),
            TextButton(
              onPressed: () => Modular.to.pushNamed("importing"),
              child: const Text("Confirm"),
            )
          ],
        ),
        shape: const CircularNotchedRectangle(),
      ),
    );
  }
}
