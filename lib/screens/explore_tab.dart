import 'package:flutter/material.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/models/property.dart';
import 'package:shiftfiji/screens/buyers_guide_screen.dart';
import 'package:shiftfiji/screens/property_compare_screen.dart';
import 'package:shiftfiji/screens/property_detail_screen.dart';
import 'package:shiftfiji/screens/search_tab.dart';
import 'package:shiftfiji/services/property_service.dart';
import 'package:shiftfiji/services/storage_service.dart';

class ExploreTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const ExploreTab({super.key, this.onNavigateTab});

  @override
  State<ExploreTab> createState() => _ExploreTabState();
}

class _ExploreTabState extends State<ExploreTab> {
  late List<Property> _featuredList;
  late List<Property> _allProperties;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _featuredList = PropertyService.getFeatured();
      _allProperties = PropertyService.getAll();
    });
  }

  void _navigateToSearchWithFilter({String? transactionType, String? city, String? propertyType, String? tenure}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchTab(
          initialTransactionType: transactionType,
          initialCity: city,
          initialPropertyType: propertyType,
          initialTenure: tenure,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SHIFT FIJI',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Real Estate',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.gold),
            tooltip: 'Compare Properties',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PropertyCompareScreen()),
              );
            },
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            icon: const Icon(Icons.favorite_rounded, color: AppColors.goldLight),
            tooltip: 'Saved Properties',
            onPressed: () => widget.onNavigateTab?.call(3),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            icon: const Icon(Icons.calculate_rounded, color: Colors.white),
            tooltip: 'Calculators',
            onPressed: () => widget.onNavigateTab?.call(2),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadData();
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Search Banner
              _buildHeroBanner(context),

              const SizedBox(height: 20),

              // Quick Categories Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Explore Fiji Real Estate',
                      subtitle: 'Find your dream home, luxury villa or freehold land',
                    ),
                    const SizedBox(height: 14),
                    _buildCategoryGrid(context),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Featured Properties Carousel
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _buildSectionHeader(
                        title: 'Featured Fiji Listings',
                        subtitle: 'Hand-picked premium island homes & estates',
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => _navigateToSearchWithFilter(),
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildFeaturedCarousel(context),

              const SizedBox(height: 24),

              // Quick Financial & Investment Tools Banner
              _buildQuickToolsBanner(context),

              const SizedBox(height: 24),

              // Top Locations in Fiji
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Browse Top Locations',
                      subtitle: 'Prime residential and investment hubs across Fiji',
                    ),
                    const SizedBox(height: 14),
                    _buildLocationList(context),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Fiji Land Tenure & Buyer Guide Banner
              _buildBuyerGuideCard(context),

              const SizedBox(height: 24),

              // Recent Fiji Listings Feed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader(
                      title: 'Latest Opportunities',
                      subtitle: 'Newly listed residential & commercial properties',
                    ),
                    const SizedBox(height: 14),
                    _buildRecentPropertiesList(context),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.location_on, color: AppColors.gold, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Fiji Islands',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.success.withOpacity(0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded, color: AppColors.success, size: 13),
                    SizedBox(width: 4),
                    Text(
                      'Verified Listings',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],nti
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Discover Fiji’s Premier\nProperties & Homes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Explore houses for sale, luxury rentals, commercial spaces, and verified real estate agents in Fiji.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Instant Search Bar Trigger
          InkWell(
            onTap: () {
              if (widget.onNavigateTab != null) {
                widget.onNavigateTab!(1);
              } else {
                _navigateToSearchWithFilter();
              }
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Search Suva, Nadi, Denarau Island...',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Filter',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    final categories = [
      {
        'title': 'Properties For Sale',
        'subtitle': 'Houses, villas & freehold',
        'icon': Icons.home_rounded,
        'action': () => _navigateToSearchWithFilter(transactionType: 'Buy'),
        'color': const Color(0xFF1E3A8A),
      },
      {
        'title': 'Properties For Rent',
        'subtitle': 'Short & long-term rentals',
        'icon': Icons.key_rounded,
        'action': () => _navigateToSearchWithFilter(transactionType: 'Rent'),
        'color': const Color(0xFF0F766E),
      },
      {
        'title': 'Freehold Land',
        'subtitle': 'Pure freehold ownership',
        'icon': Icons.landscape_rounded,
        'action': () => _navigateToSearchWithFilter(tenure: 'Freehold'),
        'color': const Color(0xFF6B21A8),
      },
      {
        'title': 'Commercial & Industrial',
        'subtitle': 'Warehouses, offices & shops',
        'icon': Icons.business_rounded,
        'action': () => _navigateToSearchWithFilter(transactionType: 'Commercial'),
        'color': const Color(0xFFC2410C),
      },
      {
        'title': 'Luxury Island Villas',
        'subtitle': 'Denarau & beachfront estates',
        'icon': Icons.villa_rounded,
        'action': () => _navigateToSearchWithFilter(propertyType: 'Villa'),
        'color': const Color(0xFF0369A1),
      },
      {
        'title': 'Fiji Buyer Guide',
        'subtitle': 'Land laws & tenure handbook',
        'icon': Icons.menu_book_rounded,
        'action': () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuyersGuideScreen()),
          );
        },
        'color': const Color(0xFF475569),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.10,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        return InkWell(
          onTap: cat['action'] as VoidCallback,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: (cat['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    color: cat['color'] as Color,
                    size: 20,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      cat['title'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat['subtitle'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeaturedCarousel(BuildContext context) {
    return SizedBox(
      height: 310,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _featuredList.length,
        separatorBuilder: (context, idx) => const SizedBox(width: 14),
        itemBuilder: (context, idx) {
          final p = _featuredList[idx];
          return _buildFeaturedCard(context, p);
        },
      ),
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Property p) {
    final isSaved = StorageService.isPropertySaved(p.id);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: p)),
        ).then((_) => setState(() {}));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 270,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: Image.network(
                    p.mainImage,
                    height: 155,
                    width: 270,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 155,
                      width: 270,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.home_rounded, color: Colors.white, size: 40),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.tenure.toLowerCase().contains('freehold') ? AppColors.success : AppColors.gold,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      p.tenure,
                      style: TextStyle(
                        color: p.tenure.toLowerCase().contains('freehold') ? Colors.white : AppColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                        color: isSaved ? AppColors.error : Colors.white,
                        size: 18,
                      ),
                      onPressed: () async {
                        await StorageService.togglePropertySaved(p);
                        setState(() {});
                      },
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.priceDisplay,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: AppColors.goldDark),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Specs line
                  Row(
                    children: [
                      if (p.bedrooms > 0) ...[
                        const Icon(Icons.bed_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text('${p.bedrooms}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                      ],
                      if (p.bathrooms > 0) ...[
                        const Icon(Icons.bathtub_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Text('${p.bathrooms}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                      ],
                      const Icon(Icons.square_foot_rounded, size: 14, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          p.landArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickToolsBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calculate_rounded,
              color: AppColors.gold,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fiji Mortgage & Currency Suite',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Calculate monthly loan repayments, FJD exchange rates & stamp duty.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
            onPressed: () => widget.onNavigateTab?.call(2),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationList(BuildContext context) {
    final locations = [
      {'name': 'Denarau Island', 'sub': 'Luxury Marina & Gated Villas', 'img': 'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Suva', 'sub': 'Capital City Executive & Penthouses', 'img': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Nadi & Fantasy Island', 'sub': 'Waterfront canal homes & resorts', 'img': 'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Coral Coast & Pacific Harbour', 'sub': 'Freehold coastal lots & golf villas', 'img': 'https://images.unsplash.com/photo-1500382017468-9049fed747ef?auto=format&fit=crop&w=400&q=80'},
      {'name': 'Savusavu', 'sub': 'Eco-resort land & private bays', 'img': 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=400&q=80'},
    ];

    return Column(
      children: locations.map((loc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                loc['img']!,
                width: 54,
                height: 54,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 54,
                  height: 54,
                  color: AppColors.primaryLight,
                  child: const Icon(Icons.location_city_rounded, color: Colors.white, size: 24),
                ),
              ),
            ),
            title: Text(
              loc['name']!,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              loc['sub']!,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            onTap: () => _navigateToSearchWithFilter(city: loc['name']!.split(' ')[0]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBuyerGuideCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.gavel_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fiji Property Buyer Guide',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.primary),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Learn about Freehold vs Crown Lease, Non-Resident rules & Stamp Duty.',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BuyersGuideScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Read', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPropertiesList(BuildContext context) {
    return Column(
      children: _allProperties.take(4).map((p) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: p)),
              ).then((_) => setState(() {}));
            },
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  child: Image.network(
                    p.mainImage,
                    width: 110,
                    height: 110,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 110,
                      height: 110,
                      color: AppColors.primaryLight,
                      child: const Icon(Icons.home_work_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p.priceDisplay,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: p.tenure.toLowerCase().contains('freehold') ? AppColors.success.withOpacity(0.15) : AppColors.gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.tenure,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: p.tenure.toLowerCase().contains('freehold') ? AppColors.success : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          p.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (p.bedrooms > 0) ...[
                              const Icon(Icons.bed_rounded, size: 13, color: AppColors.primary),
                              const SizedBox(width: 2),
                              Text('${p.bedrooms}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 8),
                            ],
                            const Icon(Icons.square_foot_rounded, size: 13, color: AppColors.primary),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                p.landArea,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
        );
      }).toList(),
    );
  }
}
