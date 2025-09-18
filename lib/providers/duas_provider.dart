import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/dua_hadith.dart';

class DuasProvider extends ChangeNotifier {
  List<DuaCategory> _categories = [];
  List<Dua> _favorites = [];
  bool _isLoading = false;
  String? _error;
  
  List<DuaCategory> get categories => _categories;
  List<Dua> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  DuasProvider() {
    _loadDuas();
    _loadFavorites();
  }
  
  Future<void> _loadDuas() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _categories = _getDefaultDuaCategories();
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading
    } catch (e) {
      _error = 'Failed to load duas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList('favorite_duas');
      if (favoritesJson != null) {
        _favorites = favoritesJson
            .map((json) => Dua.fromJson(jsonDecode(json)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading favorite duas: $e');
    }
  }
  
  Future<void> toggleFavorite(Dua dua) async {
    if (isFavorite(dua.id)) {
      _favorites.removeWhere((fav) => fav.id == dua.id);
    } else {
      _favorites.add(dua.copyWith(isFavorite: true));
    }
    
    await _saveFavorites();
    notifyListeners();
  }
  
  Future<void> _saveFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = _favorites
          .map((dua) => jsonEncode(dua.toJson()))
          .toList();
      await prefs.setStringList('favorite_duas', favoritesJson);
    } catch (e) {
      debugPrint('Error saving favorite duas: $e');
    }
  }
  
  bool isFavorite(String duaId) {
    return _favorites.any((dua) => dua.id == duaId);
  }
  
  List<Dua> getDuasByCategory(String categoryId) {
    final category = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => DuaCategory(id: '', name: '', description: '', iconName: ''),
    );
    return category.duas;
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  List<DuaCategory> _getDefaultDuaCategories() {
    return [
      DuaCategory(
        id: 'morning',
        name: 'Morning Duas',
        description: 'Start your day with these blessed supplications',
        iconName: 'wb_sunny',
        duas: [
          Dua(
            id: 'morning_1',
            arabicText: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
            transliteration: 'Asbahna wa asbahal-mulku lillahi, walhamdu lillahi, la ilaha illa Allah wahdahu la shareeka lahu',
            translation: 'We have reached the morning and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.',
            englishText: 'Morning Remembrance',
            category: 'morning',
            reference: 'Muslim',
          ),
          Dua(
            id: 'morning_2',
            arabicText: 'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
            transliteration: 'Allahumma bika asbahna, wa bika amsayna, wa bika nahya, wa bika namootu, wa ilaykan-nushoor',
            translation: 'O Allah, by Your leave we have reached the morning and by Your leave we have reached the evening, by Your leave we live and die and unto You is our resurrection.',
            englishText: 'Morning Protection',
            category: 'morning',
            reference: 'Tirmidhi',
          ),
        ],
      ),
      DuaCategory(
        id: 'evening',
        name: 'Evening Duas',
        description: 'End your day with gratitude and protection',
        iconName: 'nights_stay',
        duas: [
          Dua(
            id: 'evening_1',
            arabicText: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ',
            transliteration: 'Amsayna wa amsal-mulku lillahi walhamdu lillahi, la ilaha illa Allah wahdahu la shareeka lahu',
            translation: 'We have reached the evening and at this very time unto Allah belongs all sovereignty, and all praise is for Allah.',
            englishText: 'Evening Remembrance',
            category: 'evening',
            reference: 'Muslim',
          ),
        ],
      ),
      DuaCategory(
        id: 'protection',
        name: 'Protection Duas',
        description: 'Seek Allah\'s protection from all harm',
        iconName: 'shield',
        duas: [
          Dua(
            id: 'protection_1',
            arabicText: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
            transliteration: 'A\'udhu bi kalimatillahit-tammati min sharri ma khalaq',
            translation: 'I seek refuge in the perfect words of Allah from the evil of what He has created.',
            englishText: 'General Protection',
            category: 'protection',
            reference: 'Muslim',
          ),
          Dua(
            id: 'protection_2',
            arabicText: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
            transliteration: 'Bismillahil-ladhi la yadurru ma\'as-mihi shay\'un fil-ardi wa la fis-sama\'i wa huwas-samee\'ul-\'aleem',
            translation: 'In the name of Allah with whose name nothing is harmed on earth nor in the heavens, and He is the All-Hearing, the All-Knowing.',
            englishText: 'Protection from Harm',
            category: 'protection',
            reference: 'Abu Dawud',
            repetitionCount: 3,
          ),
        ],
      ),
      DuaCategory(
        id: 'gratitude',
        name: 'Gratitude Duas',
        description: 'Express thankfulness to Allah',
        iconName: 'favorite',
        duas: [
          Dua(
            id: 'gratitude_1',
            arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
            transliteration: 'Alhamdu lillahi rabbil-\'alameen',
            translation: 'All praise is due to Allah, Lord of all the worlds.',
            englishText: 'Praise to Allah',
            category: 'gratitude',
            reference: 'Quran 1:2',
          ),
        ],
      ),
      DuaCategory(
        id: 'travel',
        name: 'Travel Duas',
        description: 'Supplications for safe journeys',
        iconName: 'directions_car',
        duas: [
          Dua(
            id: 'travel_1',
            arabicText: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ',
            transliteration: 'Subhanal-ladhi sakhkhara lana hadha wa ma kunna lahu muqrineen, wa inna ila rabbina lamunqaliboon',
            translation: 'Glory is to Him Who has subjected this to us, and we could never have it (by our efforts). And verily, to our Lord we indeed are to return!',
            englishText: 'Travel Dua',
            category: 'travel',
            reference: 'Quran 43:13-14',
          ),
        ],
      ),
      DuaCategory(
        id: 'sleep',
        name: 'Sleep Duas',
        description: 'Peaceful rest with Allah\'s protection',
        iconName: 'bedtime',
        duas: [
          Dua(
            id: 'sleep_1',
            arabicText: 'اللَّهُمَّ بِاسْمِكَ أَمُوتُ وَأَحْيَا',
            transliteration: 'Allahumma bismika amootu wa ahya',
            translation: 'O Allah, in Your name I die and I live.',
            englishText: 'Sleep Protection',
            category: 'sleep',
            reference: 'Bukhari',
          ),
        ],
      ),
    ];
  }
}