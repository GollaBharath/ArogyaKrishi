import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

/// Modern, image-first crop selection carousel
/// Inspired by Revolut, Apple Health, Calm aesthetic
/// Full-bleed images, minimal text, spacious layout
class ModernCropCarouselScreen extends StatefulWidget {
  final String? initialLanguageCode;
  final Function(Crop) onCropSelected;

  const ModernCropCarouselScreen({
    super.key,
    this.initialLanguageCode,
    required this.onCropSelected,
  });

  @override
  State<ModernCropCarouselScreen> createState() =>
      _ModernCropCarouselScreenState();
}

class _ModernCropCarouselScreenState extends State<ModernCropCarouselScreen> {
  final LocalizationService _localizationService = LocalizationService();
  late PageController _pageController;

  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};
  List<LanguagePack> _languagePacks = [];
  List<Crop> _crops = [];
  int _currentIndex = 0;

  // Design tokens
  static const double _imageBorderRadius = 24.0;
  static const double _contentPadding = 24.0;
  static const double _spaceBetweenSections = 32.0;
  static const double _buttonHeight = 52.0;

  @override
  void initState() {
    super.initState();
    _languageCode =
        widget.initialLanguageCode ?? AppConstants.fallbackLanguageCode;
    _pageController = PageController();
    _loadData();
  }

  Future<void> _loadData() async {
    await _localizationService.loadAll();
    final packs = _localizationService.languagePacks;
    final crops = OfflineMockDataService.getCrops();

    if (!mounted) return;
    setState(() {
      _languagePacks = packs;
      if (!_localizationService.hasLanguage(_languageCode) &&
          packs.isNotEmpty) {
        _languageCode = packs.first.code;
      }
      _strings = _localizationService.getPack(_languageCode)?.strings ?? {};
      _crops = crops;
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

  void _selectCrop(Crop crop) {
    HapticFeedback.mediumImpact();
    widget.onCropSelected(crop);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_crops.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(_t('offline_select_crop_title')),
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentCrop = _crops[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('offline_select_crop_title')),
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
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
        child: Column(
          children: [
            // Image carousel (full-bleed, 40% screen height)
            Expanded(
              flex: 5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: _crops.length,
                itemBuilder: (context, index) {
                  final crop = _crops[index];
                  return _buildCropImageCard(crop);
                },
              ),
            ),

            // Content section: crop name, description, CTA
            Expanded(flex: 4, child: _buildCropInfoSection(currentCrop)),
          ],
        ),
      ),
    );
  }

  /// Full-bleed image card with subtle gradient overlay
  Widget _buildCropImageCard(Crop crop) {
    return Container(
      margin: EdgeInsets.zero,
      child: Stack(
        children: [
          // Full-bleed image, clipped to bottom corners only
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(_imageBorderRadius),
              bottomRight: Radius.circular(_imageBorderRadius),
            ),
            child: Container(
              color: Colors.grey[100],
              child: ImageAssetService.buildCropImage(
                cropId: crop.id,
                cropName: _t(crop.nameKey),
                size: 400,
              ),
            ),
          ),

          // Subtle gradient overlay for text readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.12)],
                ),
              ),
            ),
          ),

          // Page indicator dots (minimal, subtle)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _crops.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: index == _currentIndex ? 8 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(
                      index == _currentIndex ? 0.95 : 0.35,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Clean, spacious content section below image
  Widget _buildCropInfoSection(Crop crop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: _contentPadding,
        vertical: _contentPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large, bold crop name (32sp)
          Text(
            _t(crop.nameKey),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Descriptive text (light gray, readable)
          Text(
            _getCropDescription(crop.id),
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600],
              height: 1.6,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: _spaceBetweenSections),

          // Full-width CTA button
          SizedBox(
            width: double.infinity,
            height: _buttonHeight,
            child: FilledButton(
              onPressed: () => _selectCrop(crop),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                _t('continue'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Back button (text link, subtle)
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _t('back'),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Crop descriptions with farming context
  String _getCropDescription(String cropId) {
    final descriptions = {
      'rice':
          'Cereal grain staple. Thrives in monsoon seasons with water-rich soil. Key crop in Asia.',
      'wheat':
          'Winter crop with high nutrient demand. Grows best in cool climates. Golden harvest.',
      'maize':
          'Fast-growing cereal crop. Versatile use: food, feed, industrial. High yield potential.',
      'cotton':
          'Cash crop for textiles. Heat-loving plant. Requires careful pest management.',
      'tomato':
          'High-value vegetable. Demands consistent water and nutrients. Year-round potential.',
      'potato':
          'Root vegetable, staple food. Stores well. Different varieties for different seasons.',
      'groundnut':
          'Oil-rich legume. Improves soil nitrogen. Drought-tolerant crop. Good income source.',
      'sugarcane':
          'High-demand cash crop. Long growing season. Processing adds value. Labor intensive.',
    };
    return descriptions[cropId] ??
        'Learn about this crop and its growing requirements.';
  }
}
