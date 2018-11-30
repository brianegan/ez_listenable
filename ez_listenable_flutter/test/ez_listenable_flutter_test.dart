import 'package:ez_listenable/ez_listenable.dart';
import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Listenables can be handed down from parent to child',
      (WidgetTester tester) async {
    final initialValue = 0;
    final listenable = TestNotifier(initialValue);
    final widget = TestWidget(listenable);

    await tester.pumpWidget(widget);

    expect(find.text('$initialValue'), findsOneWidget);
  });

  testWidgets('Widgets update when the listenable notifies the listeners',
      (WidgetTester tester) async {
    final initialValue = 0;
    final listenable = TestNotifier(initialValue);
    final widget = TestWidget(listenable);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the listenable, which should notify the children to rebuild
    listenable.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(listenable.listenerCount, 1);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets(
      'Widgets do not update when the listenable notifies the listeners if they choose not to',
      (WidgetTester tester) async {
    final initialValue = 0;
    final listenable = TestNotifier(initialValue);
    final widget = TestWidget.noRebuild(listenable);

    // Starts out at the initial value
    await tester.pumpWidget(widget);

    // Increment the listenable, which shouldn't trigger a rebuild
    listenable.increment();

    // Rebuild the widget
    await tester.pumpWidget(widget);

    expect(listenable.listenerCount, 1);
    expect(find.text('$initialValue'), findsOneWidget);
  });

  testWidgets(
      "listenable notification doesn't build widgets between listenable and descendant",
      (WidgetTester tester) async {
    var testModel = TestNotifier();

    // use List to pass the counter by reference
    List<int> buildCounter = [0];

    // build widget tree with items between scope and descendant
    var tree = MaterialApp(
      home: EzProvider<TestNotifier>(
        listenable: testModel,
        child: Container(
          child: BuildCountContainer(
            buildCounter: buildCounter,
            child: EzConsumer<TestNotifier>(
              builder: (context, listenable) => Text("${listenable.counter}"),
            ),
          ),
        ),
      ),
    );

    // initial drawing shows the counter form the listenable
    await tester.pumpWidget(tree);
    expect(find.text('0'), findsOneWidget);
    // the render method of the widgets between scope and descendant is called once
    expect(buildCounter[0], 1);

    // Increment the listenable, which should rebuild only the listening descendant subtree
    testModel.increment();
    await tester.pump();
    await tester.pump();

    // the text changes correctly
    expect(find.text("1"), findsOneWidget);

    // the render method of the widgets between scope and descendant doesn't get called!
    expect(buildCounter[0], 1);
  });

  testWidgets('Throws an error if type info not provided',
      (WidgetTester tester) async {
    final initialValue = 0;
    final listenable = TestNotifier(initialValue);
    final widget = ErrorWidget(listenable);

    await tester.pumpWidget(widget);

    expect(tester.takeException(), isInstanceOf<EzProviderError>());
  });
}

class TestNotifier extends EzNotifier {
  int _counter;
  int listenerCount = 0;

  TestNotifier([int initialValue = 0]) {
    _counter = initialValue;
  }

  @override
  void addListener(Function listener) {
    listenerCount++;
    super.addListener(listener);
  }

  @override
  void removeListener(Function listener) {
    listenerCount--;
    super.removeListener(listener);
  }

  int get counter => _counter;

  void increment([int value]) {
    _counter++;
    notifyListeners();
  }
}

class TestWidget extends StatelessWidget {
  final TestNotifier listenable;
  final bool rebuildOnChange;

  TestWidget(this.listenable, [this.rebuildOnChange = true]);

  factory TestWidget.noRebuild(TestNotifier listenable) =>
      TestWidget(listenable, false);

  @override
  Widget build(BuildContext context) {
    return EzProvider<TestNotifier>(
      listenable: listenable,
      // Extra nesting to ensure the listenable is sent down the tree.
      child: Container(
        child: Container(
          child: EzConsumer<TestNotifier>(
            rebuildOnChange: rebuildOnChange,
            builder: (context, listenable) {
              return Text(
                listenable.counter.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );
  }
}

class ErrorWidget extends StatelessWidget {
  final TestNotifier listenable;
  final bool rebuildOnChange;

  ErrorWidget(this.listenable, [this.rebuildOnChange = true]);

  @override
  Widget build(BuildContext context) {
    return EzProvider<TestNotifier>(
      listenable: listenable,
      // Extra nesting to ensure the listenable is sent down the tree.
      child: Container(
        child: Container(
          child: EzConsumer(
            rebuildOnChange: rebuildOnChange,
            builder: (context, listenable) {
              return Text(
                listenable.counter.toString(),
                textDirection: TextDirection.ltr,
              );
            },
          ),
        ),
      ),
    );
  }
}

class BuildCountContainer extends Container {
  final List<int> buildCounter;

  @override
  Widget build(BuildContext context) {
    buildCounter[0]++;
    return super.build(context);
  }

  BuildCountContainer({Widget child, this.buildCounter}) : super(child: child);
}
