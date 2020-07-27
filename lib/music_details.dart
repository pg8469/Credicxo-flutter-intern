import 'package:flutter/material.dart';
import 'package:prakhar_internship_musixmatch/bookmarksBloc.dart';
import 'package:prakhar_internship_musixmatch/stateManagementBloc.dart';
import 'package:provider/provider.dart';
import 'constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:connectivity/connectivity.dart';
import 'helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MusicDetails extends StatelessWidget {
  final TRACK_ID;
  MyConnectivity _connectivity;

  MusicDetails(this.TRACK_ID, this._connectivity);
  var track_details;
  var lyrics;

  final BOOKMARK_INACTIVE = IconData(59495, fontFamily: 'MaterialIcons');
  final BOOKMARK_ACTIVE = IconData(59494, fontFamily: 'MaterialIcons');

  PossibleStates lastState = PossibleStates.noconnection;

  Future getDetails(
      dynamic TRACK_ID, BuildContext context, StateManagementBloc bloc) async {
    bloc.setPossibleState(PossibleStates.loading);
    String url1 =
        'https://api.musixmatch.com/ws/1.1/track.get?track_id=$TRACK_ID&apikey=$API_KEY';
    String url2 =
        'https://api.musixmatch.com/ws/1.1/track.lyrics.get?track_id=$TRACK_ID&apikey=$API_KEY';

    http.Response response1 = await http.get(url1);
    http.Response response2 = await http.get(url2);

    if (response1.statusCode == 200 && response2.statusCode == 200) {
      String body1 = response1.body;
      String body2 = response2.body;

      try {
        var temp1 = jsonDecode(body1);
        track_details = temp1['message']['body']['track'];
//        print(track_details);
        var temp2 = jsonDecode(body2);
        lyrics = temp2['message']['body']['lyrics'];
//        print(lyrics);
      } catch (e) {
        print('Some Error Occured');
      }
    } else {
      print('Some api error occured');
    }
    bloc.setPossibleState(PossibleStates.loaded);
  }

  @override
  void dispose() {
//    print('Music Details Disposed');
    _connectivity.disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<StateManagementBloc>(context);
    final bookbloc = Provider.of<BookmarksBloc>(context);
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      if (source.keys.toList()[0] == ConnectivityResult.none) {
        if (lastState == PossibleStates.loading) {
          bloc.setPossibleState(PossibleStates.noconnection);
          lastState = PossibleStates.noconnection;
//          print('Connection Lost');
        }
      } else {
        if (lastState == PossibleStates.noconnection) {
//          print('Connection Established');
          lastState = PossibleStates.loading;
          getDetails(TRACK_ID, context, bloc);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        backgroundColor: Colors.white70,
        title: Text(
          'Track Details',
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        actions: <Widget>[
          StreamBuilder<Tracks>(
              stream: bookbloc.tracks_stream,
              builder: (context, snapshot) {
//                print('Built');
                return IconButton(
                  icon: Icon(
                    (Tracks.isActive(TRACK_ID.toString()))
                        ? BOOKMARK_ACTIVE
                        : BOOKMARK_INACTIVE,
                    color: Colors.black,
                  ),
                  onPressed: () {
//                    print("Pressed");
                    bookbloc.flipValue(TRACK_ID.toString(),
                        track_details['track_name'].toString());
                  },
                );
              })
        ],
      ),
      body: StreamBuilder<PossibleStates>(
        stream: bloc.possible_states_stream,
        initialData: PossibleStates.noconnection,
        builder: (context, snapshot) {
          return _buildContent(context, snapshot.data);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PossibleStates state) {
    if (state == PossibleStates.loading)
      return Center(
        child: Loading(
            indicator: BallPulseIndicator(), size: 100.0, color: Colors.blue),
      );
    else if (state == PossibleStates.noconnection) {
      return Center(
        child: Text('No Internet Connection'),
      );
    } else
      return ListView(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        children: <Widget>[
          MyCol(
            head: 'Name',
            body: track_details['track_name'],
//                  body: 'Body Here',
          ),
          MyCol(
            head: 'Artist',
            body: track_details['artist_name'],
//                  body: 'ARtist Name',
          ),
          MyCol(
            head: 'Album Name',
            body: track_details['album_name'],
          ),
          MyCol(
            head: 'Explicit',
            body: (track_details['explicit'] == 0) ? 'False' : 'True',
          ),
          MyCol(
            head: 'Rating',
            body: track_details['track_rating'].toString(),
          ),
          MyCol(
            head: 'Lyrics',
            body: lyrics['lyrics_body'],
          ),
        ],
      );
  }
}

class MyCol extends StatelessWidget {
  String head, body;

  MyCol({this.body, this.head});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            head,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            body,
            style: TextStyle(fontSize: 15),
          )
        ],
      ),
    );
  }
}
