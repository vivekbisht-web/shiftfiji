import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shiftfiji/constants/app_colors.dart';

class ToolsTab extends StatefulWidget {
  const ToolsTab({super.key});

  @override
  State<ToolsTab> createState() => _ToolsTabState();
}

class _ToolsTabState extends State<ToolsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mortgage Calculator State
  double _propertyPrice = 450000;
  double _downPaymentPercent = 20;
  double _interestRate = 6.5;
  int _loanTermYears = 25;

  // Currency Converter State
  double _inputAmount = 100000;
  String _selectedForeignCurrency = 'AUD';
  bool _isFjdToForeign = false;

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
    _tabController = TabController(length: 2, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Financial Tools',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.calculate_rounded, size: 20), text: 'Mortgage Calculator'),
            Tab(icon: Icon(Icons.currency_exchange_rounded, size: 20), text: 'Currency Converter'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMortgageCalculator(),
          _buildCurrencyConverter(),
        ],
      ),
    );
  }

  // ==========================================
  // MORTGAGE CALCULATOR
  // ==========================================
  Widget _buildMortgageCalculator() {
    final principalRatio = _totalLoanCost > 0 ? (_loanAmount / _totalLoanCost).clamp(0.0, 1.0) : 0.5;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repayment Summary Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ESTIMATED MONTHLY REPAYMENT',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'FJD ${_currencyFormat.format(_monthlyPayment)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '/ month',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryStat('Loan Principal', 'FJD ${_currencyFormat.format(_loanAmount)}'),
                    _buildSummaryStat('Total Interest', 'FJD ${_currencyFormat.format(_totalInterest)}'),
                    _buildSummaryStat('Total Cost', 'FJD ${_currencyFormat.format(_totalLoanCost)}'),
                  ],
                ),
                const SizedBox(height: 16),
                // Breakdown Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: (principalRatio * 100).toInt(),
                        child: Container(
                          height: 8,
                          color: AppColors.gold,
                        ),
                      ),
                      Expanded(
                        flex: ((1 - principalRatio) * 100).toInt(),
                        child: Container(
                          height: 8,
                          color: Colors.redAccent.shade100,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('● Principal Amount', style: TextStyle(color: AppColors.gold, fontSize: 11)),
                    Text('● Total Interest', style: TextStyle(color: Colors.redAccent, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Sliders & Controls
          _buildSliderCard(
            title: 'Property Purchase Price',
            valueText: 'FJD ${_currencyFormat.format(_propertyPrice)}',
            value: _propertyPrice,
            min: 50000,
            max: 5000000,
            divisions: 99,
            onChanged: (val) => setState(() => _propertyPrice = val),
          ),

          const SizedBox(height: 12),

          _buildSliderCard(
            title: 'Down Payment (${_downPaymentPercent.toInt()}%)',
            valueText: 'FJD ${_currencyFormat.format(_downPaymentAmount)}',
            value: _downPaymentPercent,
            min: 5,
            max: 50,
            divisions: 45,
            onChanged: (val) => setState(() => _downPaymentPercent = val),
          ),

          const SizedBox(height: 12),

          _buildSliderCard(
            title: 'Interest Rate',
            valueText: '${_interestRate.toStringAsFixed(1)}% p.a.',
            value: _interestRate,
            min: 2.0,
            max: 15.0,
            divisions: 65,
            onChanged: (val) => setState(() => _interestRate = val),
          ),

          const SizedBox(height: 12),

          _buildSliderCard(
            title: 'Loan Duration',
            valueText: '$_loanTermYears Years (${_loanTermYears * 12} Months)',
            value: _loanTermYears.toDouble(),
            min: 5,
            max: 35,
            divisions: 30,
            onChanged: (val) => setState(() => _loanTermYears = val.toInt()),
          ),

          const SizedBox(height: 20),

          // Fiji Bank Mortgage Note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Note: Calculations are indicative estimates for Fiji residential lending. Actual loan terms depend on your financial institution (e.g. BSP Fiji, ANZ, Westpac, HFC Bank).',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber.shade900,
                      height: 1.4,
                    ),
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

  Widget _buildSummaryStat(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required String title,
    required String valueText,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                valueText,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.border,
              thumbColor: AppColors.gold,
              overlayColor: AppColors.gold.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CURRENCY CONVERTER
  // ==========================================
  Widget _buildCurrencyConverter() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Converter Card
          Container(
            padding: const EdgeInsets.all(20),
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
                const Text(
                  'International Real Estate Converter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Easily calculate property values in Australian, US, NZ Dollars & more.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Source Input Box
                _buildCurrencyInputBox(
                  currency: _isFjdToForeign ? 'FJD' : _selectedForeignCurrency,
                  isPrimary: true,
                  amount: _inputAmount,
                  onChanged: (val) {
                    final parsed = double.tryParse(val);
                    if (parsed != null && parsed >= 0) {
                      setState(() => _inputAmount = parsed);
                    }
                  },
                ),

                const SizedBox(height: 12),

                // Swap Direction Button
                Center(
                  child: InkWell(
                    onTap: () => setState(() => _isFjdToForeign = !_isFjdToForeign),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(
                        Icons.swap_vert_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Target Output Box
                _buildCurrencyOutputBox(
                  currency: _isFjdToForeign ? _selectedForeignCurrency : 'FJD',
                  amount: _convertedAmount,
                ),

                const SizedBox(height: 16),

                // Foreign Currency Selector Dropdown
                Row(
                  children: [
                    const Text(
                      'Select Comparison Currency:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedForeignCurrency,
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                          items: _exchangeRates.keys.map((curr) {
                            return DropdownMenuItem(
                              value: curr,
                              child: Text(
                                curr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedForeignCurrency = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Preset Fiji Real Estate Benchmarks
          const Text(
            'Common Fiji Property Benchmarks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildBenchmarkTile('Starter Home / Section', 250000),
          _buildBenchmarkTile('Executive Suva Apartment', 650000),
          _buildBenchmarkTile('Denarau Island Beach Villa', 2450000),
          _buildBenchmarkTile('Resort Development Land', 4800000),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCurrencyInputBox({
    required String currency,
    required bool isPrimary,
    required double amount,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currency,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: TextFormField(
              initialValue: amount.toInt().toString(),
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyOutputBox({
    required String currency,
    required double amount,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              currency,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _currencyFormat.format(amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkTile(String title, double fjdPrice) {
    final rate = _exchangeRates[_selectedForeignCurrency] ?? 1.0;
    final converted = fjdPrice * rate;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'FJD ${_currencyFormat.format(fjdPrice)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '≈ $_selectedForeignCurrency ${_currencyFormat.format(converted)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
