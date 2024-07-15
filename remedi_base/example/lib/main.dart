import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:remedi_base/remedi_base.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setFlavorConfig(
    baseUrl: "https://google.com",
    baseWebUrl: "https://naver.com",
    isRelease: kReleaseMode,
    // "prod",
    endpoint: "dev",
    enablePrintLog: kReleaseMode,
  );

  // First time, do init()
  await AppConfig.init();

  AppConfig.log();

  runApp(AppWrapper(
    app: MaterialApp(
      home: MyApp(),
    ),
    initialJobs: [
      () {
        dev.log("function 1");
      },
      () {
        dev.log("function 2");
      },
      () {
        dev.log("function 3");
      }
    ],
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: FutureBuilder(
          builder: (context, snapshot) {
            String htmlString = 'about:blank';
            if (snapshot.hasData) {
              htmlString = "${snapshot.data}";
            }
            return ListView(
              children: [Text(htmlString)],
            );
          },
          future: initPlatformState(),
        ),
      ),
    );
  }
}
