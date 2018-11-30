library ez_listenable_flutter;

import 'package:ez_listenable/ez_listenable.dart';
import 'package:flutter/widgets.dart';

export 'package:ez_listenable/ez_listenable.dart';

/// Passes an [EzListenable] down to all descendants of this Widget.
///
/// Descendant Widgets can access the listenable by using the [EzConsumer]
/// Widget, which rebuilds each time the listenable changes, or directly via the
/// [EzProvider.of] / [EzProvider.listen] static method.
///
/// To provide a EzListenable to all screens, place the [EzProvider] Widget above the
/// [WidgetsApp] or [MaterialApp] in the Widget tree.
///
/// ### Example
///
/// ```
/// EzProvider<CounterListenable>(
///   listenable: EzValue<String>('A'),
///   child: EzConsumer<CounterListenable>(
///     builder: (context, listenable) => Text(listenable.value.toString()),
///   ),
/// );
/// ```
class EzProvider<T extends EzListenable> extends StatelessWidget {
  /// The [EzListenable] to provide to [child] and its descendants.
  final T listenable;

  /// The [Widget] the [listenable] will be available to.
  final Widget child;

  EzProvider({@required this.listenable, @required this.child})
      : assert(listenable != null),
        assert(child != null);

  @override
  Widget build(BuildContext context) {
    return EzBuilder<T>(
      listenable: listenable,
      builder: (context) {
        return _InheritedEz<T>(
          listenable: listenable,
          child: child,
        );
      },
    );
  }

  /// Finds a [EzListenable] provided by a [EzProvider] Widget.
  ///
  /// Generally, you'll use a [EzConsumer] to access a listenable in the Widget
  /// tree and rebuild when the listenable changes. However, if you would to
  /// access the listenable directly, you can use the static [EzProvider.of]
  /// function instead!
  ///
  /// ### Example
  ///
  /// ```
  /// final listenable = EzProvider.of<CounterListenable>();
  /// ```
  ///
  /// ## Building UIs based on multiple [EzListenable] classes
  ///
  /// If you want a build a single Widget based on two or more [EzListenable]
  /// classes, you can use the static [of] method! No need to manage
  /// subscriptions, Flutter takes care of all of that through the magic of
  /// InheritedWidgets.
  ///
  /// ```
  /// class CombinedWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     final username = EzProvider.of<UserListenable>(context).username;
  ///     final counter = EzProvider.of<CounterListenable>(context).counter;
  ///
  ///     return Text('$username tapped the button $counter times');
  ///   }
  /// }
  /// ```
  static T of<T extends EzListenable>(
    BuildContext context, {
    bool rebuildOnChange = true,
  }) {
    final Type type = _type<_InheritedEz<T>>();

    Widget widget = rebuildOnChange
        ? context.inheritFromWidgetOfExactType(type)
        : context.ancestorWidgetOfExactType(type);

    if (widget == null) {
      throw new EzProviderError();
    } else {
      return (widget as _InheritedEz<T>).listenable;
    }
  }

  static Type _type<T>() => T;
}

/// Listens to a [listenable] and calls [builder] whenever [listenable] changes.
class EzBuilder<T extends EzListenable> extends StatefulWidget {
  final T listenable;
  final WidgetBuilder builder;

  const EzBuilder({this.listenable, this.builder});

  @override
  _EzBuilderState createState() => new _EzBuilderState();
}

class _EzBuilderState extends State<EzBuilder> {
  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChange);
  }

  @override
  void didUpdateWidget(EzBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.listenable != oldWidget.listenable) {
      oldWidget.listenable.removeListener(_onChange);
      widget.listenable.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context);

  void _onChange() => setState(() {});
}

/// Provides [listenable] to its [child] [Widget] tree via [InheritedWidget].
/// When [version] changes, all descendants who request (via
/// [BuildContext.inheritFromWidgetOfExactType]) to be rebuilt when the
/// listenable changes will do so.
class _InheritedEz<T extends EzListenable> extends InheritedWidget {
  final T listenable;

  _InheritedEz({Key key, Widget child, T listenable})
      : this.listenable = listenable,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_InheritedEz<T> oldWidget) => true;
}

/// Builds a child for a [EzConsumer].
typedef Widget EzWidgetBuilder<T extends EzListenable>(
  BuildContext context,
  T listenable,
);

/// Finds a specific [EzListenable] provided by a [EzProvider] Widget and
/// rebuilds whenever the [EzListenable] changes.
///
/// Provides an option to disable rebuilding when the [EzListenable] changes.
///
/// Provide a constant [child] Widget if some portion inside the builder does
/// not rely on the [EzListenable] and should not be rebuilt.
///
/// ### Example
///
/// ```
/// EzProvider<EzValue<int>>(
///   listenable: EzValue<int>(0),
///   child: EzConsumer<EzValue<int>>(
///     builder: (context, listenable) {
///       return Column(
///         children: [
///           Text('Button has been pressed:'),
///           Text('${listenable.counter}'),
///         ],
///       );
///     }
///   ),
/// );
/// ```
class EzConsumer<T extends EzListenable> extends StatelessWidget {
  /// Called whenever the [EzListenable] changes.
  final EzWidgetBuilder<T> builder;

  /// An optional constant that determines whether the
  final bool rebuildOnChange;

  /// Constructor.
  EzConsumer({
    @required this.builder,
    this.rebuildOnChange = true,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      EzProvider.of<T>(context, rebuildOnChange: rebuildOnChange),
    );
  }
}

class EzProviderError extends Error {
  EzProviderError();

  String toString() {
    return '''Error: Could not find the correct EzProvider.
    
To fix, please:
          
  * Provide complete types for:
    * EzProvider<MyEzListenable>
    * EzConsumer<MyEzListenable> 
    * EzProvider.of<MyEzListenable>() 
  * Always use package imports. Ex: `import 'package:my_app/my_listenable.dart';
  
If none of these solutions work, please file a bug at:
https://github.com/brianegan/ez_listenable/issues/new
      ''';
  }
}
