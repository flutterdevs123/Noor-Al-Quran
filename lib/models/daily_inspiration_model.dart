/// Distinguishes whether a live feed slide is a Quranic Ayah or a Prophetic Hadith.
enum InspirationType {
  ayah,
  hadith,
}

/// Immutable data model representing a live Quranic verse or Sahih Hadith
/// fetched from API and cached locally for offline resilience.
class DailyInspirationModel {
  final String id;
  final InspirationType type;
  final String arabicText;
  final String englishTranslation;
  final String urduTranslation;
  final String englishReference;
  final String urduReference;
  final String? occasionLabelEn;
  final String? occasionLabelUr;

  const DailyInspirationModel({
    required this.id,
    required this.type,
    required this.arabicText,
    required this.englishTranslation,
    required this.urduTranslation,
    required this.englishReference,
    required this.urduReference,
    this.occasionLabelEn,
    this.occasionLabelUr,
  });

  bool get isAyah => type == InspirationType.ayah;

  bool get hasOccasion =>
      occasionLabelEn != null && occasionLabelEn!.isNotEmpty;

  String localizedTranslation({required bool isUrdu}) =>
      isUrdu ? urduTranslation : englishTranslation;

  String localizedReference({required bool isUrdu}) =>
      isUrdu ? urduReference : englishReference;

  String? localizedOccasion({required bool isUrdu}) =>
      isUrdu ? occasionLabelUr : occasionLabelEn;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'type': type.name,
    'arabicText': arabicText,
    'englishTranslation': englishTranslation,
    'urduTranslation': urduTranslation,
    'englishReference': englishReference,
    'urduReference': urduReference,
    'occasionLabelEn': occasionLabelEn,
    'occasionLabelUr': occasionLabelUr,
  };

  factory DailyInspirationModel.fromJson(Map<String, dynamic> json) {
    return DailyInspirationModel(
      id: json['id'] as String? ?? '',
      type: (json['type'] as String?) == InspirationType.hadith.name
          ? InspirationType.hadith
          : InspirationType.ayah,
      arabicText: json['arabicText'] as String? ?? '',
      englishTranslation: json['englishTranslation'] as String? ?? '',
      urduTranslation: json['urduTranslation'] as String? ?? '',
      englishReference: json['englishReference'] as String? ?? '',
      urduReference: json['urduReference'] as String? ?? '',
      occasionLabelEn: json['occasionLabelEn'] as String?,
      occasionLabelUr: json['occasionLabelUr'] as String?,
    );
  }
}