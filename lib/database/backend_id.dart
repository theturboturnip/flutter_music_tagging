import 'package:floor/floor.dart';

class BackendId {
  final String backendType;
  final String backendId;

  BackendId(this.backendType, this.backendId);
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
