import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import '../models/pesticide_store.dart';
import '../services/api_service.dart';
import '../utils/constants.dart';
import '../utils/localization.dart';

class SuggestedTreatmentsScreen extends StatefulWidget {
  final String disease;
  final List<String> remedies;
  final String languageCode;

  const SuggestedTreatmentsScreen({
    super.key,
    required this.disease,
    required this.remedies,
    required this.languageCode,
  });

  @override
  State<SuggestedTreatmentsScreen> createState() =>
      _SuggestedTreatmentsScreenState();
}

class _SuggestedTreatmentsScreenState extends State<SuggestedTreatmentsScreen> {
  final ApiService _apiService = ApiService();
  final LocalizationService _localizationService = LocalizationService();

  bool _isLoadingRemedies = false;
  bool _isLoadingStores = false;
  String? _errorMessage;
  String? _locationError;
  String _languageCode = AppConstants.fallbackLanguageCode;
  Map<String, String> _strings = {};
  List<String> _remedies = [];
  List<PesticideStore> _stores = [];
  String _displayDisease = '';

  @override
  void initState() {
    super.initState();
    _languageCode = widget.languageCode;
    _remedies = widget.remedies;
    _displayDisease = widget.disease;
    _loadLocalization();
    _loadSuggestedTreatments();
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

  Future<void> _loadSuggestedTreatments() async {
    // Load remedies and stores in parallel, but update UI separately
    _loadRemedies();
    _loadStores();
  }

  Future<void> _loadRemedies() async {
    setState(() {
      _isLoadingRemedies = true;
      _errorMessage = null;
    });

    try {
      // Fetch remedies only (fast, local data)
      final response = await _apiService.getSuggestedTreatments(
        disease: widget.disease,
        language: _languageCode,
        lat: null, // Don't fetch stores yet
        lng: null,
      );

      if (!mounted) return;
      setState(() {
        _isLoadingRemedies = false;
        _remedies = response.remedies;
        _displayDisease = response.disease;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingRemedies = false;
        _errorMessage = _t('unexpected_error');
      });
    }
  }

  Future<void> _loadStores() async {
    setState(() {
      _isLoadingStores = true;
      _locationError = null;
    });

    try {
      final position = await _getCurrentPosition();
      final lat = position?.latitude;
      final lng = position?.longitude;

      if (lat == null || lng == null) {
        if (!mounted) return;
        setState(() {
          _isLoadingStores = false;
          _locationError = _t('location_unavailable');
        });
        return;
      }

      // Fetch stores (slow, external API)
      final response = await _apiService.getSuggestedTreatments(
        disease: widget.disease,
        language: _languageCode,
        lat: lat,
        lng: lng,
      );

      if (!mounted) return;
      setState(() {
        _isLoadingStores = false;
        _stores = response.stores;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingStores = false;
        _locationError = _t('location_unavailable');
      });
    }
  }

  Future<Position?> _getCurrentPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _locationError = _t('location_disabled'));
        return null;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        setState(() => _locationError = _t('location_permission_denied'));
        return null;
      }

      if (permission == LocationPermission.deniedForever) {
        setState(
          () => _locationError = _t('location_permission_denied_forever'),
        );
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      setState(() => _locationError = _t('location_unavailable'));
      return null;
    }
  }

  Future<void> _openMaps(PesticideStore store) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}&travelmode=driving',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t('maps_open_failed'))));
    }
  }

  Future<void> _openMapsSearch() async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=pesticide+shop+near+me',
    );

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_t('maps_open_failed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_t('suggested_treatments'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDiseaseHeader(),
              const SizedBox(height: 16),
              _buildRemediesCard(),
              const SizedBox(height: 16),
              _buildStoresSection(),
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
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.spa, color: Colors.orange[700]),
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
                Text(_displayDisease),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemediesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('suggested_treatments'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          if (_isLoadingRemedies)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
          else if (_remedies.isEmpty)
            Text(_t('no_suggestions_found'))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _remedies
                  .map(
                    (remedy) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('• $remedy'),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildStoresSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _t('nearest_pesticide_stores'),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (_locationError != null)
          Text(_locationError!, style: TextStyle(color: Colors.orange[700]))
        else if (_errorMessage != null)
          Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))
        else if (_isLoadingStores)
          const Center(child: CircularProgressIndicator())
        else if (_stores.isEmpty)
          Card(
            elevation: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('no_stores_found')),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: _openMapsSearch,
                      icon: const Icon(Icons.map_outlined),
                      label: Text(_t('open_in_maps')),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Column(children: _visibleStores().map(_buildStoreCard).toList()),
      ],
    );
  }

  List<PesticideStore> _visibleStores() {
    return _stores.take(3).toList();
  }

  Widget _buildStoreCard(PesticideStore store) {
    final distanceText = store.distanceKm == null
        ? null
        : '${store.distanceKm!.toStringAsFixed(1)} km';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              store.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            if (store.address != null && store.address!.isNotEmpty)
              Text(store.address!),
            if (distanceText != null) ...[
              const SizedBox(height: 4),
              Text(distanceText, style: TextStyle(color: Colors.grey[700])),
            ],
            if (store.phone != null && store.phone!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text('${_t('contact')}: ${store.phone}'),
            ],
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openMaps(store),
                icon: const Icon(Icons.map_outlined),
                label: Text(_t('open_in_maps')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
