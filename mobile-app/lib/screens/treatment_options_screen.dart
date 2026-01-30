import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';
import 'scan_treatment_screen.dart';
import 'suggested_treatments_screen.dart';

class TreatmentOptionsScreen extends StatefulWidget {
  final String disease;
  final List<String> remedies;
  final String languageCode;

  const TreatmentOptionsScreen({
    super.key,
    required this.disease,
    required this.remedies,
    required this.languageCode,
  });

  @override
  State<TreatmentOptionsScreen> createState() => _TreatmentOptionsScreenState();
}

class _TreatmentOptionsScreenState extends State<TreatmentOptionsScreen> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('treatment_options'))),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _t('treatment_options_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              _buildOptionCard(
                icon: Icons.qr_code_scanner,
                title: _t('scan_treatment_option'),
                subtitle: _t('scan_treatment_option_desc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ScanTreatmentScreen(
                        disease: widget.disease,
                        languageCode: _languageCode,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              _buildOptionCard(
                icon: Icons.medication_outlined,
                title: _t('suggested_treatments_option'),
                subtitle: _t('suggested_treatments_option_desc'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuggestedTreatmentsScreen(
                        disease: widget.disease,
                        remedies: widget.remedies,
                        languageCode: _languageCode,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.green[50],
                child: Icon(icon, color: Colors.green[700]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
