# ez_listenable

[![Build Status](https://travis-ci.org/brianegan/ez_listenable.svg?branch=master)](https://travis-ci.org/brianegan/ez_listenable)  [![codecov](https://codecov.io/gh/brianegan/ez_listenable/branch/master/graph/badge.svg)](https://codecov.io/gh/brianegan/ez_listenable)

A set of utilities that allow you to build apps based on observable
`EzListenable` classes.

This work is based on the `Listenable` class provided by Flutter and the Scoped
Model classes from the Fuchsia codebase. However, the `Listenable` class is part
of the Flutter framework, meaning any classes that extend `Listenable` cannot be
shared with a web project. In contrast, the core `ez_listenable` library is
written in pure Dart, which means code can be shared across both Flutter and Web
projects.

This library includes four parts:

  * [ez_listenable](https://github.com/brianegan/ez_listenable/tree/master/ez_listenable) - A set of `EzListenable` classes that can be used to provide data that other classes can to listen for changes.
  * [ez_listenable_flutter](https://github.com/brianegan/ez_listenable/tree/master/ez_listenable_flutter) - Widgets to build Flutter apps based on `EzListenable` objects. Allows you to pass an `EzListenable` through the Widget hierarchy, or rebuild a single Widget based on an `EzListenable` 
  * [ez_listenable_angular](https://github.com/brianegan/ez_listenable/tree/master/ez_listenable_angular) - Pipes to build Angular components based on the data contained within an `EzListenable`. Also rebuilds the component when the listeners are notified! 
  * [ez_listenable_test](https://github.com/brianegan/ez_listenable/tree/master/ez_listenable_test) - Utils for testing `EzListenable` classes  

## Contributors

  * Original Fuchsia Authors
  * Original Flutter authors
  * [Brian Egan](https://github.com/brianegan)
