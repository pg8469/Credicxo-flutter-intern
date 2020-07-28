import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getApplicationDocumentsDirectory();

  return directory.path;
}

Future<File> get _localFile async {
  final path = await _localPath;
  print(path);
  return File('$path/tracks.txt');
}

class Tracks {
  static Map<String, String> tracks = null;

  static Future<void> readTracks() async {
    if (tracks != null) return;
    try {
      final file = await _localFile;

      // Read the file.
      String contents = await file.readAsString();
      tracks = jsonDecode(contents).cast<String, String>();
//      print('Read Sucessfully');
    } catch (e) {
      // If encountering an error, return 0.
      print(e);
      tracks = Map<String, String>();
//      print("Error in reading file");
    }
  }

  static Future<void> writeTracks() async {
    final file = await _localFile;

    // Write the file.
    String strdata = json.encode(tracks);
    file.writeAsString(strdata);
//    print("written successfukky");
  }

  static bool isActive(String TRACK_ID) => tracks.containsKey(TRACK_ID);
}

class BookmarksBloc {
  final StreamController<Tracks> _streamController =
      StreamController<Tracks>.broadcast();

  Stream<Tracks> get tracks_stream => _streamController.stream;

  BookmarksBloc() {
    Tracks.readTracks();
  }

  void dispose() {
//    print('Disposed');
    _streamController.close();
  }

  bool flipValue(String TRACK_ID, String trackName) {
    if (Tracks.tracks.containsKey(TRACK_ID)) {
      Tracks.tracks.remove(TRACK_ID);
      speak();
      return false;
    } else {
      Tracks.tracks[TRACK_ID] = trackName;
      speak();
      return true;
    }
  }

  Map<String, String> getTracks() {
    return Tracks.tracks;
  }

  void speak() {
    Tracks.writeTracks();
    _streamController.add(Tracks());
  }
}
