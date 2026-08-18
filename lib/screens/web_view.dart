import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  double progress = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) {
              setState(() {
                progress = value / 100;
              });
            }
          },
          onPageStarted: (url) {
            debugPrint('Started: $url');
          },
          onPageFinished: (url) {
            debugPrint('Finished: $url');
          },
          onWebResourceError: (error) {
            debugPrint(
              'WebView Error: ${error.description}',
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse('https://shiftfiji.com/home'),
      );
  }

  Future<bool> handleBack() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldExit = await handleBack();

        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              WebViewWidget(
                controller: controller,
              ),

              if (progress < 1.0)
                LinearProgressIndicator(
                  value: progress,
                ),
            ],
          ),
        ),
      ),
    );
  }
}