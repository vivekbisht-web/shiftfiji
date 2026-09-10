import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shiftfiji/constants/app_colors.dart';
import 'package:shiftfiji/models/saved_property.dart';
import 'package:shiftfiji/screens/web_view.dart';
import 'package:shiftfiji/services/storage_service.dart';

class SavedTab extends StatefulWidget {
  final Function(int tabIndex)? onNavigateTab;

  const SavedTab({super.key, this.onNavigateTab});

  @override
  State<SavedTab> createState() => _SavedTabState();
}

class _SavedTabState extends State<SavedTab> {
  List<SavedProperty> _savedList = [];

  @override
  void initState() {
    super.initState();
    _loadSaved();
  }

  void _loadSaved() {
    setState(() {
      _savedList = StorageService.getSavedProperties();
    });
  }

  void _removeProperty(SavedProperty property) async {
    await StorageService.removeProperty(property.id);
    _loadSaved();
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
              _loadSaved();
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
        title: const Text(
          'Personal Notes',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              property.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Called agent, inspection this Saturday at 11am...',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
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
              if (mounted) {
                _loadSaved();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Note'),
          ),
        ],
      ),
    );
  }

  void _shareProperty(SavedProperty property) {
    Share.share(
      'Take a look at this property in Fiji: ${property.title} (${property.price})\nLocation: ${property.location}\n${property.url}',
      subject: property.title,
    );
  }

  void _openProperty(SavedProperty property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartWebViewScreen(
          initialUrl: property.url.isNotEmpty ? property.url : 'https://shiftfiji.com/properties',
          title: property.title,
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
        title: Text(
          'Saved Properties (${_savedList.length})',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: _savedList.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: _savedList.length,
              itemBuilder: (context, index) {
                final property = _savedList[index];
                return _buildPropertyCard(property);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 54,
                color: AppColors.goldDark,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Saved Properties Yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Save properties to access them offline, add private notes, or share with friends and family.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => widget.onNavigateTab?.call(0),
              icon: const Icon(Icons.explore_rounded, size: 18),
              label: const Text('Explore Listings'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyCard(SavedProperty property) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Header / Thumbnail Area
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: property.imageUrl != null
                    ? Image.network(
                        property.imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: coverFit,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: property.type == 'Rent' ? const Color(0xFF0F766E) : AppColors.gold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    property.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: property.type == 'Rent' ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.redAccent, size: 20),
                    tooltip: 'Remove',
                    onPressed: () => _removeProperty(property),
                  ),
                ),
              ),
            ],
          ),

          // Content Area
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.price,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  property.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),

                // Personal Notes Box
                if (property.notes.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note_alt_rounded, size: 15, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            property.notes,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),

                // Actions Row
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => _editNotes(property),
                      icon: const Icon(Icons.edit_note_rounded, size: 18, color: AppColors.textSecondary),
                      label: Text(
                        property.notes.isEmpty ? 'Add Note' : 'Edit Note',
                        style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 18, color: AppColors.textSecondary),
                      tooltip: 'Share',
                      onPressed: () => _shareProperty(property),
                    ),
                    ElevatedButton(
                      onPressed: () => _openProperty(property),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BoxFit get coverFit => BoxFit.cover;

  Widget _buildPlaceholderImage() {
    return Container(
      height: 160,
      width: double.infinity,
      color: AppColors.primaryLight,
      child: const Center(
        child: Icon(
          Icons.apartment_rounded,
          size: 48,
          color: Colors.white38,
        ),
      ),
    );
  }
}
