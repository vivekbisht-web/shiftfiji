import 'dart:convert';

class Property {
  final String id;
  final String title;
  final double priceFjd;
  final String priceDisplay;
  final String location;
  final String city; // Suva, Nadi, Denarau Island, Coral Coast, Savusavu, Lautoka, Pacific Harbour, Nausori, Labasa
  final String transactionType; // 'Buy', 'Rent', 'Commercial'
  final String propertyType; // 'House', 'Villa', 'Apartment', 'Land', 'Commercial'
  final int bedrooms;
  final int bathrooms;
  final int carSpaces;
  final String landArea; // e.g. "850 sqm", "0.5 Acres"
  final String floorArea; // e.g. "320 sqm"
  final String tenure; // 'Freehold', 'Crown Lease', 'Native Lease (TLTB)', 'State Lease'
  final String tenureDetails;
  final String description;
  final List<String> features;
  final List<String> images;
  final String agentName;
  final String agentPhone;
  final String agentEmail;
  final String agentAgency;
  final String agentAvatar;
  final bool isFeatured;
  final bool isVerified;
  final DateTime dateAdded;

  const Property({
    required this.id,
    required this.title,
    required this.priceFjd,
    required this.priceDisplay,
    required this.location,
    required this.city,
    required this.transactionType,
    required this.propertyType,
    required this.bedrooms,
    required this.bathrooms,
    required this.carSpaces,
    required this.landArea,
    required this.floorArea,
    required this.tenure,
    required this.tenureDetails,
    required this.description,
    required this.features,
    required this.images,
    required this.agentName,
    required this.agentPhone,
    required this.agentEmail,
    required this.agentAgency,
    required this.agentAvatar,
    this.isFeatured = false,
    this.isVerified = true,
    required this.dateAdded,
  });

  String get mainImage => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=800&q=80';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'priceFjd': priceFjd,
      'priceDisplay': priceDisplay,
      'location': location,
      'city': city,
      'transactionType': transactionType,
      'propertyType': propertyType,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'carSpaces': carSpaces,
      'landArea': landArea,
      'floorArea': floorArea,
      'tenure': tenure,
      'tenureDetails': tenureDetails,
      'description': description,
      'features': features,
      'images': images,
      'agentName': agentName,
      'agentPhone': agentPhone,
      'agentEmail': agentEmail,
      'agentAgency': agentAgency,
      'agentAvatar': agentAvatar,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    return Property(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      priceFjd: (map['priceFjd'] as num?)?.toDouble() ?? 0.0,
      priceDisplay: map['priceDisplay'] ?? '',
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      transactionType: map['transactionType'] ?? 'Buy',
      propertyType: map['propertyType'] ?? 'House',
      bedrooms: map['bedrooms']?.toInt() ?? 0,
      bathrooms: map['bathrooms']?.toInt() ?? 0,
      carSpaces: map['carSpaces']?.toInt() ?? 0,
      landArea: map['landArea'] ?? '',
      floorArea: map['floorArea'] ?? '',
      tenure: map['tenure'] ?? 'Freehold',
      tenureDetails: map['tenureDetails'] ?? '',
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      images: List<String>.from(map['images'] ?? []),
      agentName: map['agentName'] ?? '',
      agentPhone: map['agentPhone'] ?? '',
      agentEmail: map['agentEmail'] ?? '',
      agentAgency: map['agentAgency'] ?? '',
      agentAvatar: map['agentAvatar'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      isVerified: map['isVerified'] ?? true,
      dateAdded: map['dateAdded'] != null
          ? DateTime.tryParse(map['dateAdded']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory Property.fromJson(String source) =>
      Property.fromMap(json.decode(source));
}
