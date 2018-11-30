import 'package:common/common.dart';

SearchResults get searchResults {
  return SearchResults(
    items: [
      Repo(
        fullName: 'Hi',
        htmlUrl: 'there',
        owner: Owner(login: 'Test', avatarUrl: 'user'),
      )
    ],
  );
}
