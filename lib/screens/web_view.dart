import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/services/privacy_service.dart';

class SmartWebViewScreen extends StatefulWidget {
  final String initialUrl;
  final String title;
  final bool showAppBar;

  const SmartWebViewScreen({
    super.key,
    this.initialUrl = 'https://shiftfiji.com/home',
    this.title = 'Shift Fiji Portal',
    this.showAppBar = true,
  });

  @override
  State<SmartWebViewScreen> createState() => _SmartWebViewScreenState();
}

class _SmartWebViewScreenState extends State<SmartWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  bool _hasError = false;
  String _currentUrl = '';
  String _pageTitle = '';
  bool _canGoBack = false;
  bool _canGoForward = false;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.initialUrl;
    _pageTitle = widget.title;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('ShiftFiji-iOS-NativeApp/1.0.0 (Apple iOS; Hybrid)')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('[WebView] Started: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
                _currentUrl = url;
              });
            }
          },
          onProgress: (progress) {
            if (mounted) {
              setState(() {
                _loadingProgress = progress / 100.0;
              });
            }
          },
          onPageFinished: (url) async {
            debugPrint('[WebView] Finished: $url');
            // Inject cookie banner suppression and privacy script
            await _controller.runJavaScript(
              PrivacyService.getWebViewOptimizationScript(),
            );

            final canBack = await _controller.canGoBack();
            final canFwd = await _controller.canGoForward();
            final docTitle = await _controller.getTitle();

            if (mounted) {
              setState(() {
                _isLoading = false;
                _canGoBack = canBack;
                _canGoForward = canFwd;
                if (docTitle != null && docTitle.isNotEmpty && !docTitle.contains('404')) {
                  _pageTitle = docTitle;
                }
              });
            }
          },
          onWebResourceError: (error) {
            debugPrint('''
============ WEBVIEW ERROR ============
Error Code: ${error.errorCode}
Description: ${error.description}
URL: ${error.url}
=======================================
''');
            if (error.isForMainFrame ?? true) {
              if (mounted) {
                setState(() {
                  _hasError = true;
                  _isLoading = false;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _updateNavState() async {
    final canBack = await _controller.canGoBack();
    final canFwd = await _controller.canGoForward();
    if (mounted) {
      setState(() {
        _canGoBack = canBack;
        _canGoForward = canFwd;
      });
    }
  }

  void _reload() {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    _controller.reload();
  }

  Future<void> _shareCurrentPage() async {
    final url = _currentUrl.isNotEmpty ? _currentUrl : widget.initialUrl;
    await Share.share(
      'Check out this listing on Shift Fiji: $url',
      subject: 'Shift Fiji Real Estate',
    );
  }

  Future<void> _openInExternalBrowser() async {
    final uri = Uri.parse(_currentUrl.isNotEmpty ? _currentUrl : widget.initialUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_canGoBack) {
          await _controller.goBack();
          await _updateNavState();
        } else if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: widget.showAppBar
            ? AppBar(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                titleSpacing: 0,
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pageTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _currentUrl.replaceAll('https://', ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: _canGoBack ? Colors.white : Colors.white24,
                    ),
                    tooltip: 'Back',
                    onPressed: _canGoBack
                        ? () async {
                            await _controller.goBack();
                            await _updateNavState();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: _canGoForward ? Colors.white : Colors.white24,
                    ),
                    tooltip: 'Forward',
                    onPressed: _canGoForward
                        ? () async {
                            await _controller.goForward();
                            await _updateNavState();
                          }
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_rounded, size: 20),
                    tooltip: 'Share',
                    onPressed: _shareCurrentPage,
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded),
                    onSelected: (value) {
                      if (value == 'reload') {
                        _reload();
                      } else if (value == 'browser') {
                        _openInExternalBrowser();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'reload',
                        child: Row(
                          children: [
                            Icon(Icons.refresh_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Reload Page'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'browser',
                        child: Row(
                          children: [
                            Icon(Icons.open_in_browser_rounded, size: 18),
                            SizedBox(width: 10),
                            Text('Open in Safari / Browser'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
                bottom: _isLoading
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(3),
                        child: LinearProgressIndicator(
                          value: _loadingProgress > 0 ? _loadingProgress : null,
                          backgroundColor: AppColors.primaryLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                          minHeight: 3,
                        ),
                      )
                    : null,
              )
            : null,
        body: SafeArea(
          top: !widget.showAppBar,
          child: Stack(
            children: [
              // WebView component
              if (!_hasError)
                WebViewWidget(
                  controller: _controller,
                ),

              // Network error overlay
              if (_hasError)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(28.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.wifi_off_rounded,
                            size: 48,
                            color: AppColors.error,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Connection Unavailable',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Unable to connect to Shift Fiji live portal. Please verify your internet connection or browse your saved offline listings.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _reload,
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}