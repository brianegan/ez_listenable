library ez_listenable_test;

import 'dart:async';

import 'package:ez_listenable/ez_listenable.dart';
import 'package:test/test.dart';

Matcher notifies(dynamic matcher) => _ListenableMatcher(<dynamic>[matcher]);

Matcher notifiesInOrder(List<dynamic> matchers) => _ListenableMatcher(matchers);

Matcher notifiesThrough(Matcher matcher) => _NotifiesThroughMatcher(matcher);

Matcher value(dynamic matcher) {
  return predicate<EzValueListenable>(
    (listenable) {
      if (matcher is Matcher) {
        return matcher.matches(listenable.value, <dynamic, dynamic>{});
      } else {
        return listenable.value == matcher;
      }
    },
    'Value was not $matcher',
  );
}

class _ListenableMatcher extends Matcher {
  final List<dynamic> matchers;

  const _ListenableMatcher(this.matchers);

  @override
  Description describe(Description description) {
    return description;
  }

  @override
  bool matches(dynamic listenable, Map matchState) {
    if (listenable is EzListenable) {
      int count = 0;

      listenable.addListener(expectAsync0(
        () {
          expect(listenable, matchers[count]);
          count++;
        },
        count: matchers.length,
      ));
    } else {
      throw new ArgumentError(
          'Must provide a listenable to the EzListenableMatcher');
    }

    return true;
  }
}

class _NotifiesThroughMatcher extends Matcher {
  final Matcher matchers;

  const _NotifiesThroughMatcher(this.matchers);

  @override
  Description describe(Description description) {
    return description;
  }

  @override
  bool matches(dynamic listenable, Map matchState) {
    if (listenable is EzListenable) {
      final completer = Completer<Null>();

      listenable.addListener(() {
        if (matchers.matches(listenable, <dynamic, dynamic>{})) {
          completer.complete(null);
        }
      });

      expect(completer.future, completes);
    } else {
      throw new ArgumentError(
          'Must provide a listenable to the EzListenableMatcher');
    }

    return true;
  }
}
