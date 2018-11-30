# ez_listenable

[![Build Status](https://travis-ci.org/brianegan/ez_listenable.svg?branch=master)](https://travis-ci.org/brianegan/ez_listenable)  [![codecov](https://codecov.io/gh/brianegan/ez_listenable/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/ez_listenable)

A set of utilities that allow you to easily pass a data Model from a parent
Widget down to it's descendants. In addition, it also re-renders all of the
children that use the [EzListenable] when it iis updated.

This implementation is based on the the 
[Model classes](https://github.com/fuchsia-mirror/topaz/blob/c2be8939b45ad0494f0130dbea6460e77abbe62b/public/dart/widgets/lib/src/model/model.dart)
from Fuchsia's core Widgets, presented as a standalone Flutter library for
independent use so we can evaluate this architecture pattern more easily as a
community.

## Examples

  * [Counter App](https://github.com/brianegan/ez_listenable/tree/master/example) - Introduction to the tools provided by EzListenable. 
  * [Todo App](https://github.com/brianegan/flutter_architecture_samples/tree/master/example/ez_listenable) - Shows how to write a Todo app with persistence and tests. 

## Usage

Let's demo the basic usage with the all-time favorite: A counter example!

```dart
// Start by creating a class that holds some view the app's state. In
// our example, we'll have a simple counter that starts at 0 can be 
// incremented.
//
// Note: It must extend from EzNotifier.  
class CounterListenable extends EzNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    // First, increment the counter
    _counter++;
    
    // Then notify all the listeners.
    notifyListeners();
  }
}

// Create our App, which will provide the `CounterListenable` to 
// all children that require it! 
class CounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // First, create a `Provide` widget. This will provide 
    // the `listenable` to the children that request it. 
    return new EzProvider<CounterListenable>(
      listenable: new CounterListenable(),
      child: new Column(children: [
        // Create a EzConsumer Widget. This widget will get the
        // CounterListenable from the nearest Provide<CounterListenable>. 
        // It will hand that model to our builder method, and rebuild 
        // any time the CounterListenable changes (i.e. after we 
        // `notifyListeners` in the Model). 
        new EzConsumer<CounterListenable>(
          builder: (context, model) => new Text('${model.counter}'),
        ),
        new Text("Another widget that doesn't depend on the CounterListenable")
      ])
    );
  }
}
```

### Finding the Model

There are two ways to find the `Model` provided by the `Provide` Widget.

  1. Use the `EzConsumer` Widget. It will find the `Model` and run
  the builder function whenever the `Model` notifies the listeners.
  2. Use the
  [`Provide.of`](https://pub.dartlang.org/documentation/ez_listenable/latest/)
  static method directly. To make this method more readable for frequent access,
  you can consider adding your own `of` method to your own `Model` classes like
  so:
  
```dart
class CounterListenable extends Model {
  // ...
 
  /// Wraps [Provide.of] for this [Model].
  static CounterListenable of(BuildContext context) =>
      Provide.of<CounterListenable>(context);
}
```

### Listening to multiple models

If you need to listen to multiple models in a single `build` method, the easiest
way is to `Provide` two Models in a parent Widget, and use the static
`Provide.listen` function inside the `build` method of a descendant Widget. Any 
time the `Model` changes, the `build` function will be invoked.

```dart
class CombinedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final username = Provide.listen<UserModel>(context).username;
    final counter = Provide.listen<CounterListenable>(context).counter;

    return Text('$username tapped the button $counter times');
  }
}
```

This works via the power of the `InheritedWidget`. For more info on how this
works, please see the following articles:

  * [Widget — State — BuildContext — InheritedWidget](https://medium.com/flutter-community/widget-state-buildcontext-inheritedwidget-898d671b7956)
  * [InheritedWidget Documentation](https://docs.flutter.io/flutter/widgets/InheritedWidget-class.html)

## Contributors

  * Original Fuchsia Authors
  * [Brian Egan](https://github.com/brianegan)
  * [Pascal Welsch](https://github.com/passsy)
