/// App Container
import 'dart:developer' as dev;

import 'package:flutter/material.dart';

class AppWrapper extends StatefulWidget {
  final MaterialApp app;
  final List<Function> initialJobs = [];
  final Function? dispose;

  AppWrapper(
      {Key? key, required this.app, List<Function>? initialJobs, this.dispose})
      : super(key: key) {
    if (initialJobs != null && initialJobs.isNotEmpty) {
      this.initialJobs.addAll(initialJobs);
    }
  }

  @override
  State<StatefulWidget> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    widget.initialJobs.forEach((Function function) {
      function();
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return widget.app;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
        onDetached();
        break;
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.paused:
        onPaused();
        break;
      case AppLifecycleState.inactive:
        onInactive();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @mustCallSuper
  void onResumed() {
    dev.log("onResumed, key = ${widget.key}, this = $this", name: "AppWrapper");
  }

  @mustCallSuper
  void onDetached() {
    dev.log("onResumed, key = ${widget.key}, this = $this", name: "AppWrapper");
  }

  @mustCallSuper
  void onPaused() {
    dev.log("onResumed, key = ${widget.key}, this = $this", name: "AppWrapper");
  }

  @mustCallSuper
  void onInactive() {
    dev.log("onResumed, key = ${widget.key}, this = $this", name: "AppWrapper");
  }

  void dispose() {
    if (widget.dispose != null) widget.dispose!();
    super.dispose();
  }
}
