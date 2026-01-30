/// Model for scan treatment API response
class ScanTreatmentResult {
  final String disease;
  final String language;
  final String? itemLabel;
  final bool willCure;
  final String feedback;

  ScanTreatmentResult({
    required this.disease,
    required this.language,
    required this.itemLabel,
    required this.willCure,
    required this.feedback,
  });

  factory ScanTreatmentResult.fromJson(Map<String, dynamic> json) {
    return ScanTreatmentResult(
      disease: json['disease'] as String,
      language: json['language'] as String,
      itemLabel: json['item_label'] as String?,
      willCure: json['will_cure'] as bool,
      feedback: json['feedback'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disease': disease,
      'language': language,
      'item_label': itemLabel,
      'will_cure': willCure,
      'feedback': feedback,
    };
  }
}
