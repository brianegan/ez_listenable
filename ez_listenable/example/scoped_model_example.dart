import 'package:ez_listenable/ez_listenable.dart';

void main() {
  // Create an EzValue, which is a type of EzListenable that notifies its
  // listeners  every time the value changes
  final ezValue = new EzValue('Hi');

  // Create a function that will print the latest value
  void logger() => print(ezValue.value);

  // Register the logger as a listener
  ezValue.addListener(logger);

  // Update the value.
  ezValue.value = 'Hello'; // prints 'Hello'

  // Remove the logger as a listener. No longer prints on value change
  ezValue.removeListener(logger);

  // Does not print anything
  ezValue.value = 'Yo';

  // Dispose of the EzValue when you're done with it
  ezValue.dispose();
}
