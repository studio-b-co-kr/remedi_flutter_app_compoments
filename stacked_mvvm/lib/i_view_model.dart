part of 'stacked_mvvm.dart';

abstract class IViewModel<S> extends BaseViewModel {
  late S state;
  late StreamController<S> _streamController;
  late Stream<S> _stream;

  // ignore: invalid_annotation_target
  @mustCallSuper
  IViewModel() {
    state = initState;
    _streamController = BehaviorSubject<S>();
    _stream = _streamController.stream;
  }

  S get initState;

  /// use this method to move other screen or show popup
  update({S? state}) {
    _add(state: state);

    try {
      notifyListeners();
    } catch (_) {}
  }

  @mustCallSuper
  init() async {
    _add(state: initState);
  }

  get stream => _stream;

  void _add({S? state}) {
    // if _streamController is null, create the instance again.
    if (_streamController.isClosed) {
      _streamController = BehaviorSubject<S>();
      _stream = _streamController.stream;
    }

    // if state is null, keep prev state.
    this.state = state ?? this.state;
    // if state is null, do not add state to the stream.
    if (state != null) _streamController.add(this.state);
  }
}
