import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> hasAllPermissions() async {
  return await Permission.storage.isGranted;
}

class PermissionState extends Equatable {
  final bool hasStorage;

  PermissionState({required this.hasStorage});
  PermissionState.initial() : this.hasStorage = false;

  PermissionState withStorage() {
    return PermissionState(hasStorage: true);
  }

  bool hasAllPermissions() {
    return this.hasStorage;
  }

  @override
  List<Object?> get props => [hasStorage];
}

abstract class PermissionEvent extends Equatable {}

class PermissionGetStorage extends PermissionEvent {
  PermissionGetStorage();

  @override
  List<Object?> get props => [];
}

class PermissionBloc extends Bloc<PermissionEvent, PermissionState> {
  PermissionBloc() : super(PermissionState.initial()) {
    on<PermissionGetStorage>((event, emit) => emit(state.withStorage()));
  }
}

class PermissionModule extends Module {
  List<Bind> get binds => [
        // Note - "Singleton" here means "created when the module is entered,
        // destroyed when the module is exited,
        // always the same value for any children that access it".
        // not "created once, never destroyed ever".
        Bind.singleton((i) => PermissionBloc()),
      ];

  @override
  List<ModularRoute> get routes => [
        ChildRoute("/", child: (_, __) => PermissionsPage()),
      ];
}

class PermissionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) => Modular.get<PermissionBloc>(),
        child: BlocBuilder<PermissionBloc, PermissionState>(
            builder: (context, state) {
          List<Widget> children = [
            const Text("Permissions"),
            const Text(
                "This app requires a few permissions to function. Grant them to continue. Press the button to grant each permission."),
          ];

          if (state.hasStorage) {
            children.add(ElevatedButton(
                onPressed: null, child: const Text("Storage Granted")));
          } else {
            children.add(ElevatedButton(
                onPressed: () async {
                  var status = await Permission.storage.request();
                  if (status.isGranted) {
                    context.read<PermissionBloc>().add(PermissionGetStorage());
                  }
                },
                child: const Text("Grant Storage")));
          }

          if (state.hasAllPermissions()) {
            Modular.to.navigate("/home");
          }

          return Column(
            children: children,
          );
        }));
  }
}
