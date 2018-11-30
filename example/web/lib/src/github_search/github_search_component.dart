import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:angular_dart_app/src/github_search/search_results_component.dart';
import 'package:common/common.dart';
import 'package:ez_listenable_angular/ez_listenable_angular.dart';

@Component(
  selector: 'github-search',
  templateUrl: 'github_search_component.html',
  directives: [
    materialInputDirectives,
    coreDirectives,
    SearchResultsComponent,
  ],
  pipes: [ListenPipe],
)
class GithubSearchComponent {
  final SearchPresenter presenter = SearchPresenter();
}
