import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

// TODO - auto-equatable
class BackendId extends Equatable {
  // The backend you're mapping from (e.g. Android, Spotify)
  final String backendType;
  // The ID of the item in the backend's local namespace
  // e.g. for spotify this could be a Spotify URI
  final String backendId;

  BackendId(this.backendType, this.backendId);

  @override
  List<Object?> get props => [backendType, backendId];
}

enum StoredResourceType {
  Song,
  Album,
  Artist,
}

// TODO - auto-equatable
class TypedBackendId extends Equatable {
  final BackendId id;
  final StoredResourceType type;

  TypedBackendId(this.id, this.type);

  TypedBackendId.from(
      StoredResourceType type, String backendType, Object backendId)
      : this.id = BackendId(backendType, backendId.toString()),
        this.type = type;

  @override
  List<Object?> get props => [id, type];
}

class BackendIdConverter extends TypeConverter<BackendId, String> {
  static const String SEP = "\$";
  @override
  BackendId decode(String databaseValue) {
    var values = databaseValue.split(SEP);
    assert(values.length == 2);
    return BackendId(values[0], values[1]);
  }

  @override
  String encode(BackendId value) {
    assert(!value.backendId.contains(SEP));
    assert(!value.backendType.contains(SEP));

    return "${value.backendType}${SEP}${value.backendId}";
  }
}
