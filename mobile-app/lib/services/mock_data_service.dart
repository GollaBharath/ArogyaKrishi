/// Mock data service for offline mode
///
/// This service provides crop, disease, and symptom data for offline detection.
/// To add or modify data, edit the maps below directly.
///
/// - Crops: Map of crop IDs to crop names
/// - Symptoms: Map of symptom IDs to symptom names
/// - Diseases: Map of disease IDs to disease data (name, description, remedies)
/// - CropDiseases: Maps crops to their associated diseases
/// - DiseaseSymptoms: Maps diseases to their symptoms

class Crop {
  final String id;
  final String name;

  Crop({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Crop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Symptom {
  final String id;
  final String name;
  final String description;

  Symptom({required this.id, required this.name, required this.description});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Symptom && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class Disease {
  final String id;
  final String name;
  final String description;
  final List<String> remedies; // List of remedy descriptions

  Disease({
    required this.id,
    required this.name,
    required this.description,
    required this.remedies,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Disease && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class MockDataService {
  /// ============================================================
  /// CROPS DATA
  /// Add or modify crops here
  /// ============================================================
  static const Map<String, String> crops = {
    'rice': 'Rice',
    'wheat': 'Wheat',
    'cotton': 'Cotton',
    'tomato': 'Tomato',
    'potato': 'Potato',
    'groundnut': 'Groundnut',
    'sugarcane': 'Sugarcane',
    'maize': 'Maize',
  };

  /// ============================================================
  /// SYMPTOMS DATA
  /// Add or modify symptoms here
  /// ============================================================
  static const Map<String, Map<String, String>> symptoms = {
    'yellow_leaves': {
      'name': 'Yellow Leaves',
      'description': 'Leaves are turning yellow',
    },
    'brown_spots': {
      'name': 'Brown Spots',
      'description': 'Brown spots or patches on leaves',
    },
    'wilting': {
      'name': 'Wilting',
      'description': 'Plant leaves wilting or drooping',
    },
    'powdery_coating': {
      'name': 'Powdery Coating',
      'description': 'White or grayish powdery coating on leaves',
    },
    'root_rot': {
      'name': 'Root Rot',
      'description': 'Roots appear black or mushy',
    },
    'leaf_curl': {'name': 'Leaf Curl', 'description': 'Leaves curling inward'},
    'stem_rot': {
      'name': 'Stem Rot',
      'description': 'Stem showing dark discoloration',
    },
    'aphids': {
      'name': 'Aphids/Insects',
      'description': 'Small insects visible on plants',
    },
  };

  /// ============================================================
  /// DISEASES DATA
  /// Add or modify diseases here
  /// Format: 'disease_id': {'name': 'Disease Name', 'description': '', 'remedies': [...]}
  /// ============================================================
  static const Map<String, Map<String, dynamic>> diseases = {
    'blast': {
      'name': 'Blast',
      'description': 'Fungal disease affecting rice',
      'remedies': [
        'Spray with Mancozeb (0.2%) or Carbendazim (0.1%)',
        'Remove infected leaves and burn them',
        'Ensure proper drainage in fields',
        'Avoid over-watering and heavy nitrogen application',
      ],
    },
    'leaf_spot': {
      'name': 'Leaf Spot',
      'description': 'Fungal infection causing spots on leaves',
      'remedies': [
        'Spray Copper Oxychloride (3%) solution',
        'Remove and destroy infected leaves',
        'Maintain adequate spacing between plants',
        'Avoid overhead watering',
      ],
    },
    'powdery_mildew': {
      'name': 'Powdery Mildew',
      'description': 'Fungal disease with white powdery coating',
      'remedies': [
        'Spray with Sulfur powder or Karathane',
        'Ensure good air circulation',
        'Avoid overcrowding of plants',
        'Spray in early morning or late evening',
      ],
    },
    'root_rot': {
      'name': 'Root Rot',
      'description': 'Fungal infection of roots',
      'remedies': [
        'Improve field drainage',
        'Use Trichoderma treatment on seeds',
        'Crop rotation recommended',
        'Avoid waterlogging',
      ],
    },
    'early_blight': {
      'name': 'Early Blight',
      'description': 'Common potato and tomato disease',
      'remedies': [
        'Remove lower infected leaves',
        'Spray with Mancozeb (0.2%)',
        'Maintain spacing for air circulation',
        'Mulch the soil to prevent splash',
      ],
    },
    'late_blight': {
      'name': 'Late Blight',
      'description': 'Severe fungal disease in wet conditions',
      'remedies': [
        'Spray with Metalaxyl + Mancozeb',
        'Improve drainage',
        'Remove infected plant parts',
        'Use resistant varieties if available',
      ],
    },
    'yellowing_virus': {
      'name': 'Yellowing Virus',
      'description': 'Viral infection causing yellowing',
      'remedies': [
        'Remove and destroy infected plants',
        'Control insect vectors (whiteflies, aphids)',
        'Use yellow sticky traps',
        'Maintain crop hygiene',
      ],
    },
    'cotton_bollworm': {
      'name': 'Cotton Bollworm',
      'description': 'Insect pest affecting cotton',
      'remedies': [
        'Spray with Cypermethrin (0.5%) or similar insecticide',
        'Hand-pick affected bolls if infestation is low',
        'Use pheromone traps for monitoring',
        'Encourage natural predators',
      ],
    },
  };

  /// ============================================================
  /// CROP-DISEASE MAPPING
  /// Define which diseases affect which crops
  /// ============================================================
  static const Map<String, List<String>> cropDiseases = {
    'rice': ['blast', 'leaf_spot', 'yellowing_virus'],
    'wheat': ['leaf_spot', 'powdery_mildew'],
    'cotton': ['powdery_mildew', 'cotton_bollworm', 'leaf_spot'],
    'tomato': ['early_blight', 'late_blight', 'powdery_mildew'],
    'potato': ['early_blight', 'late_blight', 'root_rot'],
    'groundnut': ['leaf_spot', 'root_rot'],
    'sugarcane': ['leaf_spot', 'yellowing_virus'],
    'maize': ['leaf_spot', 'powdery_mildew'],
  };

  /// ============================================================
  /// DISEASE-SYMPTOM MAPPING
  /// Define which symptoms indicate which diseases
  /// ============================================================
  static const Map<String, List<String>> diseaseSymptoms = {
    'blast': ['brown_spots', 'wilting'],
    'leaf_spot': ['brown_spots', 'yellow_leaves'],
    'powdery_mildew': ['powdery_coating', 'leaf_curl'],
    'root_rot': ['root_rot', 'wilting'],
    'early_blight': ['brown_spots', 'yellow_leaves'],
    'late_blight': ['brown_spots', 'wilting'],
    'yellowing_virus': ['yellow_leaves', 'leaf_curl'],
    'cotton_bollworm': ['aphids'],
  };

  /// Get all crops
  static List<Crop> getCrops() {
    return crops.entries.map((e) => Crop(id: e.key, name: e.value)).toList();
  }

  /// Get all symptoms
  static List<Symptom> getSymptoms() {
    return symptoms.entries
        .map(
          (e) => Symptom(
            id: e.key,
            name: e.value['name']!,
            description: e.value['description']!,
          ),
        )
        .toList();
  }

  /// Get diseases for a specific crop
  static List<Disease> getDiseasesForCrop(String cropId) {
    final diseaseIds = cropDiseases[cropId] ?? [];
    return diseaseIds.map((diseaseId) {
      final data = diseases[diseaseId]!;
      return Disease(
        id: diseaseId,
        name: data['name'] as String,
        description: data['description'] as String,
        remedies: List<String>.from(data['remedies'] as List),
      );
    }).toList();
  }

  /// Get symptoms for a specific disease
  static List<Symptom> getSymptomsForDisease(String diseaseId) {
    final symptomIds = diseaseSymptoms[diseaseId] ?? [];
    return symptomIds.map((symptomId) {
      final data = symptoms[symptomId]!;
      return Symptom(
        id: symptomId,
        name: data['name']!,
        description: data['description']!,
      );
    }).toList();
  }

  /// Get disease by ID
  static Disease? getDiseaseById(String diseaseId) {
    final data = diseases[diseaseId];
    if (data == null) return null;
    return Disease(
      id: diseaseId,
      name: data['name'] as String,
      description: data['description'] as String,
      remedies: List<String>.from(data['remedies'] as List),
    );
  }

  /// Get crop by ID
  static Crop? getCropById(String cropId) {
    final name = crops[cropId];
    if (name == null) return null;
    return Crop(id: cropId, name: name);
  }

  /// Get symptom by ID
  static Symptom? getSymptomById(String symptomId) {
    final data = symptoms[symptomId];
    if (data == null) return null;
    return Symptom(
      id: symptomId,
      name: data['name']!,
      description: data['description']!,
    );
  }
}
