import 'package:example/features/contents/contents_page.dart';
import 'package:example/features/contents/contents_view_model.dart';
import 'package:example/features/home/home_page.dart';
import 'package:example/features/home/home_view_model.dart';
import 'package:example/features/settings/settings_page.dart';
import 'package:example/features/settings/settings_view_model.dart';
import 'package:example/features/splash/splash_page.dart';
import 'package:example/features/splash/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:remedi_architecture/remedi_architecture.dart';

///
class ExampleAppRouteGenerator extends IRouteGenerator {
  ExampleAppRouteGenerator({ScreenLogger? screenLogger})
      : super(screenLogger: screenLogger);

  @override
  Route<dynamic>? generateRoute(
    RouteSettings settings,
  ) {
    Route<dynamic>? ret;
    switch (settings.name) {
      case SettingsPage.routeName:
        ret = MaterialPageRoute(
          settings: settings,
          builder: (context) => SettingsPage(
            viewModel: SettingsViewModel.singleton(),
          ),
        );
        break;

      case ContentsPage.routeName:
        ret = MaterialPageRoute(
          settings: settings,
          builder: (context) => ContentsPage(
            viewModel: ContentsViewModel.singleton(),
          ),
        );
        break;
      case SplashPage.routeName:
        ret = MaterialPageRoute(
          settings: settings,
          builder: (context) => SplashPage(
            viewModel: SplashViewModel.singleton(),
          ),
        );
        break;
      case HomePage.routeName:
        ret = MaterialPageRoute(
          settings: settings,
          builder: (context) => HomePage(
            viewModel: HomeViewModel.singleton(),
          ),
        );
        break;
    }

    return ret;
  }
}
