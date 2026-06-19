import 'package:flutter/foundation.dart';
import 'package:wheelhub/core/enums/view_state.dart';

///
/// [BaseViewModel] is the base class with all
/// state related logic.
///
/// [BaseViewModel] class will be extended by all viewModels.
///
/// [setState] will be used to update the state of the screen
///
class BaseViewModel extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  bool _disposed = false;

  ViewState get state => _state;

  void setState(ViewState state) {
    _state = state;
    safeNotifyListeners();
  }

  void safeNotifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
