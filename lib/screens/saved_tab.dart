import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/models/property.dart';
import 'package:shiftfiji/models/saved_property.dart';
import 'package:shiftfiji/screens/property_compare_screen.dart';
import 'package:shiftfiji/screens/property_detail_screen.dart';
import 'package:shiftfiji/services/property_service.dart';
import 'package:shiftfiji/services/storage_service.dart';

class SavedTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const SavedTab({super.key, this.onNavigateTab});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<SavedProperty> _savedList = [];
  List<Property> _compareList = [];
  List<Property> _recentList = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAll() {
    setState(() {
      _savedList = StorageService.getSavedProperties();
      _compareList = StorageService.getComparisonProperties();
      _recentList = StorageService.getRecentlyViewed();
    });
  }

  void _removeProperty(SavedProperty property) async {
    await StorageService.removeProperty(property.id);
    _loadAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${property.title} removed from saved.'),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.gold,
            onPressed: () async {
              await StorageService.saveProperty(property);
              _loadAll();
            },
          ),
        ),
      );
    }
  }

  void _editNotes(SavedProperty property) {
    final noteController = TextEditingController(text: property.notes);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Personal Notes', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Called agent Seru, inspection this Saturday at 11am...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newNotes = noteController.text.trim();
              Navigator.pop(context);
              await StorageService.updatePropertyNotes(property.id, newNotes);
              _loadAll();
            },
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _openNativeProperty(String propertyId, String fallbackTitle) {
    final p = PropertyService.getById(propertyId);
    if (p != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PropertyDetailScreen(property: p)),
      ).then((_) => _loadAll());
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
          'Saved & Portfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          if (_compareList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.compare_arrows_rounded, color: AppColors.gold),
              tooltip: 'Compare Selected',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PropertyCompareScreen()),
                ).then((_) => _loadAll());
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: [
            Tab(text: 'Saved (${_savedList.length})'),
            Tab(text: 'Compare (${_compareList.length})'),
            Tab(text: 'Recent (${_recentList.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSavedListTab(),
          _buildCompareTab(),
          _buildRecentTab(),
        ],
      ),
    );
  }

  Widget _buildSavedListTab() {
    if (_savedList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_outline_rounded,
        title: 'No Saved Properties',
        subtitle: 'Tap the heart icon on any Fiji property listing to save it to your personal portfolio and add private notes.',
        buttonLabel: 'Explore Properties',
        onButton: () => widget.onNavigateTab?.call(0),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _savedList.length,
      itemBuilder: (context, index) {
        final item = _savedList[index];
        return _buildSavedCard(item);
      },
    );
  }

  Widget _buildSavedCard(SavedProperty item) {
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
        onTap: () => _openNativeProperty(item.id, item.title),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: 90,
                            height: 90,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 90,
                              height: 90,
                              color: AppColors.primaryLight,
                              child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
                            ),
                          )
                        : Container(
                            width: 90,
                            height: 90,
                            color: AppColors.primaryLight,
                            child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.price,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.primary),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // Delete Button
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error),
                    onPressed: () => _removeProperty(item),
                  ),
                ],
              ),

              // Notes Display if available
              if (item.notes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.notes,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Divider(height: 18),

              // Action Toolbar
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editNotes(item),
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: Text(item.notes.isEmpty ? 'Add Note' : 'Edit Note', style: const TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 6),
                  TextButton.icon(
                    onPressed: () => Share.share('Check out ${item.title} (${item.price}) on Shift Fiji: ${item.url}'),
                    icon: const Icon(Icons.share_rounded, size: 15),
                    label: const Text('Share', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompareTab() {
    if (_compareList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.compare_arrows_rounded,
        title: 'Comparison Matrix Empty',
        subtitle: 'Add up to 3 Fiji properties to your comparison list to inspect prices, land tenure, specs, and repayments side-by-side.',
        buttonLabel: 'Browse Properties',
        onButton: () => widget.onNavigateTab?.call(0),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_compareList.length} properties selected (Max 3)',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PropertyCompareScreen()),
                  ).then((_) => _loadAll());
                },
                icon: const Icon(Icons.compare_arrows_rounded, size: 16),
                label: const Text('Open Matrix'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _compareList.length,
            itemBuilder: (context, idx) {
              final p = _compareList[idx];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(p.mainImage, width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  title: Text(p.priceDisplay, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                  subtitle: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.error),
                    onPressed: () async {
                      await StorageService.toggleComparison(p.id);
                      _loadAll();
                    },
                  ),
                  onTap: () => _openNativeProperty(p.id, p.title),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTab() {
    if (_recentList.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history_rounded,
        title: 'No Recently Viewed',
        subtitle: 'Properties you inspect will automatically appear here for quick offline reference.',
        buttonLabel: 'Search Listings',
        onButton: () => widget.onNavigateTab?.call(1),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _recentList.length,
      itemBuilder: (context, idx) {
        final p = _recentList[idx];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(p.mainImage, width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(p.priceDisplay, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
            subtitle: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
            onTap: () => _openNativeProperty(p.id, p.title),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonLabel,
    required VoidCallback onButton,
  }) {
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
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onButton,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}
