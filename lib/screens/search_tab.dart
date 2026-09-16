import 'package:flutter/material.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/models/property.dart';
import 'package:shiftfiji/screens/property_compare_screen.dart';
import 'package:shiftfiji/screens/property_detail_screen.dart';
import 'package:shiftfiji/services/property_service.dart';
import 'package:shiftfiji/services/storage_service.dart';

class SearchTab extends StatefulWidget {
  final String? initialTransactionType;
  final String? initialCity;
  final String? initialPropertyType;
  final String? initialTenure;

  const SearchTab({
    super.key,
    this.initialTransactionType,
    this.initialCity,
    this.initialPropertyType,
    this.initialTenure,
  });

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _keywordController = TextEditingController();

  late String _transactionType;
  late String _selectedLocation;
  late String _selectedPropertyType;
  late String _selectedTenure;
  int _selectedBedrooms = 0;
  RangeValues _priceRange = const RangeValues(0, 3000000);
  String _sortBy = 'featured';
  bool _isGridView = false;

  final List<String> _locations = [
    'All Locations',
    'Denarau Island',
    'Suva',
    'Nadi',
    'Coral Coast',
    'Pacific Harbour',
    'Savusavu',
    'Lautoka',
  ];

  final List<String> _propertyTypes = [
    'All Types',
    'House',
    'Villa',
    'Apartment',
    'Land',
    'Commercial',
  ];

  final List<String> _tenures = [
    'All Tenures',
    'Freehold',
    'Crown Lease',
    'Native Lease (TLTB)',
  ];

  List<String> _recentSearches = [];
  List<Property> _filteredResults = [];

  @override
  void initState() {
    super.initState();
    _transactionType = widget.initialTransactionType ?? 'All';
    _selectedLocation = widget.initialCity ?? 'All Locations';
    _selectedPropertyType = widget.initialPropertyType ?? 'All Types';
    _selectedTenure = widget.initialTenure ?? 'All Tenures';

    _loadRecentSearches();
    _performSearch();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = StorageService.getRecentSearches();
    });
  }

  void _performSearch([String? directKeyword]) {
    final queryText = directKeyword ?? _keywordController.text.trim();
    if (queryText.isNotEmpty) {
      StorageService.addRecentSearch(queryText);
      _loadRecentSearches();
    }

    final results = PropertyService.searchProperties(
      keyword: queryText.isNotEmpty ? queryText : null,
      transactionType: _transactionType != 'All' ? _transactionType : null,
      city: _selectedLocation != 'All Locations' ? _selectedLocation : null,
      propertyType: _selectedPropertyType != 'All Types' ? _selectedPropertyType : null,
      tenure: _selectedTenure != 'All Tenures' ? _selectedTenure : null,
      minBedrooms: _selectedBedrooms > 0 ? _selectedBedrooms : null,
      minPrice: _priceRange.start > 0 ? _priceRange.start : null,
      maxPrice: _priceRange.end < 3000000 ? _priceRange.end : null,
      sortBy: _sortBy,
    );

    setState(() {
      _filteredResults = results;
    });
  }

  void _resetFilters() {
    setState(() {
      _keywordController.clear();
      _transactionType = 'All';
      _selectedLocation = 'All Locations';
      _selectedPropertyType = 'All Types';
      _selectedTenure = 'All Tenures';
      _selectedBedrooms = 0;
      _priceRange = const RangeValues(0, 3000000);
      _sortBy = 'featured';
    });
    _performSearch();
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Filters & Refinements',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          TextButton(
                            onPressed: () {
                              _resetFilters();
                              setModalState(() {});
                              Navigator.pop(context);
                            },
                            child: const Text('Reset All', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Transaction Type
                      const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['All', 'Buy', 'Rent', 'Commercial'].map((type) {
                          final selected = _transactionType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: selected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (val) {
                                setModalState(() {
                                  _transactionType = type;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Location
                      const Text('Fiji Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: _locations.map((loc) {
                            return DropdownMenuItem(
                              value: loc,
                              child: Text(loc, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                _selectedLocation = val;
                              });
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Property Type
                      const Text('Property Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _propertyTypes.map((t) {
                          final selected = _selectedPropertyType == t;
                          return ChoiceChip(
                            label: Text(t),
                            selected: selected,
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: selected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                _selectedPropertyType = t;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Fiji Land Tenure Filter
                      const Text('Fiji Land Tenure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tenures.map((tenure) {
                          final selected = _selectedTenure == tenure;
                          return ChoiceChip(
                            label: Text(tenure),
                            selected: selected,
                            selectedColor: AppColors.gold,
                            labelStyle: TextStyle(
                              color: selected ? AppColors.primary : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            onSelected: (val) {
                              setModalState(() {
                                _selectedTenure = tenure;
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Bedrooms
                      const Text('Min Bedrooms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(height: 8),
                      Row(
                        children: [0, 1, 2, 3, 4, 5].map((b) {
                          final selected = _selectedBedrooms == b;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(b == 0 ? 'Any' : '$b+'),
                              selected: selected,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                color: selected ? Colors.white : AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              onSelected: (val) {
                                setModalState(() {
                                  _selectedBedrooms = b;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // Price Range Slider
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Price Range (FJD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(
                            '${_formatCurrency(_priceRange.start)} - ${_formatCurrency(_priceRange.end)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12.5),
                          ),
                        ],
                      ),
                      RangeSlider(
                        values: _priceRange,
                        min: 0,
                        max: 3000000,
                        divisions: 30,
                        activeColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                        onChanged: (values) {
                          setModalState(() {
                            _priceRange = values;
                          });
                        },
                      ),

                      const SizedBox(height: 24),

                      // Apply Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _performSearch();
                          },
                          child: const Text('Apply Filters & View Results', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '\$${(value / 1000).toStringAsFixed(0)}K';
    }
    return '\$${value.toInt()}';
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Fiji Property Search',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.gold),
            tooltip: 'Compare Matrix',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PropertyCompareScreen()),
              );
            },
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded, color: Colors.white),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Box & Filter Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Keyword Search Field
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TextField(
                          controller: _keywordController,
                          textInputAction: TextInputAction.search,
                          onSubmitted: (val) => _performSearch(),
                          decoration: InputDecoration(
                            hintText: 'Search Suva, Denarau, Villa, Freehold...',
                            hintStyle: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary),
                            prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
                            suffixIcon: _keywordController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear_rounded, size: 18),
                                    onPressed: () {
                                      _keywordController.clear();
                                      _performSearch();
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _showFilterModal,
                      icon: const Icon(Icons.tune_rounded, size: 16),
                      label: const Text('Filter'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Quick Filters Chips Line
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Buy / Rent / Commercial Quick Toggle
                      ...['All', 'Buy', 'Rent', 'Commercial'].map((type) {
                        final selected = _transactionType == type;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _transactionType = type;
                              });
                              _performSearch();
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: selected ? AppColors.primary : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected ? AppColors.primary : AppColors.border,
                                ),
                              ),
                              child: Text(
                                type,
                                style: TextStyle(
                                  color: selected ? Colors.white : AppColors.textPrimary,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(width: 6),
                      // Sort Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _sortBy,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.arrow_drop_down, size: 16),
                          items: const [
                            DropdownMenuItem(value: 'featured', child: Text('Featured', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                            DropdownMenuItem(value: 'newest', child: Text('Newest First', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _sortBy = val;
                              });
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                if (_recentSearches.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        const Icon(Icons.history_rounded, size: 14, color: AppColors.textLight),
                        const SizedBox(width: 4),
                        ..._recentSearches.take(4).map((query) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 6.0),
                            child: InkWell(
                              onTap: () {
                                _keywordController.text = query;
                                _performSearch(query);
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  query,
                                  style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Search Stats Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredResults.length} properties available in Fiji',
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimary),
                ),
                if (_selectedLocation != 'All Locations' || _selectedPropertyType != 'All Types' || _selectedTenure != 'All Tenures')
                  InkWell(
                    onTap: _resetFilters,
                    child: const Text('Clear Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
              ],
            ),
          ),

          // Property Results Feed
          Expanded(
            child: _filteredResults.isEmpty
                ? _buildEmptyResults()
                : _isGridView
                    ? _buildGridResults()
                    : _buildListResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off_rounded, size: 52, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Matching Properties',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try expanding your price range or clearing location/tenure filters to discover available Fiji real estate.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _resetFilters,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reset All Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListResults() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const BouncingScrollPhysics(),
      itemCount: _filteredResults.length,
      itemBuilder: (context, idx) {
        final p = _filteredResults[idx];
        return _buildListCard(p);
      },
    );
  }

  Widget _buildGridResults() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredResults.length,
      itemBuilder: (context, idx) {
        final p = _filteredResults[idx];
        return _buildGridCard(p);
      },
    );
  }

  Widget _buildListCard(Property p) {
    final isSaved = StorageService.isPropertySaved(p.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: p)),
          ).then((_) => setState(() {}));
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.network(
                    p.mainImage,
                    height: 170,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
                        fontSize: 11,
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
                        size: 20,
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
              padding: const EdgeInsets.all(14),
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
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        p.propertyType,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 14, color: AppColors.goldDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      if (p.bedrooms > 0) ...[
                        const Icon(Icons.bed_rounded, size: 15, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${p.bedrooms} Beds', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                      ],
                      if (p.bathrooms > 0) ...[
                        const Icon(Icons.bathtub_rounded, size: 15, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text('${p.bathrooms} Baths', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 12),
                      ],
                      const Icon(Icons.square_foot_rounded, size: 15, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.landArea,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
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

  Widget _buildGridCard(Property p) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                p.mainImage,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.priceDisplay,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    p.city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    p.tenure,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: p.tenure.toLowerCase().contains('freehold') ? AppColors.success : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
