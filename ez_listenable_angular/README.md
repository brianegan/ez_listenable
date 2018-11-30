# ez_listenable_angular

A `ListenPipe` (`listen` in templates) that allows you to listen for changes to
an `EzListenable` and rebuild the `Component` when it does.

## Usage

First, include the `ListenPipe` in your `Component` declaration, then use the
`listen` pipe in your template:

```dart
import 'package:angular/angular.dart';
import 'package:ez_listenable/ez_listenable.dart';
import 'package:ez_listenable_angular/ez_listenable_angular.dart';

@Component(
  selector: 'my-component',
  // Listen to the EzListenable for changes and print current value. When the
  // user taps the button, the component will be updated.
  template: '''
      <p>{{(listenable | listen).value}}</p>
      <button (click)="listenable.value = 'Button Pressed'">Update</button>
    ''',
  // Add the ListenPipe
  pipes: [ListenPipe],
  // Use OnPush for performance.
  changeDetection: ChangeDetectionStrategy.OnPush,
)
class MyComponent {
  @Input()
  EzValue<String> listenable;
}
```

## Features and bugs

Please file feature requests and bugs at the
[issue tracker](http://example.com/brianegan/ez_listenable).
