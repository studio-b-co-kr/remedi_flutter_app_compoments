import 'package:remedi/architecture/architecture.dart';

abstract class ISplashRepository extends Repository {
  Future<dynamic> appOpen();

  Future<bool> needToUpdate();

  void goUpdate();

  Future<bool> isCompletedIntro();

  void goIntro();

  Future<bool> isCompletedPermissionGrant();

  void goPermission();

  Future<bool> isLogin();

  void goLogin();

  Future<bool> isCompletedOnboarding();

  void goOnboarding();

  Future<dynamic> readyToService();
}
