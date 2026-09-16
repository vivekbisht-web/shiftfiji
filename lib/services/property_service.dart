import 'package:shiftfiji/models/property.dart';

class PropertyService {
  static final List<Property> _allProperties = [
    Property(
      id: 'prop-denarau-01',
      title: 'Luxury Beachfront Villa - Denarau Island',
      priceFjd: 2450000,
      priceDisplay: 'FJD \$2,450,000',
      location: 'Denarau Island, Nadi, Fiji',
      city: 'Denarau Island',
      transactionType: 'Buy',
      propertyType: 'Villa',
      bedrooms: 4,
      bathrooms: 4,
      carSpaces: 2,
      landArea: '1,120 sqm',
      floorArea: '480 sqm',
      tenure: 'Crown Lease',
      tenureDetails: '99-year Crown Lease (84 years remaining), Gated Denarau Precinct.',
      description:
          'Experience the pinnacle of tropical island living in this prestigious Denarau Island waterfront residence. Boasting private marina berth access, an infinity-edge swimming pool overlooking the lagoon, expansive covered entertainer verandas, gourmet chef kitchen with European appliances, and four master ensuite sanctuaries.',
      features: [
        'Private Marina Berth',
        'Lagoon Frontage',
        'Infinity Swimming Pool',
        '24/7 Gated Security',
        'Solar Power System',
        'Air Conditioning throughout',
        'Fully Furnished Designer Decor',
        'Landscaped Tropical Gardens',
      ],
      images: [
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Seru Nabalarua',
      agentPhone: '+679 999 1234',
      agentEmail: 'seru@shiftfiji.com',
      agentAgency: 'Pacific Island Luxury Real Estate',
      agentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      isFeatured: true,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Property(
      id: 'prop-suva-02',
      title: 'Modern Executive Penthouse with Panoramic Ocean Views',
      priceFjd: 4500,
      priceDisplay: 'FJD \$4,500 / month',
      location: 'Domain Road, Suva, Fiji',
      city: 'Suva',
      transactionType: 'Rent',
      propertyType: 'Apartment',
      bedrooms: 3,
      bathrooms: 3,
      carSpaces: 2,
      landArea: 'N/A (Penthouse)',
      floorArea: '260 sqm',
      tenure: 'Freehold Strata Title',
      tenureDetails: 'Freehold Strata Title with Body Corporate management.',
      description:
          'Spectacular executive penthouse situated in the prestigious Domain embassy belt of Suva. Features wrap-around balconies with uninterrupted views across Suva Harbour and Laucala Bay. Includes backup generator, swimming pool, on-site gym, and biometric security.',
      features: [
        'Panoramic Ocean & Harbour Views',
        '24/7 Monitored Security',
        'Swimming Pool & Gym',
        'Backup Generator & Water Tanks',
        'Walk-in Wardrobes',
        'High-speed Fiber Ready',
      ],
      images: [
        'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Priya Sharma',
      agentPhone: '+679 922 5678',
      agentEmail: 'priya@shiftfiji.com',
      agentAgency: 'Suva Prime Properties',
      agentAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      isFeatured: true,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Property(
      id: 'prop-coral-03',
      title: 'Freehold Coastal Development Land - 2.5 Acres',
      priceFjd: 890000,
      priceDisplay: 'FJD \$890,000',
      location: 'Korotogo, Coral Coast, Sigatoka, Fiji',
      city: 'Coral Coast',
      transactionType: 'Buy',
      propertyType: 'Land',
      bedrooms: 0,
      bathrooms: 0,
      carSpaces: 0,
      landArea: '2.5 Acres (10,117 sqm)',
      floorArea: 'Vacant Land',
      tenure: 'Freehold',
      tenureDetails: '100% Freehold Title (No land rent, can be purchased by foreign nationals subject to standard consent).',
      description:
          'Rare freehold parcel nestled on the celebrated Coral Coast. Elevated gentle gradient offering 180-degree Pacific Ocean vistas and easy beach access. Ideal for a private eco-resort, wellness retreat, or subdivisional residential estate.',
      features: [
        'Rare Pure Freehold Title',
        'Direct Queens Highway Access',
        'Mains Power & Water Available at Boundary',
        'Elevated Ocean Views',
        'Minutes to 5-Star Resorts & Diving',
      ],
      images: [
        'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'David Robinson',
      agentPhone: '+679 944 8899',
      agentEmail: 'david@shiftfiji.com',
      agentAgency: 'Coral Coast Realty Fiji',
      agentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      isFeatured: true,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Property(
      id: 'prop-nadi-04',
      title: 'Modern 4-Bedroom Family Home with Pool in Fantasy Island',
      priceFjd: 1150000,
      priceDisplay: 'FJD \$1,150,000',
      location: 'Fantasy Island, Nadi, Fiji',
      city: 'Nadi',
      transactionType: 'Buy',
      propertyType: 'House',
      bedrooms: 4,
      bathrooms: 3,
      carSpaces: 2,
      landArea: '750 sqm',
      floorArea: '310 sqm',
      tenure: 'Crown Lease',
      tenureDetails: '99-year Crown Lease (91 years remaining).',
      description:
          'Brand new contemporary waterfront canal home in Fantasy Island, Nadi. Boasts open-concept living, custom mahogany cabinetry, plunge pool, outdoor BBQ kitchen, and direct canal boat mooring facilities.',
      features: [
        'Canal Mooring Jetty',
        'Private Swimming Pool',
        'Air Conditioned Bedrooms',
        'Modern Kitchen with Stone Countertops',
        'Covered Double Carport',
        '10 mins to Nadi International Airport',
      ],
      images: [
        'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600585154526-990dced4db0d?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Seru Nabalarua',
      agentPhone: '+679 999 1234',
      agentEmail: 'seru@shiftfiji.com',
      agentAgency: 'Pacific Island Luxury Real Estate',
      agentAvatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=200&q=80',
      isFeatured: false,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Property(
      id: 'prop-pacific-05',
      title: 'Golf Course Villa with Private Mooring Berth',
      priceFjd: 680000,
      priceDisplay: 'FJD \$680,000',
      location: 'Pacific Harbour, Deuba, Fiji',
      city: 'Pacific Harbour',
      transactionType: 'Buy',
      propertyType: 'Villa',
      bedrooms: 3,
      bathrooms: 2,
      carSpaces: 1,
      landArea: '920 sqm',
      floorArea: '220 sqm',
      tenure: 'Freehold',
      tenureDetails: 'Freehold Title in established residential golf precinct.',
      description:
          'Charming Pacific Harbour retreat bordering the world-renowned championship golf course. Features high vaulted timber ceilings, freshwater swimming pool, tropical landscaping, and riverfront mooring for game-fishing boats.',
      features: [
        'Golf Course Frontage',
        'Riverfront Mooring',
        'Private Swimming Pool',
        'Freehold Ownership',
        'Close to Arts Village & Marina',
      ],
      images: [
        'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1513694203232-719a280e022f?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Alipate Vula',
      agentPhone: '+679 933 1122',
      agentEmail: 'alipate@shiftfiji.com',
      agentAgency: 'Deuba Coastline Properties',
      agentAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      isFeatured: false,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Property(
      id: 'prop-savusavu-06',
      title: 'Tropical Sanctuary & Organic Plantation Estate',
      priceFjd: 1750000,
      priceDisplay: 'FJD \$1,750,000',
      location: 'Lesiaceva Point, Savusavu, Vanua Levu, Fiji',
      city: 'Savusavu',
      transactionType: 'Buy',
      propertyType: 'Villa',
      bedrooms: 5,
      bathrooms: 4,
      carSpaces: 3,
      landArea: '5.2 Acres',
      floorArea: '420 sqm',
      tenure: 'Freehold',
      tenureDetails: 'Rare Freehold Island Estate on Vanua Levu.',
      description:
          'Spectacular oceanfront estate overlooking Savusavu Bay. Comprises a master lodge and two detached private guest bures surrounded by organic coconut, citrus, and vanilla orchards. Fully off-grid capable with advanced solar and rainwater collection.',
      features: [
        'Pure Freehold Oceanfront',
        'Off-grid Solar & Hydro Capable',
        'Private Beach Access',
        'Guest Bures for Boutique Tourism',
        'Deep Water Anchorage',
      ],
      images: [
        'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'David Robinson',
      agentPhone: '+679 944 8899',
      agentEmail: 'david@shiftfiji.com',
      agentAgency: 'Coral Coast Realty Fiji',
      agentAvatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=200&q=80',
      isFeatured: true,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Property(
      id: 'prop-lautoka-07',
      title: 'Prime Commercial Warehouse & Office Complex',
      priceFjd: 1850000,
      priceDisplay: 'FJD \$1,850,000',
      location: 'Navutu Industrial Zone, Lautoka, Fiji',
      city: 'Lautoka',
      transactionType: 'Commercial',
      propertyType: 'Commercial',
      bedrooms: 0,
      bathrooms: 4,
      carSpaces: 10,
      landArea: '1,800 sqm',
      floorArea: '950 sqm',
      tenure: 'Crown Lease',
      tenureDetails: '99-year Special Industrial Crown Lease.',
      description:
          'Heavy industrial commercial complex located minutes from the Port of Lautoka. Includes high-stud container clearance warehouse, air-conditioned multi-level executive offices, 3-phase power, security gatehouse, and ample heavy vehicle maneuvering space.',
      features: [
        'Close to Port of Lautoka',
        '3-Phase Heavy Industrial Power',
        'Container High-Bay Clearance',
        'Air Conditioned Offices & Boardroom',
        'Secure Perimeter Fencing',
      ],
      images: [
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Priya Sharma',
      agentPhone: '+679 922 5678',
      agentEmail: 'priya@shiftfiji.com',
      agentAgency: 'Suva Prime Properties',
      agentAvatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
      isFeatured: false,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Property(
      id: 'prop-suva-08',
      title: 'Charming Colonial Style Residence in Tamavua',
      priceFjd: 890000,
      priceDisplay: 'FJD \$890,000',
      location: 'Tamavua Heights, Suva, Fiji',
      city: 'Suva',
      transactionType: 'Buy',
      propertyType: 'House',
      bedrooms: 4,
      bathrooms: 3,
      carSpaces: 2,
      landArea: '1,050 sqm',
      floorArea: '280 sqm',
      tenure: 'Crown Lease',
      tenureDetails: '99-year Residential Crown Lease (72 years remaining).',
      description:
          'Nestled on the cool ridges of Tamavua, this character-filled residence offers sea breezes, lush landscaped grounds, polished native hardwood flooring, generous master suite, and separate domestic helper quarters.',
      features: [
        'Cool Ridge Breezes',
        'Polished Fiji Hardwood Floors',
        'Separate Helper Quarters',
        'Swimming Pool & BBQ Terrace',
        'Lush Landscaped Grounds',
      ],
      images: [
        'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80',
        'https://images.unsplash.com/photo-1600566753376-12c8ab7fb75b?auto=format&fit=crop&w=1200&q=80',
      ],
      agentName: 'Alipate Vula',
      agentPhone: '+679 933 1122',
      agentEmail: 'alipate@shiftfiji.com',
      agentAgency: 'Deuba Coastline Properties',
      agentAvatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=200&q=80',
      isFeatured: false,
      isVerified: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ];

  static List<Property> getAll() => List.unmodifiable(_allProperties);

  static List<Property> getFeatured() =>
      _allProperties.where((p) => p.isFeatured).toList();

  static Property? getById(String id) {
    try {
      return _allProperties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Property> getSimilar(Property property, {int limit = 4}) {
    return _allProperties
        .where((p) => p.id != property.id && (p.city == property.city || p.propertyType == property.propertyType || p.transactionType == property.transactionType))
        .take(limit)
        .toList();
  }

  static List<Property> searchProperties({
    String? keyword,
    String? transactionType,
    String? city,
    String? propertyType,
    int? minBedrooms,
    double? minPrice,
    double? maxPrice,
    String? tenure,
    String sortBy = 'featured', // 'featured', 'price_asc', 'price_desc', 'newest'
  }) {
    var results = _allProperties.where((p) {
      // Keyword match
      if (keyword != null && keyword.trim().isNotEmpty) {
        final query = keyword.toLowerCase().trim();
        final matchTitle = p.title.toLowerCase().contains(query);
        final matchLocation = p.location.toLowerCase().contains(query);
        final matchCity = p.city.toLowerCase().contains(query);
        final matchType = p.propertyType.toLowerCase().contains(query);
        final matchTenure = p.tenure.toLowerCase().contains(query);
        final matchDesc = p.description.toLowerCase().contains(query);
        if (!matchTitle && !matchLocation && !matchCity && !matchType && !matchTenure && !matchDesc) {
          return false;
        }
      }

      // Transaction Type (Buy / Rent / Commercial)
      if (transactionType != null &&
          transactionType.isNotEmpty &&
          transactionType != 'All') {
        if (p.transactionType.toLowerCase() != transactionType.toLowerCase()) {
          return false;
        }
      }

      // City / Location
      if (city != null && city.isNotEmpty && city != 'All Locations') {
        if (p.city.toLowerCase() != city.toLowerCase() &&
            !p.location.toLowerCase().contains(city.toLowerCase())) {
          return false;
        }
      }

      // Property Type
      if (propertyType != null &&
          propertyType.isNotEmpty &&
          propertyType != 'All Types') {
        if (!propertyType.toLowerCase().contains(p.propertyType.toLowerCase()) &&
            !p.propertyType.toLowerCase().contains(propertyType.toLowerCase())) {
          return false;
        }
      }

      // Minimum Bedrooms
      if (minBedrooms != null && minBedrooms > 0) {
        if (p.bedrooms < minBedrooms) return false;
      }

      // Price Range (FJD)
      if (minPrice != null && minPrice > 0) {
        if (p.priceFjd < minPrice) return false;
      }
      if (maxPrice != null && maxPrice > 0) {
        if (p.priceFjd > maxPrice) return false;
      }

      // Tenure
      if (tenure != null && tenure.isNotEmpty && tenure != 'All Tenures') {
        if (!p.tenure.toLowerCase().contains(tenure.toLowerCase())) {
          return false;
        }
      }

      return true;
    }).toList();

    // Sorting
    switch (sortBy) {
      case 'price_asc':
        results.sort((a, b) => a.priceFjd.compareTo(b.priceFjd));
        break;
      case 'price_desc':
        results.sort((a, b) => b.priceFjd.compareTo(a.priceFjd));
        break;
      case 'newest':
        results.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'featured':
      default:
        results.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return b.dateAdded.compareTo(a.dateAdded);
        });
        break;
    }

    return results;
  }
}
