class AllahName {
  final int number;
  final String arabicName;
  final String transliteration;
  final String meaning;
  final String description;
  
  AllahName({
    required this.number,
    required this.arabicName,
    required this.transliteration,
    required this.meaning,
    required this.description,
  });
  
  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      number: json['number'] ?? 0,
      arabicName: json['arabicName'] ?? '',
      transliteration: json['transliteration'] ?? '',
      meaning: json['meaning'] ?? '',
      description: json['description'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabicName': arabicName,
      'transliteration': transliteration,
      'meaning': meaning,
      'description': description,
    };
  }
}