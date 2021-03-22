part of 'stacked_mvvm.dart';

abstract class BaseViewModel<S, R extends BaseRepository>
    with ChangeNotifier, DiagnosticableTreeMixin {
  S? state;

  @mustCallSuper
  BaseViewModel({this.repository}) {
    state = initState;
  }

  S get initState;

  /// use this method to move other screen or show popup
  update({S? state}) {
    this.state = state;
    notifyListeners();
  }

  init() async {
    /// Do not update ui here.
    /// Only for background work. ex> get data or others.
  }

  final R? repository;

  @mustCallSuper
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty('state', state));
  }
}
