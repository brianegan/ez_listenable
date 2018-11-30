# ez_listenable

[![Build Status](https://travis-ci.org/brianegan/ez_listenable.svg?branch=master)](https://travis-ci.org/brianegan/ez_listenable)  [![codecov](https://codecov.io/gh/brianegan/ez_listenable/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/ez_listenable)

A set of utilities that allow you to easily pass a data Model from a parent Widget down to it's descendants. In addition, it also re-renders all of the children that use the listenable when it changes.

Besides a couple of tests and a bit of documentation, this is not my work / idea. It's a simple extraction of the [Model classes](https://github.com/fuchsia-mirror/topaz/blob/c2be8939b45ad0494f0130dbea6460e77abbe62b/public/dart/widgets/lib/src/model/model.dart) from Fuchsia's core Widgets, presented as a standalone Flutter Plugin for independent use so we can evaluate this architecture pattern more easily as a community.

## Examples

  * [Counter App](https://github.com/brianegan/ez_listenable/tree/master/ez_listenable_flutter/example) - Introduction to the tools provided by EzListenable. 
  * [Github Search App (Mobile and Web app)](https://github.com/brianegan/ez_listenable/tree/master/example) - Shows how to write a cross-platform app using EzListenable. 

## Usage

Let's demo the basic usage with the all-time favorite: A counter example!

```dart
// Start by creating a class that holds some view the app's state. In
// our example, we'll have a simple counter that starts at 0 can be 
// incremented.
//
// Note: It must extend from Model.  
class CounterListenable extends Model {
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
    // First, create a `ScopedModel` widget. This will provide 
    // the `model` to the children that request it. 
    return new ScopedModel<CounterListenable>(
      listenable: new CounterListenable(),
      child: new Column(children: [
        // Create a ScopedModelDescendant. This widget will get the
        // CounterListenable from the nearest ScopedModel<CounterListenable>. 
        // It will hand that model to our builder method, and rebuild 
        // any time the CounterListenable changes (i.e. after we 
        // `notifyListeners` in the Model). 
        new ScopedModelDescendant<CounterListenable>(
          builder: (context, model) => new Text('${model.counter}'),
        ),
        new Text("Another widget that doesn't depend on the CounterListenable")
      ])
    );
  }
}
```

### Finding the Model

There are two ways to find the `Model` provided by the `ScopedModel` Widget.

  1. Use the `ScopedModelDescendant` Widget. It will find the `Model` and run the
  builder function whenever the `Model` notifies the listeners.
  2. Use the [`ScopedModel.of`](https://pub.dartlang.org/documentation/ez_listenable/latest/) static method directly. To make this method more readable for frequent access, you can consider adding your own `of` method to your own `Model` classes like so:
  
```dart
class CounterListenable extends Model {
  // ...
 
  /// Wraps [ScopedModel.of] for this [Model].
  static CounterListenable of(BuildContext context) =>
      ScopedModel.of<CounterListenable>(context);
}
```  

## Contributors

  * Original Authors
  * [Brian Egan](https://github.com/brianegan)
  * [Pascal Welsch](https://github.com/passsy)
