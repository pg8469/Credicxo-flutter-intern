import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prakhar_internship_musixmatch/bookmarksBloc.dart';
import 'package:prakhar_internship_musixmatch/bookmarks_list.dart';
import 'package:prakhar_internship_musixmatch/stateManagementBloc.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'constants.dart';
import 'music_details.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'helper.dart';
import 'package:connectivity/connectivity.dart';

class Home extends StatelessWidget {
  String url =
      'https://api.musixmatch.com/ws/1.1/chart.tracks.get?apikey=$API_KEY';

  List musics = [];

  PossibleStates lastState = PossibleStates.noconnection;

  MyConnectivity _connectivity = MyConnectivity.instance;

  final showBookmarkIcon = IconData(58417, fontFamily: 'MaterialIcons');

  Future getMusics(BuildContext context, StateManagementBloc bloc) async {
    bloc.setPossibleState(PossibleStates.loading);
    http.Response response = await http.get(url);
    if (response.statusCode == 200) {
      String body = response.body;
//      print("Success");
      try {
        var jsonData = jsonDecode(body);
        musics = jsonData['message']['body']['track_list'];
        bloc.setPossibleState(PossibleStates.loaded);
//        print(musics);

      } catch (e) {
        print("Exception Occured");
      }
    } else
      print(response.statusCode);
  }

  @override
  void dispose() {
//    print('Home disposed');
    _connectivity.disposeStream();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = Provider.of<StateManagementBloc>(context);
    final bookbloc = Provider.of<BookmarksBloc>(context);
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      //If no Connection
      if (source.keys.toList()[0] == ConnectivityResult.none) {
        if (lastState == PossibleStates.loading) {
          bloc.setPossibleState(PossibleStates.noconnection);
          lastState = PossibleStates.noconnection;
//          print('Connection Lost');
        }
      }
      //If connection Established
      else {
        if (lastState == PossibleStates.noconnection) {
//          print('Connection Established');
          lastState = PossibleStates.loading;
          getMusics(context, bloc);
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white70,
        title: Center(
          child: Text(
            'Trending',
            style: TextStyle(fontSize: 20, color: Colors.black),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(showBookmarkIcon, color: Colors.black),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookMarksList(_connectivity),
                  ));
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('No Internet Connection'),
            SizedBox(
              height: 5,
            ),
            Text('Click on top right to access the offline bookmarks'),
          ],
        ),
      );
    } else
      return ListView.separated(
        separatorBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Divider(
            color: Colors.black,
          ),
        ),
        itemBuilder: (context, index) {
          return RawMaterialButton(
            child: MyListTile(musics[index]['track']),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MusicDetails(
                          musics[index]['track']['track_id'], _connectivity)));
            },
          );
        },
        itemCount: musics.length,
      );
  }
}

class MyListTile extends StatelessWidget {
  var music;
  MyListTile(this.music);
  @override
  Widget build(BuildContext context) {
    return Container(
//      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Icon(
              IconData(57392, fontFamily: 'MaterialIcons'),
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  music['track_name'],
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                  ),
                ),
                Text(music['album_name'])
              ],
            ),
          ),
          SizedBox(
            width: 20,
          ),
          Expanded(flex: 3, child: Text(music['artist_name'])),
        ],
      ),
    );
  }
}
