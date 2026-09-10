import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftfiji/models/saved_property.dart';

class StorageService {
  static const String _savedPropertiesKey = 'sf_saved_properties_v1';
  static const String _recentSearchesKey = 'sf_recent_searches_v1';
  static const String _preferredCurrencyKey = 'sf_preferred_currency_v1';

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    // Pre-populate with curated featured Fiji listings if empty
    final existing = getSavedProperties();
    if (existing.isEmpty) {
      await _prepopulateCuratedProperties();
    }
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService must be initialized before use.');
    }
    return _prefs!;
  }

  // --- Saved Properties ---
  static List<SavedProperty> getSavedProperties() {
    try {
      final jsonList = prefs.getStringList(_savedPropertiesKey) ?? [];
      return jsonList.map((item) => SavedProperty.fromJson(item)).toList();
    } catch (e) {
      debugPrint('Error loading saved properties: $e');
      return [];
    }
  }

  static Future<bool> saveProperty(SavedProperty property) async {
    try {
      final list = getSavedProperties();
      final index = list.indexWhere((p) => p.id == property.id || (p.url.isNotEmpty && p.url == property.url));
      if (index >= 0) {
        list[index] = property;
      } else {
        list.insert(0, property);
      }
      final jsonList = list.map((p) => p.toJson()).toList();
      return await prefs.setStringList(_savedPropertiesKey, jsonList);
    } catch (e) {
      debugPrint('Error saving property: $e');
      return false;
    }
  }

  static Future<bool> removeProperty(String id) async {
    try {
      final list = getSavedProperties();
      list.removeWhere((p) => p.id == id);
      final jsonList = list.map((p) => p.toJson()).toList();
      return await prefs.setStringList(_savedPropertiesKey, jsonList);
    } catch (e) {
      debugPrint('Error removing property: $e');
      return false;
    }
  }

  static bool isPropertySaved(String id, {String? url}) {
    final list = getSavedProperties();
    return list.any((p) => p.id == id || (url != null && url.isNotEmpty && p.url == url));
  }

  static Future<bool> updatePropertyNotes(String id, String notes) async {
    final list = getSavedProperties();
    final index = list.indexWhere((p) => p.id == id);
    if (index >= 0) {
      list[index] = list[index].copyWith(notes: notes);
      final jsonList = list.map((p) => p.toJson()).toList();
      return await prefs.setStringList(_savedPropertiesKey, jsonList);
    }
    return false;
  }

  // --- Recent Searches ---
  static List<String> getRecentSearches() {
    return prefs.getStringList(_recentSearchesKey) ?? [
      'Suva Waterfront Apartments',
      'Denarau Island Luxury Villas',
      'Nadi Airport Commercial Space',
      'Coral Coast Freehold Land',
    ];
  }

  static Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final list = getRecentSearches();
    list.remove(query);
    list.insert(0, query);
    if (list.length > 10) list.removeLast();
    await prefs.setStringList(_recentSearchesKey, list);
  }

  // --- Preferred Currency ---
  static String getPreferredCurrency() {
    return prefs.getString(_preferredCurrencyKey) ?? 'FJD';
  }

  static Future<void> setPreferredCurrency(String currency) async {
    await prefs.setString(_preferredCurrencyKey, currency);
  }

  // --- Initial Curated Properties for Fiji Offline Showcase ---
  static Future<void> _prepopulateCuratedProperties() async {
    final initial = [
      SavedProperty(
        id: 'prop-denarau-01',
        title: 'Luxury Beachfront Villa - Denarau Island',
        price: 'FJD \$2,450,000',
        location: 'Denarau Island, Nadi, Fiji',
        type: 'Buy',
        imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
        url: 'https://shiftfiji.com/properties',
        notes: 'Exclusive gated community with private marina berth.',
        savedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SavedProperty(
        id: 'prop-suva-02',
        title: 'Modern Executive Penthouse with Ocean Views',
        price: 'FJD \$4,500 / month',
        location: 'Domain, Suva, Fiji',
        type: 'Rent',
        imageUrl: 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=800&q=80',
        url: 'https://shiftfiji.com/properties',
        notes: 'Fully furnished, 24/7 security and swimming pool.',
        savedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      SavedProperty(
        id: 'prop-coral-03',
        title: 'Freehold Coastal Development Land',
        price: 'FJD \$890,000',
        location: 'Coral Coast, Sigatoka, Fiji',
        type: 'Buy',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
        url: 'https://shiftfiji.com/properties',
        notes: 'Ideal for boutique eco-resort or private retreat.',
        savedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];

    final jsonList = initial.map((p) => p.toJson()).toList();
    await prefs.setStringList(_savedPropertiesKey, jsonList);
  }
}
