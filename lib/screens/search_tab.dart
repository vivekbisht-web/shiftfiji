import 'package:flutter/material.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/screens/web_view.dart';
import 'package:shiftfiji/services/storage_service.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _keywordController = TextEditingController();

  String _transactionType = 'Buy'; // Buy, Rent, Commercial
  String _selectedLocation = 'All Locations';
  String _selectedPropertyType = 'All Types';
  int _selectedBedrooms = 0; // 0 = Any
  RangeValues _priceRange = const RangeValues(0, 3000000);

  final List<String> _locations = [
    'All Locations',
    'Suva',
    'Nadi',
    'Denarau Island',
    'Lautoka',
    'Coral Coast',
    'Pacific Harbour',
    'Nausori',
    'Savusavu',
    'Labasa',
  ];

  final List<String> _propertyTypes = [
    'All Types',
    'House / Villa',
    'Apartment / Flat',
    'Residential Land',
    'Commercial Property',
    'Holiday Home / Resort',
  ];

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = StorageService.getRecentSearches();
    });
  }

  void _executeSearch([String? directKeyword]) {
    final queryText = directKeyword ?? _keywordController.text.trim();
    if (queryText.isNotEmpty) {
      StorageService.addRecentSearch(queryText);
      _loadRecentSearches();
    }

    final queryParams = <String, String>{};
    if (queryText.isNotEmpty) queryParams['keyword'] = queryText;
    if (_transactionType != 'Buy') queryParams['type'] = _transactionType.toLowerCase();
    if (_selectedLocation != 'All Locations') queryParams['location'] = _selectedLocation;
    if (_selectedPropertyType != 'All Types') queryParams['property_type'] = _selectedPropertyType;
    if (_selectedBedrooms > 0) queryParams['beds'] = '$_selectedBedrooms';
    if (_priceRange.start > 0) queryParams['min_price'] = '${_priceRange.start.toInt()}';
    if (_priceRange.end < 3000000) queryParams['max_price'] = '${_priceRange.end.toInt()}';

    final uri = Uri(
      scheme: 'https',
      host: 'shiftfiji.com',
      path: '/properties',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final title = _selectedLocation != 'All Locations'
        ? '$_selectedLocation Properties'
        : 'Search Results';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartWebViewScreen(
          initialUrl: uri.toString(),
          title: title,
        ),
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _keywordController.clear();
      _transactionType = 'Buy';
      _selectedLocation = 'All Locations';
      _selectedPropertyType = 'All Types';
      _selectedBedrooms = 0;
      _priceRange = const RangeValues(0, 3000000);
    });
  }

  String _formatCurrency(double value) {
    if (value >= 1000000) {
      return 'FJD \$${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return 'FJD \$${(value / 1000).toStringAsFixed(0)}K';
    }
    return 'FJD \$${value.toInt()}';
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
          'Search & Filters',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Reset',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction Type Segmented Toggle
            _buildTransactionToggle(),

            const SizedBox(height: 20),

            // Keyword Search Input
            _buildSearchBox(),

            const SizedBox(height: 20),

            // Location Selector Dropdown
            _buildDropdownFilter(
              label: 'Location / Region in Fiji',
              icon: Icons.location_on_rounded,
              value: _selectedLocation,
              items: _locations,
              onChanged: (val) {
                if (val != null) setState(() => _selectedLocation = val);
              },
            ),

            const SizedBox(height: 16),

            // Property Type Dropdown
            _buildDropdownFilter(
              label: 'Property Category',
              icon: Icons.apartment_rounded,
              value: _selectedPropertyType,
              items: _propertyTypes,
              onChanged: (val) {
                if (val != null) setState(() => _selectedPropertyType = val);
              },
            ),

            const SizedBox(height: 20),

            // Bedrooms Selector
            _buildBedroomsSelector(),

            const SizedBox(height: 20),

            // Price Range Slider
            _buildPriceRangeSelector(),

            const SizedBox(height: 24),

            // Search CTA Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => _executeSearch(),
                icon: const Icon(Icons.search_rounded, size: 20),
                label: const Text(
                  'Search Properties',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.primary,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Recent Searches Chips
            if (_recentSearches.isNotEmpty) ...[
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _recentSearches.map((term) {
                  return ActionChip(
                    avatar: const Icon(Icons.history_rounded, size: 16, color: AppColors.textSecondary),
                    label: Text(
                      term,
                      style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                    ),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () {
                      _keywordController.text = term;
                      _executeSearch(term);
                    },
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionToggle() {
    final types = ['Buy', 'Rent', 'Commercial'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: types.map((type) {
          final isSelected = _transactionType == type;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _transactionType = type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _keywordController,
        onSubmitted: (val) => _executeSearch(),
        decoration: InputDecoration(
          hintText: 'Enter keyword, suburb, street, agency...',
          hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 14),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          suffixIcon: _keywordController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    _keywordController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBedroomsSelector() {
    final bedOptions = [0, 1, 2, 3, 4, 5];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bedrooms',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: bedOptions.map((beds) {
            final isSelected = _selectedBedrooms == beds;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3.0),
                child: InkWell(
                  onTap: () => setState(() => _selectedBedrooms = beds),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      beds == 0 ? 'Any' : '$beds+',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Price Range (FJD)',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${_formatCurrency(_priceRange.start)} - ${_formatCurrency(_priceRange.end)}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
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
              setState(() => _priceRange = values);
            },
          ),
        ],
      ),
    );
  }
}
