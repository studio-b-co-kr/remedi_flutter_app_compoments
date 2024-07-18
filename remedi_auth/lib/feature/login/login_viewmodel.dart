import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:remedi_auth/auth_repository.dart';
import 'package:remedi_auth/model/apple_credential.dart';
import 'package:remedi_auth/model/i_app_credential.dart';
import 'package:remedi_auth/model/kakao_credential.dart';
import 'package:remedi_auth/repository/i_login_repository.dart';
import 'package:remedi_auth/resources/app_strings.dart';
import 'package:remedi_auth/viewmodel/i_login_viewmodel.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:developer' as dev;

import '../../auth_error.dart';

class LoginViewModel extends ILoginViewModel {
  final String? kakaoAppId;
  final ILoginRepository repository;

  LoginViewModel({required this.repository, this.kakaoAppId}) : super();

  @override
  LoginViewState get initState => LoginViewState.Idle;

  @override
  loginWithApple() async {
    update(state: LoginViewState.Loading);
    bool isAvailable = await SignInWithApple.isAvailable();
    if (!isAvailable) {
      this.authError = AuthError(
          title: AppStrings.loginError,
          code: AppStrings.codeAppleLoginError,
          message: AppStrings.invalidVersionAppleLogin);
      update(state: LoginViewState.Error);
      return;
    }

    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      AppleCredential appleCredential = AppleCredential(
          userIdentifier: credential.userIdentifier,
          identityToken: credential.identityToken,
          authorizationCode: credential.authorizationCode,
          email: credential.email);

      var appCredential = await repository.loginWithApple(appleCredential);

      if (appCredential is ICredential) {
        if (appCredential.isError) {
          this.authError = appCredential.error;
          update(state: LoginViewState.Error);
          return;
        }

        await Future.wait([
          AuthRepository.instance().writeUserId(appCredential.userId),
          AuthRepository.instance().writeUserCode(appCredential.userCode),
          AuthRepository.instance().writeAccessToken(appCredential.accessToken),
          AuthRepository.instance()
              .writeRefreshToken(appCredential.refreshToken ?? "")
        ]);

        update(state: LoginViewState.Success);
        return;
      } else {
        throw AuthError(
            title: AppStrings.loginError, code: AppStrings.codeAppleLoginError);
      }
    } catch (e) {
      String title = AppStrings.loginError;
      String code = AppStrings.codeAppleLoginError;
      String message = AppStrings.messageAuthError;

      if (e is SignInWithAppleAuthorizationException) {
        title = e.code.toString();
        code = e.message;
        message = e.message;
        if (e.code == AuthorizationErrorCode.canceled ||
            e.code == AuthorizationErrorCode.unknown) {
          update(state: LoginViewState.Idle);
          return;
        }
      }

      this.authError =
          AuthError(title: title, code: code, message: message, error: e);
      update(state: LoginViewState.Error);
    }
  }

  @override
  loginWithKakao() async {
    update(state: LoginViewState.Loading);

    _KakaoLoginInfo? loginInfo = await loginKakao();

    if (loginInfo == null) {
      this.authError = AuthError(
          title: AppStrings.loginError, code: AppStrings.codeKakaoLoginError);
      update(state: LoginViewState.Error);
    } else {
      var credential = await repository.loginWithKakao(KakaoCredential(
          accessToken: loginInfo.accessToken, id: loginInfo.userId));

      if (credential is ICredential) {
        if (credential.isError) {
          this.authError = credential.error;
          await UserApi.instance.logout();
          update(state: LoginViewState.Error);
          return;
        }

        await Future.wait([
          AuthRepository.instance().writeUserId(credential.userId),
          AuthRepository.instance().writeUserCode(credential.userCode),
          AuthRepository.instance().writeAccessToken(credential.accessToken),
          AuthRepository.instance()
              .writeRefreshToken(credential.refreshToken ?? "")
        ]);

        await UserApi.instance.logout();
        update(state: LoginViewState.Success);
      } else {
        this.authError = AuthError(
            title: AppStrings.loginError, code: AppStrings.codeKakaoLoginError);
        await UserApi.instance.logout();
        update(state: LoginViewState.Error);
      }
    }
  }

  Future<_KakaoLoginInfo?> loginKakao() async {
    String accessToken;
    int? userId;
    if (await isKakaoTalkInstalled()) {
      try {
        accessToken = (await UserApi.instance.loginWithKakaoTalk()).accessToken;
        userId = (await UserApi.instance.accessTokenInfo()).id;
      } catch (error) {
        if (error is PlatformException && error.code == 'CANCELED') {
          dev.log(error.toString(), name: 'CANCELED');
          return null;
        } else {
          dev.log(error.toString(), name: '`loginWithKakaoTalk()`');
        }
        // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
        try {
          accessToken =
              (await UserApi.instance.loginWithKakaoAccount()).accessToken;
          userId = (await UserApi.instance.accessTokenInfo()).id;
        } catch (error) {
          dev.log(error.toString(),
              name: '`isKakaoTalkInstalled()` but `loginWithKakaoAccount()`');
          return null;
        }
      }
    } else {
      try {
        accessToken =
            (await UserApi.instance.loginWithKakaoAccount()).accessToken;
        userId = (await UserApi.instance.accessTokenInfo()).id;
      } catch (error) {
        dev.log(error.toString(), name: '`loginWithKakaoAccount()`');
        return null;
      }
    }
    return _KakaoLoginInfo(accessToken: accessToken, userId: userId);
  }
}

class _KakaoLoginInfo {
  String? accessToken;
  int? userId;

  _KakaoLoginInfo({this.accessToken, this.userId});
}
