import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('Started: $url');

            if (mounted) {
              setState(() {
                isLoading = true;
              });
            }
          },

          onPageFinished: (url) {
            debugPrint('Finished: $url');

            if (mounted) {
              setState(() {
                isLoading = false;
              });
            }
          },

          onWebResourceError: (error) {
            debugPrint('''
================ WEBVIEW ERROR ================
Error Code: ${error.errorCode}
Description: ${error.description}
URL: ${error.url}
Error Type: ${error.errorType}
===============================================
''');
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
              // Website
              WebViewWidget(
                controller: controller,
              ),

              // Loading overlay
              if (isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}