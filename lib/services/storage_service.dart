import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shiftfiji/models/property.dart';
import 'package:shiftfiji/models/saved_property.dart';
import 'package:shiftfiji/services/property_service.dart';

class StorageService {
  static const String _savedPropertiesKey = 'sf_saved_properties_v2';
  static const String _recentSearchesKey = 'sf_recent_searches_v2';
  static const String _preferredCurrencyKey = 'sf_preferred_currency_v2';
  static const String _comparePropertiesKey = 'sf_compare_properties_v2';
  static const String _recentlyViewedKey = 'sf_recently_viewed_v2';

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

  static Future<bool> savePropertyFromModel(Property property, {String notes = ''}) async {
    final saved = SavedProperty(
      id: property.id,
      title: property.title,
      price: property.priceDisplay,
      location: property.location,
      type: property.transactionType,
      imageUrl: property.mainImage,
      url: 'https://shiftfiji.com/properties/${property.id}',
      notes: notes,
      savedAt: DateTime.now(),
    );
    return await saveProperty(saved);
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

  static Future<bool> togglePropertySaved(Property property) async {
    if (isPropertySaved(property.id)) {
      return await removeProperty(property.id);
    } else {
      return await savePropertyFromModel(property);
    }
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

  // --- Property Comparison Matrix (Up to 3 properties) ---
  static List<String> getComparisonIds() {
    return prefs.getStringList(_comparePropertiesKey) ?? [];
  }

  static List<Property> getComparisonProperties() {
    final ids = getComparisonIds();
    return ids.map((id) => PropertyService.getById(id)).whereType<Property>().toList();
  }

  static Future<bool> toggleComparison(String propertyId) async {
    final list = getComparisonIds();
    if (list.contains(propertyId)) {
      list.remove(propertyId);
    } else {
      if (list.length >= 3) {
        list.removeAt(0); // keep max 3
      }
      list.add(propertyId);
    }
    return await prefs.setStringList(_comparePropertiesKey, list);
  }

  static bool isInComparison(String propertyId) {
    return getComparisonIds().contains(propertyId);
  }

  static Future<bool> clearComparison() async {
    return await prefs.remove(_comparePropertiesKey);
  }

  // --- Recently Viewed ---
  static List<Property> getRecentlyViewed() {
    final ids = prefs.getStringList(_recentlyViewedKey) ?? [];
    return ids.map((id) => PropertyService.getById(id)).whereType<Property>().toList();
  }

  static Future<void> trackRecentlyViewed(String propertyId) async {
    final list = prefs.getStringList(_recentlyViewedKey) ?? [];
    list.remove(propertyId);
    list.insert(0, propertyId);
    if (list.length > 10) list.removeLast();
    await prefs.setStringList(_recentlyViewedKey, list);
  }

  // --- Recent Searches ---
  static List<String> getRecentSearches() {
    return prefs.getStringList(_recentSearchesKey) ?? [
      'Denarau Island Luxury Villas',
      'Suva Domain Ocean View',
      'Coral Coast Freehold Land',
      'Fantasy Island Nadi Canal Home',
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

  static Future<void> clearRecentSearches() async {
    await prefs.remove(_recentSearchesKey);
  }

  // --- Preferred Currency ---
  static String getPreferredCurrency() {
    return prefs.getString(_preferredCurrencyKey) ?? 'FJD';
  }

  static Future<void> setPreferredCurrency(String currency) async {
    await prefs.setString(_preferredCurrencyKey, currency);
  }

  // --- Initial Curated Properties Pre-population ---
  static Future<void> _prepopulateCuratedProperties() async {
    final initial = [
      SavedProperty(
        id: 'prop-denarau-01',
        title: 'Luxury Beachfront Villa - Denarau Island',
        price: 'FJD \$2,450,000',
        location: 'Denarau Island, Nadi, Fiji',
        type: 'Buy',
        imageUrl: 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80',
        url: 'https://shiftfiji.com/properties/prop-denarau-01',
        notes: 'Exclusive gated marina villa with private berth.',
        savedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      SavedProperty(
        id: 'prop-coral-03',
        title: 'Freehold Coastal Development Land - 2.5 Acres',
        price: 'FJD \$890,000',
        location: 'Korotogo, Coral Coast, Sigatoka, Fiji',
        type: 'Buy',
        imageUrl: 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=800&q=80',
        url: 'https://shiftfiji.com/properties/prop-coral-03',
        notes: '100% Freehold title with elevated 180-degree ocean views.',
        savedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    final jsonList = initial.map((p) => p.toJson()).toList();
    await prefs.setStringList(_savedPropertiesKey, jsonList);
  }
}
