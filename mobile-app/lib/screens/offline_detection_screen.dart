import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import '../services/image_asset_service.dart';

/// Offline detection screen with crop -> symptom -> disease -> remedy flow
class OfflineDetectionScreen extends StatefulWidget {
  const OfflineDetectionScreen({super.key});

  @override
  State<OfflineDetectionScreen> createState() => _OfflineDetectionScreenState();
}

class _OfflineDetectionScreenState extends State<OfflineDetectionScreen> {
  // Navigation state
  Crop? _selectedCrop;
  List<Symptom> _selectedSymptoms = [];
  Disease? _detectedDisease;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Diagnosis'),
        centerTitle: true,
        elevation: 0,
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
    if (_detectedDisease != null) {
      return _buildDiseaseResult();
    } else if (_selectedCrop != null && _selectedSymptoms.isNotEmpty) {
      return _buildSymptomSelection();
    } else if (_selectedCrop != null) {
      return _buildSymptomSelection();
    } else {
      return _buildCropSelection();
    }
  }

  /// Step 1: Select Crop
  Widget _buildCropSelection() {
    final crops = MockDataService.getCrops();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Select Your Crop',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'What crop are you growing?',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
          ],
        ),

        // Crop grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
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
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCrop = crop;
          _selectedSymptoms = [];
          _detectedDisease = null;
        });
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Stack(
          children: [
            // Background image or gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[300]!, Colors.green[600]!],
                ),
              ),
            ),
            // Crop image or fallback
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ImageAssetService.buildCropImage(
                    cropId: crop.id,
                    cropName: crop.name,
                    size: 80,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    crop.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Step 2: Select Symptoms
  Widget _buildSymptomSelection() {
    final availableDiseases = MockDataService.getDiseasesForCrop(
      _selectedCrop!.id,
    );

    // Get all possible symptoms from diseases for this crop
    final possibleSymptoms = <Symptom>{};
    for (var disease in availableDiseases) {
      final symptoms = MockDataService.getSymptomsForDisease(disease.id);
      possibleSymptoms.addAll(symptoms);
    }

    // Convert to sorted list for consistent ordering
    final symptomList = possibleSymptoms.toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header with back button
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                setState(() {
                  _selectedCrop = null;
                  _selectedSymptoms = [];
                });
              },
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What Symptoms?',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _selectedCrop!.name,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select all symptoms you observe:',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Symptoms checklist
        for (final symptom in symptomList)
          Builder(
            builder: (context) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: isSelected ? 4 : 0,
                  color: isSelected ? Colors.green[50] : Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? Colors.green[600]!
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: ListTile(
                    leading: SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        children: [
                          ImageAssetService.buildSymptomImage(
                            symptomId: symptom.id,
                            symptomName: symptom.name,
                            size: 60,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Checkbox(
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedSymptoms.add(symptom);
                                  } else {
                                    _selectedSymptoms.remove(symptom);
                                  }
                                });
                              },
                              activeColor: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    title: Text(
                      symptom.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(symptom.description),
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSymptoms.remove(symptom);
                        } else {
                          _selectedSymptoms.add(symptom);
                        }
                      });
                    },
                  ),
                ),
              );
            },
          ),

        const SizedBox(height: 24),

        // Analyze button
        if (_selectedSymptoms.isNotEmpty)
          ElevatedButton.icon(
            onPressed: _analyzeSymptoms,
            icon: const Icon(Icons.search),
            label: const Text('Analyze Symptoms'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          )
        else
          ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Select symptoms to continue'),
          ),

        const SizedBox(height: 16),
      ],
    );
  }

  /// Step 3: Show Disease Result
  Widget _buildDiseaseResult() {
    final disease = _detectedDisease!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Back button
        Align(
          alignment: Alignment.topLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _detectedDisease = null;
              });
            },
          ),
        ),

        // Disease card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: Colors.orange[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange[700],
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Possible Disease',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.orange[700],
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            disease.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  disease.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Remedies section
        Text(
          'Recommended Remedies',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        for (final entry in disease.remedies.asMap().entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        const SizedBox(height: 24),

        // Info banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[300]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This is an offline diagnosis based on symptoms. Please consult an agricultural expert for confirmation.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.blue[700]),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _detectedDisease = null;
                    _selectedSymptoms = [];
                    _selectedCrop = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Start Over'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Share functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share feature coming soon')),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
      ],
    );
  }

  /// Analyze symptoms and find matching disease
  void _analyzeSymptoms() {
    final availableDiseases = MockDataService.getDiseasesForCrop(
      _selectedCrop!.id,
    );

    // Score diseases based on symptom matches
    var diseaseScores = <String, int>{};

    for (var disease in availableDiseases) {
      final diseaseSymptoms = MockDataService.getSymptomsForDisease(disease.id);
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
      final disease = MockDataService.getDiseaseById(bestMatchId!);
      setState(() {
        _detectedDisease = disease;
      });
    } else {
      // No match found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No matching disease found. Please consult an expert.'),
        ),
      );
    }
  }
}
