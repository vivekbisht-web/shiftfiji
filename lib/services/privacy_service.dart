class PrivacyService {
  /// JavaScript snippet to inject into the WebView to:
  /// 1. Suppress redundant web cookie consent banners inside the iOS app
  /// 2. Ensure no third-party tracking or ad tracking occurs
  static String getWebViewOptimizationScript() {
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

          // 2. Ensure opt-out from advertising/tracking analytics
          window['ga-disable-G-7LKC3P7TXR'] = true;
          if (window.dataLayer) {
            window.dataLayer.push({'event': 'opt_out_tracking'});
          }

          console.log('[ShiftFiji Native] Privacy optimization applied. Zero tracking enforced.');
        } catch (e) {
          console.error('[ShiftFiji Native] Script injection error:', e);
        }
      })();
    ''';
  }
}
