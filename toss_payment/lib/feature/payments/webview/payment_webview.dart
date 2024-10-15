import 'dart:io';

import 'package:flutter/material.dart';
import 'package:toss_payment/extensions/uri_extension.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 토스 결제가 진행되는 웹뷰입니다.
class PaymentWebView extends StatefulWidget {
  /// 결제창의 타이틀
  final String? title;

  /// 실제 결제가 진행되는 웹페이지 URL
  final Uri paymentRequestUrl;

  /// 웹뷰 콜백 onPageStarted
  final Function(String url)? onPageStarted;

  /// 웹뷰 콜백 onPageFinished
  final Function(String url)? onPageFinished;

  /// 결제창이 dispose 될 때 콜백
  final Function()? onDisposed;

  /// 닫힘 버튼을 탭했을 때 콜백
  final Function()? onTapCloseButton;

  const PaymentWebView({
    Key? key,
    this.title,
    this.onPageStarted,
    this.onPageFinished,
    this.onDisposed,
    this.onTapCloseButton,
    required this.paymentRequestUrl,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    _initWebView();
    super.initState();
  }

  _initWebView() {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (url) {
            widget.onPageStarted;
            debugPrint('🔴 Started loading: ${Uri.decodeFull(url)}');
          },
          onPageFinished: (url) {
            widget.onPageFinished;
            debugPrint('🔴 Finished loading: ${Uri.decodeFull(url)}');
          },
          onNavigationRequest: (NavigationRequest request) {
            Uri uri = Uri.parse(request.url);
            // url 이 웹뷰에 유효하다면 해당 url 로 이동한다.
            if (uri.scheme == 'http' ||
                uri.scheme == 'https' ||
                uri.scheme == 'about') {
              return NavigationDecision.navigate;
            }

            // url 이 웹뷰에 유효하지 않다면 해당 url 로 이동하지 않는다.
            debugPrint(
                '✅ allowing navigation to ${Uri.decodeFull(request.url)}');

            String launchUrl = request.url;

            if (Platform.isAndroid) {
              Uri tossPayment =
                  UriExtension.androidIntentUrlOrigin(request.url);
              launchUrl = tossPayment.toString();
            }

            launchUrlString(launchUrl);

            debugPrint(
                '❌ blocking navigation to ${Uri.decodeFull(request.url)}');
            return NavigationDecision.prevent;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..enableZoom(false)
      ..loadRequest(widget.paymentRequestUrl);

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          widget.title ?? "",
          style: TextStyle(color: Colors.indigo.shade50),
        ),
        backgroundColor: Colors.indigo,
        elevation: 0,
        actions: [
          InkWell(
            onTap: widget.onTapCloseButton,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Icon(
                Icons.close,
                color: Colors.indigo.shade50,
              ),
            ),
          )
        ],
      ),
      body: WebViewWidget(
        controller: _controller,
      ),
    );
  }

  @override
  void dispose() {
    if (widget.onDisposed != null) {
      widget.onDisposed!();
    }
    super.dispose();
  }
}
