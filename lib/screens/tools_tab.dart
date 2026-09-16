import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/screens/buyers_guide_screen.dart';

class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mortgage Calculator State
  double _propertyPrice = 650000;
  double _downPaymentPercent = 20;
  double _interestRate = 6.5;
  int _loanTermYears = 25;

  // Currency Converter State
  double _inputAmount = 100000;
  String _selectedForeignCurrency = 'AUD';
  bool _isFjdToForeign = false;

  // Stamp Duty / Closing Costs State
  double _transferPurchasePrice = 500000;
  bool _isNonResidentBuyer = false;

  // Fixed benchmark exchange rates (FJD base)
  final Map<String, double> _exchangeRates = {
    'AUD': 0.68,
    'USD': 0.45,
    'NZD': 0.74,
    'EUR': 0.41,
    'GBP': 0.35,
    'CAD': 0.61,
    'CNY': 3.25,
    'JPY': 68.50,
  };

  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Mortgage Calculations
  double get _downPaymentAmount => _propertyPrice * (_downPaymentPercent / 100.0);
  double get _loanAmount => _propertyPrice - _downPaymentAmount;

  double get _monthlyPayment {
    if (_loanAmount <= 0) return 0;
    final monthlyRate = (_interestRate / 100.0) / 12.0;
    final totalMonths = _loanTermYears * 12;

    if (monthlyRate == 0) return _loanAmount / totalMonths;

    final factor = pow(1 + monthlyRate, totalMonths).toDouble();
    return _loanAmount * (monthlyRate * factor) / (factor - 1);
  }

  double get _totalLoanCost => _monthlyPayment * (_loanTermYears * 12);
  double get _totalInterest => _totalLoanCost > _loanAmount ? _totalLoanCost - _loanAmount : 0;

  // Currency Calculations
  double get _convertedAmount {
    final rate = _exchangeRates[_selectedForeignCurrency] ?? 1.0;
    if (_isFjdToForeign) {
      return _inputAmount * rate;
    } else {
      return _inputAmount / rate;
    }
  }

  // Closing Cost Estimations (Fiji)
  double get _estimatedLegalConveyancingFee => _transferPurchasePrice * 0.02; // ~2%
  double get _estimatedTitleRegistrationFee => 150.0;
  double get _estimatedValuationFee => 850.0;
  double get _totalEstimatedClosingCost =>
      _estimatedLegalConveyancingFee + _estimatedTitleRegistrationFee + _estimatedValuationFee;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Financial & Legal Tools',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(text: 'Mortgage'),
            Tab(text: 'Currency'),
            Tab(text: 'Closing Costs'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMortgageTab(),
          _buildCurrencyTab(),
          _buildClosingCostsTab(),
        ],
      ),
    );
  }

  Widget _buildMortgageTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Monthly Repayment Result Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'ESTIMATED MONTHLY REPAYMENT',
                  style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                ),
                const SizedBox(height: 8),
                Text(
                  'FJD \$${_currencyFormat.format(_monthlyPayment).replaceAll('\$', '')}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Loan Principal', 'FJD \$${_currencyFormat.format(_loanAmount).replaceAll('\$', '')}'),
                    _buildStatCol('Total Interest', 'FJD \$${_currencyFormat.format(_totalInterest).replaceAll('\$', '')}'),
                    _buildStatCol('Total Outlay', 'FJD \$${_currencyFormat.format(_totalLoanCost).replaceAll('\$', '')}'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Controls Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Property Price Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Property Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FJD \$${_currencyFormat.format(_propertyPrice).replaceAll('\$', '')}',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _propertyPrice,
                  min: 100000,
                  max: 3000000,
                  divisions: 58,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _propertyPrice = val),
                ),

                const SizedBox(height: 12),

                // Down Payment
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Down Payment (%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_downPaymentPercent.toInt()}% (FJD \$${_currencyFormat.format(_downPaymentAmount).replaceAll('\$', '')})',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _downPaymentPercent,
                  min: 5,
                  max: 50,
                  divisions: 9,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _downPaymentPercent = val),
                ),

                const SizedBox(height: 12),

                // Interest Rate
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Interest Rate (% p.a.)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_interestRate.toStringAsFixed(1)}%',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.goldDark, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _interestRate,
                  min: 3.5,
                  max: 12.0,
                  divisions: 17,
                  activeColor: AppColors.gold,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _interestRate = val),
                ),

                const SizedBox(height: 12),

                // Loan Term
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Loan Term (Years)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$_loanTermYears Years',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _loanTermYears.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 5,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _loanTermYears = val.toInt()),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Fiji Banks Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withOpacity(0.4)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Major commercial lenders in Fiji include BSP (Bank South Pacific), ANZ Fiji, Westpac Fiji, and BRED Bank.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrencyTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Conversion Box
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isFjdToForeign ? 'Converting from FJD' : 'Converting to FJD',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.swap_vert_rounded, color: AppColors.primary),
                      onPressed: () {
                        setState(() {
                          _isFjdToForeign = !_isFjdToForeign;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Amount Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                    Text(
                      '${_isFjdToForeign ? "FJD" : _selectedForeignCurrency} \$${_currencyFormat.format(_inputAmount).replaceAll('\$', '')}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
                Slider(
                  value: _inputAmount,
                  min: 10000,
                  max: 2000000,
                  divisions: 40,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _inputAmount = val),
                ),

                const SizedBox(height: 14),

                // Foreign Currency Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedForeignCurrency,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: _exchangeRates.keys.map((c) {
                      return DropdownMenuItem(
                        value: c,
                        child: Text('$c - ${_getCurrencyName(c)}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedForeignCurrency = val;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(height: 20),

                // Result Box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _isFjdToForeign ? 'Equivalent in $_selectedForeignCurrency' : 'Equivalent in Fiji Dollars (FJD)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_isFjdToForeign ? _selectedForeignCurrency : "FJD"} \$${_currencyFormat.format(_convertedAmount).replaceAll('\$', '')}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Live Benchmark Rates
          const Text(
            'Fiji Dollar (FJD) Benchmark Indicative Rates',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 10),
          ..._exchangeRates.entries.map((entry) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 FJD', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
                  Text(
                    '${entry.value} ${entry.key}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13.5),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildClosingCostsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primaryLight, AppColors.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Fiji Stamp Duty & Closing Costs',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(
                  'Under current Fiji fiscal legislation, Stamp Duty on residential transfers has been abolised (0%). Here is the estimate of legal conveyancing and registration fees.',
                  style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12.5, height: 1.35),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Price Slider
          Container(
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
                    const Text('Purchase Price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'FJD \$${_currencyFormat.format(_transferPurchasePrice).replaceAll('\$', '')}',
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _transferPurchasePrice,
                  min: 100000,
                  max: 3000000,
                  divisions: 29,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  onChanged: (val) => setState(() => _transferPurchasePrice = val),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Non-Resident / Foreign Purchaser', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  subtitle: const Text('Subject to Land Sales Act compliance', style: TextStyle(fontSize: 11.5)),
                  value: _isNonResidentBuyer,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isNonResidentBuyer = val),
                ),

                const Divider(height: 24),

                // Cost Itemization
                _buildFeeRow('Fiji Stamp Duty on Transfer', 'FJD \$0 (Abolished)', isHighlight: true),
                _buildFeeRow('Legal Conveyancing Fee (~2%)', 'FJD \$${_currencyFormat.format(_estimatedLegalConveyancingFee).replaceAll('\$', '')}'),
                _buildFeeRow('Registrar of Titles Registration Fee', 'FJD \$${_currencyFormat.format(_estimatedTitleRegistrationFee).replaceAll('\$', '')}'),
                _buildFeeRow('Valuation & Survey Estimate', 'FJD \$${_currencyFormat.format(_estimatedValuationFee).replaceAll('\$', '')}'),

                const Divider(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Estimated Closing Costs', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.textPrimary)),
                    Text(
                      'FJD \$${_currencyFormat.format(_totalEstimatedClosingCost).replaceAll('\$', '')}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Complete Buyer's Guide Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuyersGuideScreen()),
                );
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('Open Full Fiji Property Buyer Guide'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String val) {
    return Column(
      children: [
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }

  Widget _buildFeeRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrencyName(String code) {
    switch (code) {
      case 'AUD': return 'Australian Dollar';
      case 'USD': return 'US Dollar';
      case 'NZD': return 'New Zealand Dollar';
      case 'EUR': return 'Euro';
      case 'GBP': return 'British Pound';
      case 'CAD': return 'Canadian Dollar';
      case 'CNY': return 'Chinese Yuan';
      case 'JPY': return 'Japanese Yen';
      default: return code;
    }
  }
}
