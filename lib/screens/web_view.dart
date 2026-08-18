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
  bool hasError = false;

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
                hasError = false;
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
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  hasError = true;
                  isLoading = false;
                });
              }
            }
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

  void retryLoad() {
    setState(() {
      hasError = false;
      isLoading = true;
    });
    controller.reload();
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
              if (!hasError)
                WebViewWidget(
                  controller: controller,
                ),

              // Network error overlay
              if (hasError)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connection Error',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Unable to load Shift Fiji. Please check your internet connection and try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: retryLoad,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Loading overlay
              if (isLoading && !hasError)
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