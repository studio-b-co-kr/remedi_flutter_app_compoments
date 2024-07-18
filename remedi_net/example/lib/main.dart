import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:remedi_net_new/remedi_net.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: const Text("TEST"),
      ),
      body: FutureBuilder(
        future: getGoogle(),
        builder: (context, snapshot) => Center(
          child: Text(
            '${(snapshot.data is GoogleData) ? (snapshot.data as GoogleData).toJson : ""}',
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<dynamic> getGoogle() async {
    var ret = await GoogleApiService().get();
    dev.log("$ret", name: 'getGoogle');
    return ret;
  }
}

class GoogleApiService extends ApiService<GoogleData> {
  GoogleApiService()
      : super(
          request: DioRequest(
            builder: DioBuilder.json(
              baseUrl: 'https://www.googleapis.com',
            ),
          ),
        );

  get() async {
    return requestGet(path: '/books/v1/volumes', queries: {'q': '{http}'});
  }

  @override
  GoogleData? onSuccess({int? statusCode, dynamic json}) {
    return GoogleData.fromJson(json);
  }

  @override
  HttpError onError(HttpError error) {
    // TODO: customize error data.
    return super.onError(error);
  }
}

class GoogleData extends IDto {
  GoogleData();

  static GoogleData? fromJson(json) {
    return GoogleData();
  }

  @override
  get toJson => "";
}
