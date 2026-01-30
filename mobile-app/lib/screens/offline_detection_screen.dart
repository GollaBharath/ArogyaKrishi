import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import 'offline_detection_result_screen.dart';

/// Offline detection screen with crop -> symptom -> disease -> remedy flow
class OfflineDetectionScreen extends StatefulWidget {
  final String? initialLanguageCode;

  const OfflineDetectionScreen({super.key, this.initialLanguageCode});

  @override
  State<OfflineDetectionScreen> createState() => _OfflineDetectionScreenState();
}

class _OfflineDetectionScreenState extends State<OfflineDetectionScreen> {
  final LocalizationService _localizationService = LocalizationService();

  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};
  List<LanguagePack> _languagePacks = [];

  // Navigation state
  Crop? _selectedCrop;
  List<Symptom> _selectedSymptoms = [];

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

  String _tWithVars(String key, Map<String, String> vars) {
    var value = _t(key);
    vars.forEach((k, v) {
      value = value.replaceAll('{$k}', v);
    });
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedCrop != null) {
              setState(() {
                _selectedCrop = null;
                _selectedSymptoms = [];
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _selectedCrop != null
              ? _t('offline_identify_symptoms_title')
              : _t('offline_select_crop_title'),
        ),
        centerTitle: true,
        elevation: 0,
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
            padding: const EdgeInsets.all(16.0),
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_selectedCrop != null && _selectedSymptoms.isNotEmpty) {
      return _buildSymptomSelection();
    } else if (_selectedCrop != null) {
      return _buildSymptomSelection();
    } else {
      return _buildCropSelection();
    }
  }

  /// Step 1: Select Crop
  Widget _buildCropSelection() {
    final crops = OfflineMockDataService.getCrops();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),

        // Modern crop grid with full-bleed images
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75, // Vertical emphasis
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: crops.length,
          itemBuilder: (context, index) {
            final crop = crops[index];
            return _buildCropCard(crop);
          },
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCropCard(Crop crop) {
    final isSelected = _selectedCrop?.id == crop.id;

    return AnimatedScale(
      scale: isSelected ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedCrop = crop;
                _selectedSymptoms = [];
              });
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Full-bleed crop image
                ImageAssetService.buildCropImage(
                  cropId: crop.id,
                  cropName: _t(crop.nameKey),
                  size: 300,
                ),

                // Gradient overlay for text legibility
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

                // Crop name over image
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

                // Selection indicator
                if (isSelected)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(0.1),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
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

  /// Step 2: Select Symptoms
  Widget _buildSymptomSelection() {
    final availableDiseases = OfflineMockDataService.getDiseasesForCrop(
      _selectedCrop!.id,
    );

    // Get all possible symptoms from diseases for this crop
    final possibleSymptoms = <Symptom>{};
    for (var disease in availableDiseases) {
      final symptoms = OfflineMockDataService.getSymptomsForDisease(disease.id);
      possibleSymptoms.addAll(symptoms);
    }

    // Convert to sorted list for consistent ordering
    final symptomList = possibleSymptoms.toList()
      ..sort((a, b) => _t(a.nameKey).compareTo(_t(b.nameKey)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        // Crop name subheading
        Text(
          _t(_selectedCrop!.nameKey),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.green[700],
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 16),
        // Prompt text
        Text(
          _tWithVars('offline_symptom_prompt', {
            'crop': _t(_selectedCrop!.nameKey),
          }),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Symptoms grid - image-centric
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.0,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: symptomList.length,
          itemBuilder: (context, index) {
            final symptom = symptomList[index];
            final isSelected = _selectedSymptoms.any((s) => s.id == symptom.id);
            return _buildSymptomCard(symptom, isSelected);
          },
        ),

        const SizedBox(height: 24),

        // Analyze button
        if (_selectedSymptoms.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(
                  _tWithVars('offline_selected_symptoms', {
                    'symptoms': _selectedSymptoms
                        .map((s) => _t(s.nameKey))
                        .join(', '),
                  }),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _analyzeSymptoms,
                icon: const Icon(Icons.search),
                label: Text(_t('offline_analyze_symptoms')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              _t('offline_select_symptoms_hint'),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSymptomCard(Symptom symptom, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSymptoms.removeWhere((s) => s.id == symptom.id);
          } else {
            _selectedSymptoms.add(symptom);
          }
        });
      },
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.green[600]! : Colors.grey[300]!,
            width: isSelected ? 3 : 1,
          ),
        ),
        color: isSelected ? Colors.green[50] : Colors.white,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image background
            ClipRRect(
              borderRadius: BorderRadius.circular(11),
              child: ImageAssetService.buildSymptomImage(
                symptomId: symptom.id,
                imagePath: symptom.imagePath,
                symptomName: _t(symptom.nameKey),
                size: 200,
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.4),
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkmark indicator
                  if (isSelected)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  // Text at bottom
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t(symptom.nameKey),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _t(symptom.descriptionKey),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Analyze symptoms and find matching disease
  void _analyzeSymptoms() {
    final availableDiseases = OfflineMockDataService.getDiseasesForCrop(
      _selectedCrop!.id,
    );

    // Score diseases based on symptom matches
    var diseaseScores = <String, int>{};

    for (var disease in availableDiseases) {
      final diseaseSymptoms = OfflineMockDataService.getSymptomsForDisease(
        disease.id,
      );
      int matchCount = 0;

      for (var symptom in _selectedSymptoms) {
        if (diseaseSymptoms.any((s) => s.id == symptom.id)) {
          matchCount++;
        }
      }

      diseaseScores[disease.id] = matchCount;
    }

    // Find disease with highest match
    String? bestMatchId;
    int maxMatches = 0;

    diseaseScores.forEach((diseaseId, matches) {
      if (matches > maxMatches) {
        maxMatches = matches;
        bestMatchId = diseaseId;
      }
    });

    if (bestMatchId != null && maxMatches > 0) {
      final disease = OfflineMockDataService.getDiseaseById(bestMatchId!);
      // Navigate to result screen instead of showing inline
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OfflineDetectionResultScreen(
            disease: disease,
            languageCode: _languageCode,
          ),
        ),
      );
    } else {
      // No match found
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t('offline_no_match'))));
    }
  }
}
