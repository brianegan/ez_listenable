import 'package:angular/angular.dart';
import 'package:angular_components/angular_components.dart';
import 'package:common/common.dart';

@Component(
  selector: 'search-results',
  templateUrl: 'search_results_component.html',
  directives: [
    materialInputDirectives,
    coreDirectives,
    MaterialSpinnerComponent,
    MaterialIconComponent,
  ],
)
class SearchResultsComponent {
  @Input()
  SearchState state;

  bool get isEmpty => state is SearchEmpty;
  bool get isPopulated => state is SearchPopulated;
  bool get isError => state is SearchError;
  bool get isNoTerm => state is SearchNoTerm;
  bool get isLoading => state is SearchLoading;

  SearchResults get result => (state as SearchPopulated).result;
}
