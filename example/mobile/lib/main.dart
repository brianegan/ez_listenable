import 'package:common/common.dart';
import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/search_screen.dart';

void main() {
  runApp(SearchApp());
}

class SearchApp extends StatefulWidget {
  SearchApp({Key key}) : super(key: key);

  @override
  _ScopedModelAppState createState() => _ScopedModelAppState();
}

class _ScopedModelAppState extends State<SearchApp> {
  // Instantiate the Presenter as a field in the state class. We do not want to
  // rebuild the presenter every time the build method is run.
  final presenter = SearchPresenter();

  @override
  void dispose() {
    presenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RxDart Github Search',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.grey,
      ),
      home: EzProvider<SearchPresenter>(
        listenable: presenter,
        child: SearchScreen(),
      ),
    );
  }
}
