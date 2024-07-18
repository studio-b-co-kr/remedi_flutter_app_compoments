import 'dart:developer' as dev;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:remedi_base/remedi_base.dart';
import 'package:remedi_engage/remedi_engage.dart';

const AndroidNotificationChannelWrapperList channels =
    AndroidNotificationChannelWrapperList(
        defaultChannelId: 'high_importance_channel',
        defaultChannelTitle: 'High Importance Notifications',
        defaultChannelBody: 'This channel is used for important notifications.',
        channels: [
      AndroidNotificationChannelWrapper(
          channel: AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        // 'This channel is used for important notifications.', // description
        importance: Importance.high,
      ))
    ]);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  await FcmManager.init(
      onBackgroundMessage: (RemoteMessage message) async {
        await Firebase.initializeApp();
        dev.log('Handling a background message${message.messageId}');
      },
      channels: channels);

  runApp(AppWrapper(
    app: MaterialApp(home: MyHomePage()),
    initialJobs: [
      () =>
          FcmManager.handleInitialMessage(handler: (RemoteMessage message) {}),
      () => FcmManager.handleOnMessage(channels: channels),
      () => FcmManager.handleOnMessageOpenedApp(
          handler: (RemoteMessage message) {})
    ],
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
