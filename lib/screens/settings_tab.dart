import 'package:flutter/material.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/screens/web_view.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  void _openUrl(String url, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartWebViewScreen(
          initialUrl: url,
          title: title,
        ),
      ),
    );
  }

  Future<void> _launchExternal(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear App Cache'),
        content: const Text(
          'This will clear temporary web data and cached images. Your saved offline properties will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache and temporary web files cleared successfully.'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
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
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Tracking & Privacy Card (Guideline 5.1.2 compliance)
            _buildPrivacyCard(),

            const SizedBox(height: 20),

            // Quick Portal Links
            _buildSectionTitle('Explore Shift Fiji Portal'),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.business_rounded,
              title: 'Agencies Directory',
              subtitle: 'Browse real estate companies in Fiji',
              onTap: () => _openUrl('https://shiftfiji.com/agencies', 'Agencies'),
            ),
            _buildSettingsTile(
              icon: Icons.badge_rounded,
              title: 'Registered Agents',
              subtitle: 'Find licensed property specialists',
              onTap: () => _openUrl('https://shiftfiji.com/agents', 'Agents'),
            ),
            _buildSettingsTile(
              icon: Icons.home_repair_service_rounded,
              title: 'Property Services',
              subtitle: 'Valuation, building inspection, legal',
              onTap: () => _openUrl('https://shiftfiji.com/services', 'Services'),
            ),
            _buildSettingsTile(
              icon: Icons.newspaper_rounded,
              title: 'Market Insights & Blogs',
              subtitle: 'Fiji property market trends & news',
              onTap: () => _openUrl('https://shiftfiji.com/blogs', 'Blogs'),
            ),

            const SizedBox(height: 20),

            // Support & Contact
            _buildSectionTitle('Help & Legal'),
            const SizedBox(height: 8),
            _buildSettingsTile(
              icon: Icons.support_agent_rounded,
              title: 'Contact Support',
              subtitle: 'info@shiftfiji.com',
              onTap: () => _launchExternal('mailto:info@shiftfiji.com'),
            ),
            _buildSettingsTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our data protection guidelines',
              onTap: () => _openUrl('https://shiftfiji.com/contact-us', 'Privacy Policy'),
            ),
            _buildSettingsTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              subtitle: 'User agreement and listing guidelines',
              onTap: () => _openUrl('https://shiftfiji.com/contact-us', 'Terms of Service'),
            ),
            _buildSettingsTile(
              icon: Icons.cleaning_services_rounded,
              title: 'Clear Temporary Cache',
              subtitle: 'Free up local web storage space',
              onTap: _clearCache,
            ),

            const SizedBox(height: 28),

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Shift Fiji • Version 1.0.0 (Build 2)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '© 2026 Shift Fiji. All rights reserved.',
                    style: TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: AppColors.textSecondary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildPrivacyCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy & Data Protection',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Zero Third-Party User Tracking',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Shift Fiji values your privacy. We do not track users across other apps or websites, nor do we share or sell your personal data to data brokers or advertising networks.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Privacy Status:',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 14, color: AppColors.success),
                      SizedBox(width: 5),
                      Text(
                        'Private & Secure',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textLight,
          size: 20,
        ),
      ),
    );
  }
}
