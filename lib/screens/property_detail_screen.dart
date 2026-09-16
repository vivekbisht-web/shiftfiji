import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/models/property.dart';
import 'package:shiftfiji/screens/buyers_guide_screen.dart';
import 'package:shiftfiji/services/property_service.dart';
import 'package:shiftfiji/services/storage_service.dart';

class PropertyDetailScreen extends StatefulWidget {
  final Property property;

  const PropertyDetailScreen({super.key, required this.property});

  @override
  State<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  bool _isSaved = false;
  bool _isInCompare = false;
  String _selectedCurrency = 'FJD';

  // In-Listing Mortgage Estimator State
  late double _downPaymentPercent;
  double _interestRate = 6.5;
  final int _loanTermYears = 25;

  // Benchmark Rates against FJD
  final Map<String, double> _rates = {
    'FJD': 1.0,
    'AUD': 0.68,
    'USD': 0.45,
    'NZD': 0.74,
    'EUR': 0.41,
    'GBP': 0.35,
  };

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _downPaymentPercent = 20.0;
    _isSaved = StorageService.isPropertySaved(widget.property.id);
    _isInCompare = StorageService.isInComparison(widget.property.id);
    _selectedCurrency = StorageService.getPreferredCurrency();
    StorageService.trackRecentlyViewed(widget.property.id);
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

  void _toggleSave() async {
    final newState = !_isSaved;
    setState(() {
      _isSaved = newState;
    });
    if (newState) {
      await StorageService.savePropertyFromModel(widget.property);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.property.title} saved to your portfolio.'),
            backgroundColor: AppColors.primary,
            action: SnackBarAction(
              label: 'Add Note',
              textColor: AppColors.gold,
              onPressed: _showNotesDialog,
            ),
          ),
        );
      }
    } else {
      await StorageService.removeProperty(widget.property.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from saved properties.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _toggleCompare() async {
    await StorageService.toggleComparison(widget.property.id);
    setState(() {
      _isInCompare = StorageService.isInComparison(widget.property.id);
    });
    if (mounted) {
      final total = StorageService.getComparisonIds().length;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isInCompare
              ? 'Added to comparison matrix ($total/3 selected).'
              : 'Removed from comparison matrix.'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showNotesDialog() {
    final savedProps = StorageService.getSavedProperties();
    final existing = savedProps.firstWhere(
      (p) => p.id == widget.property.id,
      orElse: () => StorageService.getSavedProperties().first,
    );
    final controller = TextEditingController(text: existing.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Private Note', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'e.g., Scheduled inspection with Seru for Saturday 2pm...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.updatePropertyNotes(widget.property.id, controller.text.trim());
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _shareProperty() {
    Share.share(
      'Check out ${widget.property.title} in ${widget.property.location} for ${widget.property.priceDisplay} on Shift Fiji:\nhttps://shiftfiji.com/properties/${widget.property.id}',
      subject: widget.property.title,
    );
  }

  Future<void> _makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'\s+'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final uri = Uri.parse(
      'mailto:$email?subject=Inquiry: ${Uri.encodeComponent(widget.property.title)}&body=Hello ${widget.property.agentName},\n\nI am interested in ${widget.property.title} located in ${widget.property.location} listed for ${widget.property.priceDisplay}. Please send me further inspection details.',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendWhatsApp(String phone) async {
    final cleanNumber = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final uri = Uri.parse(
      'https://wa.me/$cleanNumber?text=Hi%20${Uri.encodeComponent(widget.property.agentName)},%20I%20am%20inquiring%20about%20${Uri.encodeComponent(widget.property.title)}%20(${widget.property.priceDisplay}).',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showInspectionModal() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final dateController = TextEditingController(text: 'This Weekend (Preferred)');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 24,
          left: 20,
          right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Book Property Viewing',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Request a private or virtual guided viewing for ${widget.property.title}.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number / WhatsApp',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: dateController,
              decoration: const InputDecoration(
                labelText: 'Preferred Day / Time',
                prefixIcon: Icon(Icons.access_time_rounded, size: 20),
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Viewing request submitted to ${widget.property.agentName}! They will contact you shortly.'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                child: const Text('Confirm Inspection Request', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mortgage Calculations
  double get _loanAmount => widget.property.priceFjd * (1 - (_downPaymentPercent / 100.0));
  double get _monthlyRepayment {
    if (widget.property.transactionType == 'Rent' || _loanAmount <= 0) return 0;
    final r = (_interestRate / 100.0) / 12.0;
    final n = _loanTermYears * 12;
    if (r == 0) return _loanAmount / n;
    final factor = pow(1 + r, n).toDouble();
    return _loanAmount * (r * factor) / (factor - 1);
  }

  String _formatConvertedPrice() {
    final rate = _rates[_selectedCurrency] ?? 1.0;
    final converted = widget.property.priceFjd * rate;
    if (widget.property.transactionType == 'Rent') {
      return '$_selectedCurrency \$${_currencyFormat.format(converted).replaceAll('\$', '')}/mo';
    }
    return '$_selectedCurrency \$${_currencyFormat.format(converted).replaceAll('\$', '')}';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final similar = PropertyService.getSimilar(p);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero Image Gallery App Bar
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isInCompare ? Icons.compare_arrows_rounded : Icons.compare_arrows_outlined,
                    color: _isInCompare ? AppColors.gold : Colors.white,
                    size: 20,
                  ),
                ),
                tooltip: 'Compare Property',
                onPressed: _toggleCompare,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                ),
                tooltip: 'Share Property',
                onPressed: _shareProperty,
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSaved ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                    color: _isSaved ? AppColors.error : Colors.white,
                    size: 20,
                  ),
                ),
                tooltip: 'Save Property',
                onPressed: _toggleSave,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: _imagePageController,
                    itemCount: p.images.length,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentImageIndex = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      return Image.network(
                        p.images[idx],
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) => Container(
                          color: AppColors.primaryLight,
                          child: const Center(
                            child: Icon(Icons.image_not_supported_rounded, color: Colors.white54, size: 48),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ),
                  // Image Counter Indicator
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.photo_camera_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${_currentImageIndex + 1} / ${p.images.length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Tenure Badge
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: p.tenure.toLowerCase().contains('freehold')
                            ? AppColors.success
                            : AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.tenure,
                        style: TextStyle(
                          color: p.tenure.toLowerCase().contains('freehold') ? Colors.white : AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Header with Currency Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.priceDisplay,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (_selectedCurrency != 'FJD')
                              Text(
                                '≈ ${_formatConvertedPrice()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.goldDark,
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Currency Switcher Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedCurrency,
                          underline: const SizedBox(),
                          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                          items: ['FJD', 'AUD', 'USD', 'NZD', 'EUR', 'GBP'].map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(c, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedCurrency = val;
                              });
                              StorageService.setPreferredCurrency(val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Title & Address
                  Text(
                    p.title,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 16, color: AppColors.goldDark),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          p.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Specifications Matrix Cards
                  _buildSpecsMatrix(p),

                  const SizedBox(height: 20),

                  // Fiji Land Tenure Legal Insights Card
                  _buildTenureCard(p),

                  const SizedBox(height: 20),

                  // Overview & Description
                  _buildSectionTitle('Property Overview'),
                  const SizedBox(height: 8),
                  Text(
                    p.description,
                    style: const TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textPrimary,
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Features & Amenities Chips
                  _buildSectionTitle('Key Features & Amenities'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.features.map((f) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              f,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Interactive Mortgage Estimator (if Buy)
                  if (p.transactionType == 'Buy') ...[
                    _buildMortgageEstimatorCard(p),
                    const SizedBox(height: 24),
                  ],

                  // Agent Profile & Inquiry Section
                  _buildAgentCard(p),

                  const SizedBox(height: 24),

                  // Similar Properties
                  if (similar.isNotEmpty) ...[
                    _buildSectionTitle('Similar Properties in Fiji'),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 240,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: similar.length,
                        separatorBuilder: (context, idx) => const SizedBox(width: 14),
                        itemBuilder: (context, idx) {
                          final item = similar[idx];
                          return _buildSimilarCard(item);
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),

      // Persistent Bottom Action Bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Call Agent Quick Button
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                  tooltip: 'Call Agent',
                  onPressed: () => _makeCall(p.agentPhone),
                ),
              ),
              const SizedBox(width: 10),
              // WhatsApp Quick Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF25D366).withOpacity(0.3)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF25D366)),
                  tooltip: 'WhatsApp Agent',
                  onPressed: () => _sendWhatsApp(p.agentPhone),
                ),
              ),
              const SizedBox(width: 12),
              // Book Inspection Main Action Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showInspectionModal,
                  icon: const Icon(Icons.calendar_month_rounded, size: 18),
                  label: const Text(
                    'Book Viewing',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSpecsMatrix(Property p) {
    final items = [
      {'icon': Icons.bed_rounded, 'label': 'Bedrooms', 'val': '${p.bedrooms}'},
      {'icon': Icons.bathtub_rounded, 'label': 'Bathrooms', 'val': '${p.bathrooms}'},
      {'icon': Icons.directions_car_rounded, 'label': 'Parking', 'val': '${p.carSpaces}'},
      {'icon': Icons.landscape_rounded, 'label': 'Land Area', 'val': p.landArea},
      {'icon': Icons.square_foot_rounded, 'label': 'Floor Area', 'val': p.floorArea},
      {'icon': Icons.category_rounded, 'label': 'Type', 'val': p.propertyType},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.95,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: items.length,
        itemBuilder: (context, idx) {
          final item = items[idx];
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(item['icon'] as IconData, size: 18, color: AppColors.primary),
                const SizedBox(height: 4),
                Text(
                  item['val'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 1),
                Text(
                  item['label'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTenureCard(Property p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fiji Land Tenure: ${p.tenure}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BuyersGuideScreen()),
                  );
                },
                child: const Text('Guide', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            p.tenureDetails,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMortgageEstimatorCard(Property p) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.calculate_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Mortgage Estimator',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'FJD \$${_currencyFormat.format(_monthlyRepayment).replaceAll('\$', '')}/mo',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14.5,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Down Payment Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Down Payment', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_downPaymentPercent.toInt()}% (FJD \$${_currencyFormat.format(p.priceFjd * (_downPaymentPercent / 100)).replaceAll('\$', '')})',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: _downPaymentPercent,
            min: 10,
            max: 50,
            divisions: 8,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() {
                _downPaymentPercent = val;
              });
            },
          ),

          // Interest Rate Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Interest Rate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_interestRate.toStringAsFixed(1)}% p.a.',
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Slider(
            value: _interestRate,
            min: 4.0,
            max: 12.0,
            divisions: 16,
            activeColor: AppColors.gold,
            inactiveColor: AppColors.border,
            onChanged: (val) {
              setState(() {
                _interestRate = val;
              });
            },
          ),
          const SizedBox(height: 4),
          const Text(
            '*Estimated monthly principal & interest payment based on 25-year term. Excludes insurance and council rates.',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildAgentCard(Property p) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(p.agentAvatar),
                backgroundColor: AppColors.primaryLight,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.agentName,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.agentAgency,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 14, color: AppColors.success),
                        SizedBox(width: 4),
                        Text(
                          'Licensed Real Estate Agent (REALB)',
                          style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _makeCall(p.agentPhone),
                  icon: const Icon(Icons.call_rounded, size: 16),
                  label: const Text('Call Agent'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _sendEmail(p.agentEmail),
                  icon: const Icon(Icons.email_outlined, size: 16),
                  label: const Text('Email Inquiry'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimilarCard(Property item) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: item),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Image.network(
                item.mainImage,
                height: 120,
                width: 220,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.priceDisplay,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
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
