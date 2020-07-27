import 'dart:async';

class Tracks {
  static Map<String, String> tracks = Map();

  static bool isActive(String TRACK_ID) => tracks.containsKey(TRACK_ID);
}

class BookmarksBloc {
  final StreamController<Tracks> _streamController =
      StreamController<Tracks>.broadcast();

  Stream<Tracks> get tracks_stream => _streamController.stream;

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
    _streamController.add(Tracks());
  }
}
