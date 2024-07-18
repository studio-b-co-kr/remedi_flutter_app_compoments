import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:remedi_net_new/remedi_net.dart';

void main() {
  group('Test restful api', () {
    test('Fetch Success Method Test', () async {
      TestApiService testApiService = TestApiService();
      final dioAdapter = DioAdapter(dio: testApiService.dio);

      dioAdapter.onGet("", (server) {
        server.reply(200, {'message': 'Success!'});
      });

      var ret = await testApiService.get();
      expect(ret is TestResponse, true);
      expect(ret.message, 'Success!');
    });

    test('Fetch Error Method Test', () async {
      TestApiService testApiService = TestApiService();
      final dioAdapter = DioAdapter(dio: testApiService.dio);

      dioAdapter.onGet("", (server) {
        server.reply(400, {'message': 'Success!'});
      });

      var ret = await testApiService.get();
      expect(ret is HttpError, true);
    });
  });
}

class TestApiService extends ApiService<TestResponse> {
  TestApiService()
      : super(
            request: DioRequest(
                builder: DioBuilder.json(baseUrl: 'http://test.com')));

  get() async {
    return await requestGet();
  }

  @override
  TestResponse? onSuccess({int? statusCode, dynamic json}) {
    return TestResponse.fromJson(json);
  }
}

class TestResponse extends IDto {
  final String message;

  TestResponse({
    required this.message,
  });

  factory TestResponse.fromJson(json) {
    return TestResponse(message: json['message']);
  }

  @override
  Map<String, dynamic> get toJson => {
        'message': message,
      };
}
