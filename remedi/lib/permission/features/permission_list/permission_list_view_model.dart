part of 'permission_list.dart';

class PermissionListViewModel extends ViewModel {
  final List<AppPermission> permissionList;

  PermissionListViewModel({required this.permissionList});

  @override
  initialise() {
    loadStateAll();
  }

  loadStateAll() async {
    await Future.forEach<AppPermission>(permissionList, (permission) async {
      await Future.delayed(Duration.zero);
      await permission.loadStatus;
      dev.log('permission.name = ${permission.permission}', name: toString());
      dev.log('permission.state = ${permission.state}', name: toString());
    });

    updateUi();
  }

  requestAll() async {
    await Future.forEach<AppPermission>(permissionList, (permission) async {
      (await permission.request());
    });

    updateUi();
  }

  request(AppPermission appPermission) async {
    // before request get status.
    AppLog.log('${appPermission.state}', name: '${appPermission.hashCode}');
    if (appPermission.state == AppPermissionState.permanentlyDenied) {
      await openAppSettings();
    } else {
      await appPermission.request();
    }
    updateUi();
  }

  bool get canSkipAll {
    bool ret = true;
    for (var element in permissionList) {
      if (element.shouldBeGranted) {
        ret = false;
        break;
      }
    }

    return ret;
  }
}
