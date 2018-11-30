import 'package:ez_listenable_flutter/ez_listenable_flutter.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp(
    presenter: CounterPresenter(),
  ));
}

class MyApp extends StatelessWidget {
  final CounterPresenter presenter;

  const MyApp({Key key, @required this.presenter}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // At the top level of our app, we'll, create a Provide Widget. This
    // will provide the CounterPresenter to all children in the app that request it
    // using a EzConsumer.
    return EzProvider<CounterPresenter>(
      listenable: presenter,
      child: MaterialApp(
        title: 'EzListenable Demo',
        home: CounterHome('EzListenable Demo'),
      ),
    );
  }
}

// Start by creating a class that has a counter and a method to increment it.
//
// Note: It must extend from EzListenable.
class CounterPresenter extends EzNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    // First, increment the counter
    _counter++;

    // Then notify all the listeners.
    notifyListeners();
  }
}

class CounterHome extends StatelessWidget {
  final String title;

  CounterHome(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('You have pushed the button this many times:'),
            // Create an EzConsumer Widget. This widget will get the
            // CounterPresenter from the nearest parent
            // Provide<CounterPresenter>. It will hand that CounterPresenter to
            // our builder method, and rebuild any time the CounterPresenter
            // changes (i.e. after we `notifyListeners` in the EzListenable).
            EzConsumer<CounterPresenter>(
              builder: (context, presenter) {
                return Text(
                  presenter.counter.toString(),
                  style: Theme.of(context).textTheme.display1,
                );
              },
            ),
          ],
        ),
      ),
      // Use the EzConsumer again in order to use the increment method from the
      // CounterPresenter
      floatingActionButton: EzConsumer<CounterPresenter>(
        builder: (context, presenter) {
          return FloatingActionButton(
            onPressed: presenter.increment,
            tooltip: 'Increment',
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
