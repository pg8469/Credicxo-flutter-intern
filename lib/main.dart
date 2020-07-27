import 'package:flutter/material.dart';
import 'package:prakhar_internship_musixmatch/stateManagementBloc.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider<StateManagementBloc>(
      create: (context) => StateManagementBloc(),
      dispose: (context, bloc) => bloc.dispose(),
      child: MaterialApp(
        home: Home(),
      ),
    );
  }
}
