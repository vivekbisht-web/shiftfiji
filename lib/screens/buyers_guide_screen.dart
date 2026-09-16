import 'package:flutter/material.dart';
import 'package:shiftfiji/constants/app_colors.dart';

class BuyersGuideScreen extends StatelessWidget {
  const BuyersGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: const Text(
          'Fiji Property Buyer Guide',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Banner
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel_rounded, color: AppColors.gold, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Fiji Real Estate Legal Handbook',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Essential legal, tenure, and financial information for local and international property buyers in the Fiji Islands.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Land Tenure Types
            _buildSectionHeader('Understanding Fiji Land Tenures'),
            const SizedBox(height: 12),
            _buildTenureCard(
              title: '1. Freehold Land (~8% of Fiji)',
              badge: 'Highest Ownership',
              badgeColor: AppColors.success,
              description:
                  'Freehold land is the only land in Fiji that can be bought and sold outright with complete ownership. It can be freely transferred to Fiji citizens. Non-residents can purchase freehold residential properties within municipal town boundaries or lots exceeding one acre outside towns for tourism/commercial purposes.',
              icon: Icons.verified_user_rounded,
            ),
            const SizedBox(height: 12),
            _buildTenureCard(
              title: '2. Crown / State Lease (~4% of Fiji)',
              badge: '99-Year Leases',
              badgeColor: AppColors.gold,
              description:
                  'Owned by the Government of Fiji and administered by the Department of Lands. Issued for up to 99-year terms (residential, agricultural, industrial, commercial). Rents are reassessed every 5–10 years. Popular in areas like Fantasy Island and Port Denarau.',
              icon: Icons.account_balance_rounded,
            ),
            const SizedBox(height: 12),
            _buildTenureCard(
              title: '3. iTaukei Native Lease (~88% of Fiji)',
              badge: 'TLTB Administered',
              badgeColor: Colors.blue.shade700,
              description:
                  'Owned by indigenous Fijian landowning clans (Mataqali) and administered exclusively by the iTaukei Land Trust Board (TLTB). Cannot be sold outright, but can be leased for up to 99 years for tourism, residential, or agricultural developments.',
              icon: Icons.people_alt_rounded,
            ),

            const SizedBox(height: 24),

            // Foreign Investment & Land Sales Act
            _buildSectionHeader('Non-Resident & Foreign Buyer Rules'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBullet(
                    'Land Sales Act (Amendment):',
                    'Non-resident individuals cannot purchase vacant residential freehold land inside municipal boundaries without development covenants.',
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(
                    'Building Covenant:',
                    'Foreign purchasers of vacant residential land must complete construction of a dwelling valued at minimum FJD \$250,000 within 24 months of purchase.',
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(
                    'Strata / Apartments:',
                    'Foreign investors can purchase strata-titled apartments, integrated tourism resort villas (e.g. Denarau Island), and commercial properties without dwelling restrictions.',
                  ),
                  const SizedBox(height: 10),
                  _buildBullet(
                    'Reserve Bank of Fiji (RBF):',
                    'All offshore funds brought into Fiji for property transactions must obtain Reserve Bank approval to ensure repatriation rights on future sale proceeds.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Steps to Purchase
            _buildSectionHeader('Step-by-Step Purchase Roadmap'),
            const SizedBox(height: 12),
            _buildStepTile(1, 'Property Selection & Title Search', 'Select your property and engage a licensed Fiji conveyancing solicitor to conduct a title search at the Registrar of Titles Office in Suva.'),
            _buildStepTile(2, 'Sales & Purchase Agreement', 'Sign the standard Fiji Law Society Sales & Purchase Agreement and pay the standard 10% stakeholder deposit into the trust account.'),
            _buildStepTile(3, 'Consent & Approvals', 'Obtain Minister of Lands consent (for Crown Lease) or TLTB consent (for Native Lease), plus Reserve Bank of Fiji clearance for offshore funds.'),
            _buildStepTile(4, 'Settlement & Registration', 'Pay remaining 90% balance at settlement. Your solicitor lodges the transfer deed with the Registrar of Titles for issuance of title.'),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
    );
  }

  Widget _buildTenureCard({
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required IconData icon,
  }) {
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
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5, color: AppColors.textPrimary),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(color: badgeColor, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildBullet(String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• ', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
              children: [
                TextSpan(text: '$title ', style: const TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: body, style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTile(int step, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary,
            child: Text('$step', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
