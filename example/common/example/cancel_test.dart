import 'dart:async';

import 'package:async/async.dart';

void main() {
  runIt();
}

void runIt() {
  final operation = CancelableOperation.fromFuture(
    Future.delayed(Duration(seconds: 1), () => 'Cancelled?'),
  );

  () async {
    final result = await operation.value;

    print('Here? $result');
  }();

  operation.cancel();
}
