import 'dart:convert';

class SavedProperty {
  final String id;
  final String title;
  final String price;
  final String location;
  final String type; // Buy, Rent, Commercial, Land
  final String? imageUrl;
  final String url;
  final String notes;
  final DateTime savedAt;

  SavedProperty({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.type,
    this.imageUrl,
    required this.url,
    this.notes = '',
    required this.savedAt,
  });

  SavedProperty copyWith({
    String? id,
    String? title,
    String? price,
    String? location,
    String? type,
    String? imageUrl,
    String? url,
    String? notes,
    DateTime? savedAt,
  }) {
    return SavedProperty(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      location: location ?? this.location,
      type: type ?? this.type,
      imageUrl: imageUrl ?? this.imageUrl,
      url: url ?? this.url,
      notes: notes ?? this.notes,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'location': location,
      'type': type,
      'imageUrl': imageUrl,
      'url': url,
      'notes': notes,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedProperty.fromMap(Map<String, dynamic> map) {
    return SavedProperty(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      price: map['price'] ?? '',
      location: map['location'] ?? '',
      type: map['type'] ?? 'Buy',
      imageUrl: map['imageUrl'],
      url: map['url'] ?? '',
      notes: map['notes'] ?? '',
      savedAt: map['savedAt'] != null
          ? DateTime.tryParse(map['savedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory SavedProperty.fromJson(String source) =>
      SavedProperty.fromMap(json.decode(source));
}
