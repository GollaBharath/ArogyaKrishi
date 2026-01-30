import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import 'suggested_treatments_screen.dart';

/// Full-page detection result screen for online mode
class DetectionResultScreen extends StatefulWidget {
  final DetectionResult result;
  final String languageCode;

  const DetectionResultScreen({
    super.key,
    required this.result,
    required this.languageCode,
  });

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  final LocalizationService _localizationService = LocalizationService();
  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode;
    _loadLocalization();
  }

  Future<void> _loadLocalization() async {
    await _localizationService.loadAll();
    if (!mounted) return;
    setState(() {
      if (!_localizationService.hasLanguage(_languageCode)) {
        _languageCode = AppConstants.fallbackLanguageCode;
      }
      _strings = _localizationService.getPack(_languageCode)?.strings ?? {};
    });
  }

  String _t(String key) {
    return _strings[key] ?? _localizationService.translate(_languageCode, key);
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(value, style: TextStyle(color: Colors.grey[700])),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;

    return Scaffold(
      appBar: AppBar(
        title: Text(_t('detection_result')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResultRow(_t('crop'), result.crop),
                      _buildResultRow(_t('disease'), result.disease),
                      _buildResultRow(
                        _t('confidence'),
                        '${(result.confidence * 100).toStringAsFixed(1)}%',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Remedies section
              Text(
                _t('remedies'),
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: result.remedies
                        .map(
                          (remedy) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '• ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Expanded(child: Text(remedy)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Action buttons
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuggestedTreatmentsScreen(
                        disease: result.disease,
                        remedies: result.remedies,
                        languageCode: _languageCode,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_t('treatment_options')),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(_t('back_to_home')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
