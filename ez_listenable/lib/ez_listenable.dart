library ez_listenable;

import 'dart:async';

import 'package:meta/meta.dart';

/// An object that maintains a set of listeners.
abstract class EzListenable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const EzListenable();

  /// Return a [EzListenable] that triggers when any of the given
  /// [EzListenable]s themselves trigger.
  ///
  /// The list must not be changed after this method has been called. Doing so
  /// will lead to memory leaks or exceptions.
  ///
  /// The list may contain nulls; they are ignored.
  factory EzListenable.merge(List<EzListenable> listenables) = _EzMerged;

  /// Register a closure to be called when the object notifies its listeners.
  void addListener(void Function() listener);

  /// Register a closure to be called the first time the object notifies its
  /// listeners.
  void once(void Function() listener);

  /// Remove a previously registered closure from the list of closures that the
  /// object notifies.
  void removeListener(void Function() listener);
}

/// An interface for subclasses of [EzListenable] that expose a [value].
///
/// This interface is implemented by [EzValue<T>] and [Animation<T>], and
/// allows other APIs to accept either of those implementations interchangeably.
abstract class EzValueListenable<T> implements EzListenable {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const EzValueListenable();

  /// The current value of the object. When the value changes, the callbacks
  /// registered with [addListener] will be invoked.
  T get value;
}

/// A base class that holds some data and allows other classes to listen to
/// changes to that data.
///
/// In order to notify listeners that the data has changed, you must explicitly
/// call the [notifyListeners] method.
///
/// ### Example
///
/// ```
/// class CounterNotifier extends EzNotifier {
///   int _counter = 0;
///
///   int get counter => _counter;
///
///   void increment() {
///     // First, increment the counter
///     _counter++;
///
///     // Then notify all the listeners.
///     notifyListeners();
///   }
/// }
/// ```
abstract class EzNotifier extends EzListenable {
  Set<void Function()> _listeners = new Set<void Function()>();
  Set<void Function()> _onceListeners = new Set<void Function()>();

  int _version = 0;

  int get version => _version;

  /// Register a [listener] callback that will be invoked whenever
  /// [notifyListeners] is called.
  void addListener(void Function() listener) {
    assert(_debugAssertNotDisposed());

    _listeners.add(listener);
  }

  /// Register a [listener] callback that will be invoked the first time
  /// [notifyListeners] is called.
  void once(void Function() listener) {
    assert(_debugAssertNotDisposed());

    _onceListeners.add(listener);
  }

  /// The provided callback will no longer be invoked when [notifyListeners] is
  /// called
  void removeListener(void Function() listener) {
    assert(_debugAssertNotDisposed());

    _listeners.remove(listener);
    _onceListeners.remove(listener);
  }

  /// Clear all subscriptions and shut the EzListenable down. It will no longer be
  /// usable after this point.
  void dispose() {
    assert(_debugAssertNotDisposed());
    _listeners = null;
  }

  /// Should be called only by [EzNotifier] subclasses when the data has
  /// changed. This will cause all registered listeners to be invoked.
  @protected
  void notifyListeners() {
    assert(_debugAssertNotDisposed());
    _version++;

    // Convert the listeners into a list before execution. This will prevent
    // iterable modification errors if a listener removes itself inside the
    // callback.
    _listeners.toList().forEach((listener) => listener());
    _onceListeners.toList().forEach((listener) => listener());
    _onceListeners.clear();
  }

  bool _debugAssertNotDisposed() {
    assert(() {
      if (_listeners == null) {
        throw new Exception('A $runtimeType was used after being disposed.\n'
            'Once you have called dispose() on a $runtimeType, it can no longer be used.');
      }
      return true;
    }());
    return true;
  }
}

/// An EzNotifier that holds a single value. Whenever the value changes,
/// listener callbacks will be invoked.
///
/// ### Example
///
/// ```
/// final ez = EzValue<String>('A');
///
/// ez.addListener(() => print(ez.value));
///
/// ez.value = 'B'; // prints 'B'
/// ```
class EzValue<T> extends EzNotifier implements EzValueListenable<T> {
  T _value;
  StreamSubscription<T> _subscription;

  EzValue([T initialValue]) : _value = initialValue;

  /// Get the current value
  T get value => _value;

  /// Update the current value and notify all listeners
  set value(T newValue) {
    _value = newValue;
    notifyListeners();
  }

  StreamSubscription<T> bind(Stream<T> stream) {
    _subscription = stream.listen((newValue) => value = newValue);

    return _subscription;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EzValue &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  String toString() {
    return 'EzValue{value: $_value}';
  }
}

/// A class that can be used to derive a value based on data from another
/// [EzListenable] or several [EzListenable]s.
///
/// The value will be recomputed when the provided [listenable] notifies the
/// listeners that values have changed. You can also use [EzComputedValue.merge]
/// to compute a value based on multiple [EzListenable]s
///
/// ### Simple Example
///
/// ```dart
/// final email = EzValue<String>('a');
///
/// // Determine whether or not the email is valid using a (hacky) validator.
/// final emailValid = EzComputation(
///   email,
///   () => email.value.contains('@'),
/// );
///
/// // The function provided to EzComputation is immediately executed,
/// // and the computed value is available synchronously.
/// print(emailValid); // prints 'false'.
///
/// // When the email EzValue is changed, the function will be synchronously
/// // run again!
/// email.value = 'a@b.com';
/// print(emailValid); // prints 'true'.
/// ```
///
/// ### Deriving data from multiple [EzListenable]s
///
/// In this case, we can use the [EzComputedValue.merge] function to listen to
/// several [EzListenable]s and recompute a value any time any of them notify
/// a change.
///
/// ```dart
/// final email = EzValue<String>('');
/// final password = EzValue<String>('');
///
/// // Determine whether the email is valid, and make that a Listenable!
/// final emailValid = EzComputation<bool>(
///   email,
///   () => email.value.contains('@'),
/// );
///
/// // Determine whether the password is valid, and make that a Listenable!
/// final passwordValid = EzComputation<bool>(
///   password,
///   () => password.value.length >= 6,
/// );
///
/// // Now, we will only enable the "Login Button" when the email and
/// // password are valid. To do so, we can listen to the emailValid and
/// // passwordValid EzComputed. We use use the merge factory for
/// // this purpose! (Under the hood, it uses EzListenable.merge)
/// final loginButtonEnabled = EzComputation<bool>.merge(
///   [emailValid, passwordValid],
///   () => emailValid.value && passwordValid.value,
/// );
///
/// // Update the email
/// print(emailValid.value); // false
/// print(loginButtonEnabled.value); // false
/// email.value = 'a@b.com';
/// print(emailValid.value); // true
/// print(loginButtonEnabled.value); // false
///
/// // Update the password
/// print(passwordValid.value); // false
/// password.value = '123456';
/// print(passwordValid.value); // true
/// print(loginButtonEnabled.value); // true
/// ```
class EzComputedValue<T> extends EzNotifier implements EzValueListenable<T> {
  final EzNotifier _merged;
  final T Function() compute;
  T _value;

  T get value => _value;

  EzComputedValue(EzListenable listenable, this.compute)
      : _merged = _EzMerged([listenable]) {
    _updateValue();
    _merged.addListener(_updateValue);
  }

  factory EzComputedValue.merge(
    List<EzListenable> listenables,
    T Function() compute,
  ) {
    return EzComputedValue(_EzMerged(listenables), compute);
  }

  @override
  void dispose() {
    _merged.dispose();
    super.dispose();
  }

  void _updateValue() => _value = compute();

  @override
  String toString() {
    return 'EzComputed{value: $value}';
  }
}

/// Merges multiple EzListenables into a single listenable.
class _EzMerged extends EzNotifier {
  _EzMerged(this._children) {
    for (EzListenable child in _children) child?.addListener(notifyListeners);
  }

  final List<EzListenable> _children;

  @override
  void dispose() {
    for (EzListenable child in _children)
      child?.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  String toString() {
    return 'EzListenable.merge([${_children.join(", ")}])';
  }
}
