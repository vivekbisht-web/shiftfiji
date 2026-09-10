# App Store Reviewer Response & Resubmission Guide
**App Name:** Shift Fiji  
**Bundle ID:** (As configured in App Store Connect)  
**Version:** 1.0.0 (Build 2+)  

---

## 📋 Copy-Paste Response for App Store Connect Resolution Center

Paste the following message into the App Store Review Resolution Center message thread:

```text
Dear Apple App Review Team,

Thank you for your feedback regarding Guideline 4.2 (Design - Minimum Functionality) and Guideline 5.1.2(i) (Legal - Privacy - Data Use and Sharing).

We have made comprehensive revisions to the Shift Fiji application to address both guidelines:

========================================================================
1. RESOLUTION TO GUIDELINE 4.2 (MINIMUM FUNCTIONALITY & NATIVE EXPERIENCE)
========================================================================
We have completely redesigned the application from a simple WebView into a rich, Native-First Flutter hybrid application with native device capabilities:

- Native Navigation Architecture: The app now features a 5-tab native iOS navigation bar (Explore, Search & Filters, Financial Tools, Saved Properties, and Settings & Privacy).
- Native Financial & Real Estate Utilities (100% Offline):
  * Fiji Mortgage & Loan Repayment Calculator: Interactive sliders for property purchase price, down payment %, interest rate %, and loan term with real-time monthly repayment breakdown, principal vs. interest ratios, and amortization charts.
  * Fiji Dollar (FJD) Real Estate Currency Converter: Real-time calculation between FJD and major international currencies (AUD, USD, NZD, EUR, GBP, CAD) for overseas investors.
- Native Offline Saved Listings & Notes Vault: Users can save property listings locally on the device (using local storage), attach private inspection notes, and view them even without an active internet connection.
- Native Search & Multi-Criteria Filtering: Filter by transaction type (Buy/Rent/Commercial), Fiji region (Suva, Nadi, Denarau Island, Coral Coast, Lautoka), price brackets, and room counts.
- Native Device Integrations: Integrated native iOS Share sheet (share_plus), native dialer/email launcher for real estate agent inquiries (url_launcher).

========================================================================
2. RESOLUTION TO GUIDELINE 5.1.2(i) (DATA USE, COOKIES & APP TRACKING TRANSPARENCY)
========================================================================
- Implemented AppTrackingTransparency (ATT) Framework:
  * The app now includes the AppTrackingTransparency framework.
  * On app launch, the native ATT permission dialog is displayed with a clear disclosure (NSUserTrackingUsageDescription): "Shift Fiji uses this identifier to deliver personalized property recommendations and measure app performance without sharing your personal data with third-party advertisers."
  * Users can view their current tracking status at any time in the "Settings & Privacy" tab.
- Cookie & Tracking Suppression:
  * If the user chooses "Ask App not to Track", all tracking cookies and analytics scripts (such as Google Analytics / Tag Manager) are programmatically disabled via JavaScript injection.
  * Conflicting web cookie consent popups have been removed/suppressed inside the native iOS application so the experience is seamless and governed entirely by iOS native privacy settings.
- App Privacy in App Store Connect:
  * Our App Privacy details have been updated in App Store Connect to accurately disclose data collection practices.

Review Account / Demo Credentials:
The app does not require a login to access native tools, search, calculators, or saved listings. 

Thank you for your review. Please let us know if any further information is needed.

Best regards,
The Shift Fiji Development Team
```

---

## 🛠️ App Store Connect Configuration Checklist

### 1. App Privacy Questionnaire in App Store Connect
When editing your App Privacy in App Store Connect:
1. Go to **App Store Connect** > **Apps** > **Shift Fiji** > **App Privacy**.
2. **Identifiers / Usage Data**:
   - If you collect Device ID / Analytics for app performance: Select **"Data Used to Track You"** if linked across apps, or disclose **"Product Interaction" / "Analytics"** not used for tracking.
   - If user denies ATT: The app automatically suppresses third-party tracking scripts.
3. **Location / Contact Info**: Only collected if user submits an inquiry form.

### 2. Review Notes in App Store Connect (Version Info)
In the **Version Information** > **Review Notes** section:
- Mention: *"The AppTrackingTransparency (ATT) dialog is triggered automatically on first launch upon app initialization and can also be verified under the Settings & Privacy tab."*

---

## 📱 Summary of Native Code Changes in this Build

| Feature | Description | File |
| :--- | :--- | :--- |
| **Main Navigation** | 5-Tab Native Navigation Bar (IndexedStack) | `lib/screens/main_shell_screen.dart` |
| **Explore Hub** | Fiji categories, top regions, quick tools | `lib/screens/explore_tab.dart` |
| **Search & Filters** | Suburb, price slider, bed/bath criteria | `lib/screens/search_tab.dart` |
| **Mortgage Calculator** | 100% offline loan repayment & cost estimator | `lib/screens/tools_tab.dart` |
| **Currency Converter** | FJD to AUD/USD/NZD/EUR converter | `lib/screens/tools_tab.dart` |
| **Saved Properties Vault** | Offline saved listings, inspection notes, share | `lib/screens/saved_tab.dart` |
| **Privacy & Settings** | ATT status, cache clearing, legal links | `lib/screens/settings_tab.dart` |
| **ATT Framework** | iOS Tracking Permission & Cookie suppression | `lib/services/tracking_service.dart` |
| **Info.plist** | `NSUserTrackingUsageDescription` added | `ios/Runner/Info.plist` |
