import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

/// Modern Material 3 crop selection screen
/// Designed with clean, minimal aesthetics following contemporary mobile UI standards
class CropSelectionScreen extends StatefulWidget {
  final String? initialLanguageCode;
  final Function(Crop) onCropSelected;

  const CropSelectionScreen({
    super.key,
    this.initialLanguageCode,
    required this.onCropSelected,
  });

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  final LocalizationService _localizationService = LocalizationService();

  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};
  List<LanguagePack> _languagePacks = [];
  Crop? _selectedCrop;

  // Design constants - Material 3 & Modern UX
  static const double _horizontalPadding = 16.0;
  static const double _gridGap = 16.0;
  static const double _sectionVerticalGap = 24.0;
  static const double _borderRadius = 20.0;
  // static const double _cropCardLabelPadding = 16.0;

  @override
  void initState() {
    super.initState();
    _languageCode =
        widget.initialLanguageCode ?? AppConstants.fallbackLanguageCode;
    _loadLocalizationPacks();
  }

  Future<void> _loadLocalizationPacks() async {
    await _localizationService.loadAll();
    final packs = _localizationService.languagePacks;
    if (!mounted) return;
    setState(() {
      _languagePacks = packs;
      if (!_localizationService.hasLanguage(_languageCode) &&
          packs.isNotEmpty) {
        _languageCode = packs.first.code;
      }
      _strings = _localizationService.getPack(_languageCode)?.strings ?? {};
    });
  }

  void _setLanguage(String code) {
    setState(() {
      _languageCode = code;
      _strings = _localizationService.getPack(_languageCode)?.strings ?? {};
    });
  }

  String _t(String key) {
    return _strings[key] ?? _localizationService.translate(_languageCode, key);
  }

  void _onCropSelected(Crop crop) {
    setState(() {
      _selectedCrop = crop;
    });
    // Haptic feedback for selection
    HapticFeedback.lightImpact();
    // Call parent callback
    widget.onCropSelected(crop);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('offline_select_crop_title')),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        actions: [
          if (_languagePacks.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: _setLanguage,
              tooltip: _t('select_language'),
              icon: const Icon(Icons.language),
              itemBuilder: (context) {
                return _languagePacks
                    .map(
                      (pack) => PopupMenuItem<String>(
                        value: pack.code,
                        child: Text(pack.name),
                      ),
                    )
                    .toList();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section with improved visual hierarchy
                Padding(
                  padding: const EdgeInsets.only(top: _sectionVerticalGap),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main title with modern typography
                      Text(
                        _t('offline_select_crop_title'),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      // Subtitle with warm, inviting tone
                      Text(
                        _t('offline_select_crop_subtitle'),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: _sectionVerticalGap),

                // Modern crop grid
                _buildCropGrid(),

                const SizedBox(height: _sectionVerticalGap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the grid of crop cards with modern spacing
  Widget _buildCropGrid() {
    final crops = OfflineMockDataService.getCrops();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75, // Vertical emphasis for premium feel
        crossAxisSpacing: _gridGap,
        mainAxisSpacing: _gridGap,
      ),
      itemCount: crops.length,
      itemBuilder: (context, index) {
        final crop = crops[index];
        return _buildModernCropCard(crop);
      },
    );
  }

  /// Builds a single modern crop card with Material 3 styling
  Widget _buildModernCropCard(Crop crop) {
    final isSelected = _selectedCrop?.id == crop.id;

    return AnimatedScale(
      scale: isSelected ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_borderRadius),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _onCropSelected(crop),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // FULL-BLEED IMAGE (no card, no padding)
                ImageAssetService.buildCropImage(
                  cropId: crop.id,
                  cropName: _t(crop.nameKey),
                  size: 300,
                ),

                // Subtle gradient for text legibility
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.55),
                        ],
                      ),
                    ),
                  ),
                ),

                // Crop name OVER image
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: Text(
                    _t(crop.nameKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                // Selection indicator (border, not shadow)
                if (isSelected)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(_borderRadius),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Helper method to get crop description/category
  /// Can be extended with crop model properties or localization strings
  // String _getCropDescription(String cropId) {
  //   final descriptions = {
  //     'rice': 'Cereal grain',
  //     'wheat': 'Cereal grain',
  //     'maize': 'Cereal crop',
  //     'cotton': 'Cash crop',
  //     'tomato': 'Vegetable',
  //     'potato': 'Root vegetable',
  //     'groundnut': 'Legume',
  //     'sugarcane': 'Cash crop',
  //   };
  //   return descriptions[cropId] ?? '';
  // }
}
