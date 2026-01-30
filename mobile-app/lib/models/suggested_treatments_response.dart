import 'pesticide_store.dart';

class SuggestedTreatmentsResponse {
  final String disease;
  final String language;
  final List<String> remedies;
  final List<PesticideStore> stores;

  SuggestedTreatmentsResponse({
    required this.disease,
    required this.language,
    required this.remedies,
    required this.stores,
  });

  factory SuggestedTreatmentsResponse.fromJson(Map<String, dynamic> json) {
    return SuggestedTreatmentsResponse(
      disease: json['disease'] as String,
      language: json['language'] as String,
      remedies: List<String>.from(json['remedies'] as List),
      stores: (json['stores'] as List)
          .map((item) => PesticideStore.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
