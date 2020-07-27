import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:prakhar_internship_musixmatch/music_details.dart';
import 'package:provider/provider.dart';

import 'bookmarksBloc.dart';

class BookMarksList extends StatelessWidget {
  final _connectivity;
  BookMarksList(this._connectivity);
  @override
  Widget build(BuildContext context) {
    final bookbloc = Provider.of<BookmarksBloc>(context);
    final allTracks = bookbloc.getTracks();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        title: Center(
          child: Text(
            'Bookmarked Tracks',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
      ),
      body: StreamBuilder<Tracks>(
          stream: bookbloc.tracks_stream,
          builder: (context, snapshot) {
            return ListView.separated(
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Divider(
                  color: Colors.black,
                ),
              ),
              itemCount: allTracks.length,
              itemBuilder: (context, index) {
                String key = allTracks.keys.elementAt(index);
                return RawMaterialButton(
                  padding: EdgeInsets.zero,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Text(
                      allTracks[key],
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                MusicDetails(key, _connectivity)));
                  },
                );
              },
            );
          }),
    );
  }
}
