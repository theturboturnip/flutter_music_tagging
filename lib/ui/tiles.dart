import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_music_tagging/database/models.dart';

abstract class TitleSubtitleTile extends StatelessWidget {
  final String title;
  final String subtitle;

  const TitleSubtitleTile({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(color: Colors.lightBlueAccent),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(subtitle)
          ],
        ),
      ),
    );
  }
}

class SongTile extends TitleSubtitleTile {
  SongTile(Song song, Artist artist)
      : super(title: song.title, subtitle: artist.name);
}
