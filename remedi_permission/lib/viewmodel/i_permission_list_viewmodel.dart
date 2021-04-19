import 'package:remedi_permission/repository/i_permission_list_repository.dart';
import 'package:stacked_mvvm/stacked_mvvm.dart';

abstract class IPermissionListViewModel
    extends BaseViewModel<PermissionListViewState, IPermissionListRepository> {
  IPermissionListViewModel({required IPermissionListRepository repository})
      : super(repository: repository);

  bool hasError = false;

  Future<dynamic> requestAll();

  Future<bool> get checkError;

  skipOrNext();

  Future<bool> get canSkip;

  Future<bool> get showNext;

  Future<bool> get showRequestAll;

  Future<dynamic> refresh();
}

enum PermissionListViewState { Init, Refresh, Error, Skip, AllGranted }
