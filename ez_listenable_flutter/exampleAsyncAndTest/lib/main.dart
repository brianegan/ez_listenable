import 'dart:async';

import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(new MyApp(notifier: CounterNotifier()));
}

class MyApp extends StatelessWidget {
  final AbstractNotifier notifier;

  const MyApp({Key key, @required this.notifier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // At the top level of our app, we'll, create a Provide Widget. This
    // will provide the CounterListenable to all children in the app that request it
    // using a EzConsumer.
    return new EzProvider<AbstractNotifier>(
      listenable: notifier,
      child: new MaterialApp(
        title: 'Flutter Demo',
        theme: new ThemeData(
          primarySwatch: Colors.green,
        ),
        home: new CounterHome('EzListenable Demo'),
      ),
    );
  }
}

// Start by creating a class that has a counter and a method to increment it.
//
// Note: It must extend from EzNotifier.
abstract class AbstractNotifier extends EzNotifier {
  int get counter;
  void increment();
}

class CounterNotifier extends AbstractNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() async {
    // First, increment the counter
    _counter++;

    // needed for simulate an async action like an http request ...
    await Future.delayed(const Duration(seconds: 1));

    // Then notify all the listeners.
    notifyListeners();
  }
}

class TestNotifier extends AbstractNotifier {
  int _counter = 111;

  int get counter => _counter;

  void increment() {
    _counter += 2;
    notifyListeners();
  }
}

class CounterHome extends StatelessWidget {
  final String title;

  CounterHome(this.title);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Text(
              'You have pushed the button this many times:',
            ),
            // Create a EzConsumer. This widget will get the
            // CounterListenable from the nearest parent Provide<CounterListenable>.
            // It will hand that CounterListenable to our builder method, and
            // rebuild any time the CounterListenable changes (i.e. after we
            // `notifyListeners` in the EzNotifier).
            new EzConsumer<AbstractNotifier>(
              builder: (context, notifier) {
                return new Text(
                  notifier.counter.toString(),
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      // Use the EzConsumer again in order to use the increment
      // method from the CounterListenable
      floatingActionButton: new EzConsumer<AbstractNotifier>(
        builder: (context, listenable) => new FloatingActionButton(
              onPressed: listenable.increment,
              tooltip: 'Increment',
              child: new Icon(Icons.add),
            ),
      ),
    );
  }
}
