import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

class Song {
  final String path;
  final String name;
  String? title;
  String? artist;
  Uint8List? albumArt;

  Song({
    required this.path,
    required this.name,
    this.title,
    this.artist,
    this.albumArt,
  });

  factory Song.fromPlatformFile(PlatformFile file) {
    return Song(
      path: file.path!,
      name: file.name,
    );
  }
}
