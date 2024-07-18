import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:remedi_permission/repository/i_permission_repository.dart';
import 'package:remedi_permission/viewmodel/i_permission_viewmodel.dart';

class PermissionViewModel extends IPermissionViewModel {
  final IPermissionRepository repository;

  PermissionViewModel({required this.repository}) : super();

  @override
  PermissionViewState get initState => PermissionViewState.Init;

  @override
  init() async {
    // await Future.delayed(Duration(milliseconds: 100));
    await repository.init();
    _handleStatus(repository.status);
    super.init();
  }

  @override
  Future<bool> goToSettings() async {
    return await openAppSettings();
  }

  @override
  Future<PermissionStatus> requestPermission() async {
    switch (repository.status ?? PermissionStatus.granted) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        // close permission page and back to the screen to request permission.
        break;
      case PermissionStatus.denied:
        // if the permission is mandatory to use app, keep permission page.
        await repository.request();
        if (repository.status == PermissionStatus.limited ||
            repository.status == PermissionStatus.granted) {
          update(state: PermissionViewState.grantedAndExit);
        }
        break;

      case PermissionStatus.permanentlyDenied:
        // goto settings
        bool ret = await openAppSettings();
        if (ret) {
          await repository.readPermissionStatus();
        }
        break;

      case PermissionStatus.restricted:
        // impossible to access
        break;
    }

    _handleStatus(repository.status);

    return repository.status ?? PermissionStatus.granted;
  }

  _handleStatus(PermissionStatus? status) {
    if (status == null) {
      return;
    }

    PermissionViewState state = PermissionViewState.Denied;
    switch (status) {
      case PermissionStatus.granted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        state = PermissionViewState.Granted;

        break;
      case PermissionStatus.denied:
        if (repository.permission.mandatory) {
          state = PermissionViewState.Error;
        } else {
          state = PermissionViewState.Denied;
        }
        break;
      case PermissionStatus.permanentlyDenied:
        if (repository.permission.mandatory) {
          state = PermissionViewState.Error;
        } else {
          state = PermissionViewState.PermanentlyDenied;
        }
        break;
      case PermissionStatus.restricted:
        state = PermissionViewState.Disabled;
        break;
    }

    update(state: state);
  }

  @override
  String get description => repository.permission.description ?? "";

  @override
  String get errorDescription => repository.permission.errorDescription ?? "";

  @override
  String get title => repository.permission.title ?? "";

  @override
  String get statusMessage {
    String ret = "";
    switch (state) {
      case PermissionViewState.Granted:
      case PermissionViewState.Limited:
        ret = "허용됨";
        break;
      case PermissionViewState.Init:
      case PermissionViewState.Denied:
      case PermissionViewState.PermanentlyDenied:
        ret = "해당 권한을 허용해주세요.";
        break;
      case PermissionViewState.Error:
        ret = errorDescription;
        break;
      case PermissionViewState.Disabled:
      case PermissionViewState.Restricted:
        ret = "사용 불가능합니다.";
        break;
      default:
        break;
    }
    return ret;
  }

  @override
  Future refresh() async {
    PermissionStatus status = await repository.readPermissionStatus();
    _handleStatus(status);
  }

  @override
  Widget icon({double size = 24}) {
    return repository.permission.icon ?? _generateIcon(size: size);
  }

  Widget _generateIcon({double size = 24}) {
    IconData iconData;
    switch (repository.permission.permission.value) {
      case 0: //calendar
        iconData = Icons.calendar_today_sharp;
        break;
      case 1: //camera
        iconData = Icons.camera_alt_outlined;
        break;
      case 2: //contacts
        iconData = Icons.contacts_outlined;
        break;
      case 3: //location
      case 4: //locationAlways
      case 5: //locationWhenInUse
        iconData = Icons.location_on_outlined;
        break;
      case 6: //mediaLibrary
        iconData = Icons.library_music_outlined;
        break;
      case 7: //microphone
        iconData = Icons.mic_none_outlined;
        break;
      case 8: //phone
        iconData = Icons.local_phone_outlined;
        break;
      case 9: //photos
        iconData = Icons.photo_size_select_actual_outlined;
        break;
      case 10: //photosAddOnly
        iconData = Icons.add_a_photo_outlined;
        break;
      case 11: //reminders
        iconData = Icons.access_alarms;
        break;
      case 12: //sensors
        iconData = Icons.device_thermostat;
        break;
      case 13: //sms
        iconData = Icons.sms_outlined;
        break;
      case 14: //speech
        iconData = Icons.connect_without_contact;
        break;
      case 15: //storage
        iconData = Icons.sd_storage_outlined;
        break;
      case 16: //ignoreBatteryOptimizations
        iconData = Icons.battery_alert_rounded;
        break;
      case 17: //notification
        iconData = Icons.notifications_active_outlined;
        break;
      case 18: //accessMediaLocation
        iconData = Icons.mediation_sharp;
        break;
      case 19: //activityRecognition
        iconData = Icons.accessibility;
        break;
      case 21: //bluetooth
        iconData = Icons.bluetooth;
        break;
      case 20: //unknown
      default:
        iconData = Icons.device_unknown_sharp;
        break;
    }

    return Icon(
      iconData,
      size: size,
      color: Colors.blueGrey.shade700,
    );
  }

  @override
  Future<bool> get canSkip async => false;

  @override
  bool get isError => repository.isError;

  @override
  bool get isGranted => repository.isGranted;

  @override
  bool get isPermanentlyDenied => repository.isPermanentlyDenied;
}

/// refer to below permission status.
// enum PermissionStatus {
//   /// The user granted access to the requested feature.
//   granted,
//
//   /// The user denied access to the requested feature.
//   denied,
//
//   /// The OS denied access to the requested feature. The user cannot change
//   /// this app's status, possibly due to active restrictions such as parental
//   /// controls being in place.
//   /// *Only supported on iOS.*
//   restricted,
//
//   ///User has authorized this application for limited access.
//   /// *Only supported on iOS (iOS14+).*
//   limited,
//
//   /// The user denied access to the requested feature and selected to never
//   /// again show a request for this permission. The user may still change the
//   /// permission status in the settings.
//   /// *Only supported on Android.*
//   permanentlyDenied,
// }
