import 'dart:io';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/image_service.dart';
import '../models/scan_treatment_result.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

class ScanTreatmentScreen extends StatefulWidget {
  final String disease;
  final String languageCode;

  const ScanTreatmentScreen({
    super.key,
    required this.disease,
    required this.languageCode,
  });

  @override
  State<ScanTreatmentScreen> createState() => _ScanTreatmentScreenState();
}

class _ScanTreatmentScreenState extends State<ScanTreatmentScreen> {
  final ImageService _imageService = ImageService();
  final ApiService _apiService = ApiService();
  final LocalizationService _localizationService = LocalizationService();
  final TextEditingController _itemLabelController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  String? _errorMessage;
  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};
  ScanTreatmentResult? _result;

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

  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(_t('take_photo')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(_t('choose_from_gallery')),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final image = await _imageService.pickFromCamera();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _showPermissionDialog();
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final image = await _imageService.pickFromGallery();
      if (image != null) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_t('permission_required')),
          content: Text(_t('permission_body')),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_t('cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _imageService.openSystemSettings();
              },
              child: Text(_t('open_settings')),
            ),
          ],
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _scanTreatment() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = _t('no_image_selected');
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _apiService.scanTreatment(
        imageFile: _selectedImage!,
        disease: widget.disease,
        itemLabel: _itemLabelController.text,
        language: _languageCode,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _result = result;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = '${_t('error_detection_failed')}: ${e.message}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '${_t('unexpected_error')}: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _itemLabelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('scan_treatment')), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDiseaseHeader(),
              const SizedBox(height: 16),
              if (_selectedImage != null) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Container(
                        constraints: const BoxConstraints(maxHeight: 300),
                        child: Center(
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: _showImageSourceDialog,
                icon: const Icon(Icons.add_a_photo),
                label: Text(_t('scan_item')),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _t('item_name'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _itemLabelController,
                decoration: InputDecoration(
                  hintText: _t('item_name_hint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    border: Border.all(color: Colors.red.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red[700]),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _scanTreatment,
                icon: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      )
                    : const Icon(Icons.medical_services),
                label: Text(
                  _isLoading ? _t('checking') : _t('check_treatment'),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                _buildFeedbackCard(_result!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiseaseHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.local_hospital, color: Colors.blue[700]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('disease'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(widget.disease),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ScanTreatmentResult result) {
    final badgeColor = result.willCure ? Colors.green : Colors.orange;
    final badgeText = result.willCure
        ? _t('will_cure_yes')
        : _t('will_cure_no');

    // Parse feedback to separate main message and suggestions
    final feedbackParts = result.feedback.split('\n\n');
    final mainFeedback = feedbackParts[0];
    final suggestions = feedbackParts.length > 1 ? feedbackParts[1] : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _t('treatment_feedback'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            mainFeedback,
            style: TextStyle(
              fontSize: 14,
              color: result.willCure ? Colors.green[900] : Colors.orange[900],
            ),
          ),
          if (suggestions != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestions,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
