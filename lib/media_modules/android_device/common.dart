import 'package:equatable/equatable.dart';
import 'package:flutter_music_tagging/database/backend_id.dart';

class AndroidAlbumInfo extends Equatable {
  final String title;
  final String artistName;
  final TypedBackendId id;

  AndroidAlbumInfo(this.id, this.title, this.artistName);

  @override
  List<Object?> get props => [title, artistName, id];
}
