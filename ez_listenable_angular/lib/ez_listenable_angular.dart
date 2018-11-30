library ez_listenable_angular;

import 'package:angular/core.dart';
import 'package:ez_listenable/ez_listenable.dart';

@Pipe('listen', pure: false)
class ListenPipe implements OnDestroy, PipeTransform {
  EzListenable _listenable;
  ChangeDetectorRef _ref;

  ListenPipe(this._ref);

  @override
  void ngOnDestroy() {
    if (_listenable != null) {
      _disconnect();
    }
  }

  dynamic transform(dynamic listenable) {
    assert(listenable is EzListenable,
        'Must pass an EzListenable into the listen pipe');

    if (_listenable == null) {
      _connect(listenable);
    } else if (_listenable != listenable) {
      _disconnect();
      _connect(listenable);
    }

    return listenable;
  }

  void _connect(EzListenable listenable) {
    _listenable = listenable;
    _listenable.addListener(_ref.markForCheck);
  }

  void _disconnect() {
    _listenable.removeListener(_ref.markForCheck);
  }
}
