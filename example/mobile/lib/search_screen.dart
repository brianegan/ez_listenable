import 'package:common/common.dart';
import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';
import 'package:mobile/search_empty_view.dart';
import 'package:mobile/search_error_view.dart';
import 'package:mobile/search_intro_view.dart';
import 'package:mobile/search_loading_view.dart';
import 'package:mobile/search_result_view.dart';

class SearchScreen extends StatefulWidget {
  SearchScreen({Key key}) : super(key: key);

  @override
  SearchScreenState createState() {
    return SearchScreenState();
  }
}

class SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    final presenter = EzProvider.of<SearchPresenter>(context);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Flex(
            direction: Axis.vertical,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 0),
                child: TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search Github...',
                  ),
                  style: TextStyle(
                    fontSize: 36,
                    fontFamily: "Hind",
                    decoration: TextDecoration.none,
                  ),
                  onChanged: presenter.onTermChange,
                ),
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: Duration(milliseconds: 350),
                  child: _stateToVisible(presenter.state),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  static Widget _stateToVisible(SearchState state) {
    if (state is SearchEmpty) {
      return SearchEmptyView();
    } else if (state is SearchLoading) {
      return SearchLoadingView();
    } else if (state is SearchError) {
      return SearchErrorView();
    } else if (state is SearchPopulated) {
      return SearchResultView(
        key: ValueKey(state.result.hashCode),
        repos: state.result.items,
      );
    } else {
      return SearchIntroView();
    }
  }
}
