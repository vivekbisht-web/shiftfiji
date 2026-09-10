import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TrackingService {
  static const String _prefTrackingRequestedKey = 'att_requested_v1';
  static const String _prefTrackingAllowedKey = 'att_allowed_v1';

  static TrackingStatus _currentStatus = TrackingStatus.notDetermined;

  static TrackingStatus get currentStatus => _currentStatus;
  static bool get isTrackingAuthorized =>
      _currentStatus == TrackingStatus.authorized;

  /// Request ATT authorization if on iOS and not yet determined
  static Future<void> initTracking() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (!kIsWeb && Platform.isIOS) {
        final status =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        _currentStatus = status;

        if (status == TrackingStatus.notDetermined) {
          // Wait a slight delay for the UI to be presented
          await Future.delayed(const Duration(milliseconds: 600));
          final requestedStatus =
              await AppTrackingTransparency.requestTrackingAuthorization();
          _currentStatus = requestedStatus;
          await prefs.setBool(_prefTrackingRequestedKey, true);
          await prefs.setBool(
            _prefTrackingAllowedKey,
            requestedStatus == TrackingStatus.authorized,
          );
        } else {
          await prefs.setBool(
            _prefTrackingAllowedKey,
            status == TrackingStatus.authorized,
          );
        }
      } else {
        // Non-iOS platforms
        _currentStatus = TrackingStatus.notSupported;
      }
    } catch (e) {
      debugPrint('Error initializing ATT: $e');
      _currentStatus = TrackingStatus.notSupported;
    }
  }

  /// Get human-readable description of current tracking authorization status
  static String getStatusDescription() {
    switch (_currentStatus) {
      case TrackingStatus.authorized:
        return 'Allowed (Personalized Experience)';
      case TrackingStatus.denied:
        return 'Declined (Standard Experience)';
      case TrackingStatus.restricted:
        return 'Restricted by Device Settings';
      case TrackingStatus.notDetermined:
        return 'Not Determined';
      case TrackingStatus.notSupported:
        return 'Standard Protection';
    }
  }

  /// JavaScript snippet to inject into the WebView to:
  /// 1. Suppress redundant web cookie consent banners inside the iOS app
  /// 2. If user denied ATT tracking, disable web analytics / tracking cookies
  static String getWebViewOptimizationScript() {
    final allowTracking = isTrackingAuthorized;

    return '''
      (function() {
        try {
          // 1. Suppress cookie consent banners / redundant popups inside the native app
          const style = document.createElement('style');
          style.innerHTML = `
            .cookie-banner, #cookie-consent, .cookie-notice, .cc-banner, 
            .iziToast-wrapper, .cookie-alert, .cookie-popup,
            #gdpr-cookie-message, .alert-cookie {
              display: none !important;
              visibility: hidden !important;
              opacity: 0 !important;
              pointer-events: none !important;
            }
          `;
          document.head.appendChild(style);

          // 2. Comply with ATT user tracking preference for analytics
          ${!allowTracking ? '''
            // Disable Google Analytics & Tag Manager tracking when user declined ATT
            window['ga-disable-G-7LKC3P7TXR'] = true;
            if (window.dataLayer) {
              window.dataLayer.push({'event': 'opt_out_tracking'});
            }
          ''' : ''}

          console.log('[ShiftFiji Native] ATT compliance script applied. Tracking allowed: $allowTracking');
        } catch (e) {
          console.error('[ShiftFiji Native] Script injection error:', e);
        }
      })();
    ''';
  }
}
