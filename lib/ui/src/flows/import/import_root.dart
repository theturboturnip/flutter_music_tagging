import 'package:equatable/equatable.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';

import 'common.dart';
import 'import_populate.dart';

class ImportRootState extends Equatable {
  final int currentStep;
  final ISet<AndroidAlbumInfo> selectedRoots;

  ImportRootState.initial()
      : currentStep = 0,
        selectedRoots = ISet<AndroidAlbumInfo>();
  ImportRootState({required this.currentStep, required this.selectedRoots});

  ImportRootState withRoots(ISet<AndroidAlbumInfo> newRoots) {
    return ImportRootState(currentStep: 1, selectedRoots: newRoots);
  }

  @override
  List<Object?> get props => [selectedRoots];
}

abstract class ImportRootEvent extends Equatable {}

class ImportRootSetRoots extends ImportRootEvent {
  final ISet<AndroidAlbumInfo> newRoots;

  ImportRootSetRoots(this.newRoots);

  @override
  List<Object?> get props => throw UnimplementedError();
}

class ImportRootBloc extends Bloc<ImportRootEvent, ImportRootState> {
  ImportRootBloc() : super(ImportRootState.initial());

  @override
  Stream<ImportRootState> mapEventToState(ImportRootEvent event) async* {
    if (event is ImportRootSetRoots) {
      yield state.withRoots(event.newRoots);
    }
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
            return Stepper(
              currentStep: state.currentStep,
              steps: <Step>[
                Step(
                  title: const Text('Select Root Albums'),
                  content: Container(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      children: [
                        ElevatedButton(
                            child: const Text('Open Android Media'),
                            onPressed: () =>
                                Modular.to.pushNamed("select_roots")),
                        Text('Selected ${state.selectedRoots.length} albums'),
                      ],
                    ),
                  ),
                ),
                const Step(
                  title: Text('Step 2 title'),
                  content: Text('Content for Step 2'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
