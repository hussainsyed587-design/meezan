import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/quran.dart';
import '../constants/app_constants.dart';
import '../data/quran_surahs.dart';

class QuranProvider extends ChangeNotifier {
  List<QuranSurah> _surahs = [];
  List<QuranAyah> _currentSurahAyahs = [];
  List<QuranBookmark> _bookmarks = [];
  bool _isLoading = false;
  String? _error;
  int? _currentSurah;
  int? _lastReadSurah;
  int? _lastReadAyah;
  double _fontSize = 18.0;
  bool _showTranslation = true;
  bool _showTransliteration = false;
  
  // Getters
  List<QuranSurah> get surahs => _surahs;
  List<QuranAyah> get currentSurahAyahs => _currentSurahAyahs;
  List<QuranBookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get currentSurah => _currentSurah;
  int? get lastReadSurah => _lastReadSurah;
  int? get lastReadAyah => _lastReadAyah;
  double get fontSize => _fontSize;
  bool get showTranslation => _showTranslation;
  bool get showTransliteration => _showTransliteration;
  
  QuranProvider() {
    _initializeProvider();
  }
  
  Future<void> _initializeProvider() async {
    _loadPreferences();
    _loadBookmarks();
    await _loadSurahs();
  }
  
  Future<void> _loadSurahs() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Try to load from API first
      await _loadSurahsFromAPI();
      debugPrint('Successfully loaded ${_surahs.length} surahs from API');
    } catch (e) {
      // Fallback to local data if API fails
      _surahs = QuranData.getAllSurahs();
      debugPrint('Failed to load surahs from API, using local data: $e');
      debugPrint('Loaded ${_surahs.length} surahs from local data');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadSurahsFromAPI() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.quranApiUrl}/meta'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data']['surahs'] != null && data['data']['surahs']['references'] != null) {
          final List<dynamic> surahsJson = data['data']['surahs']['references'];
          _surahs = surahsJson.map((surah) {
            return QuranSurah(
              number: surah['number'] ?? 0,
              name: surah['name'] ?? '',
              englishName: surah['englishName'] ?? '',
              englishTranslation: surah['englishNameTranslation'] ?? '',
              revelationType: surah['revelationType'] ?? 'Unknown',
              numberOfAyahs: surah['numberOfAyahs'] ?? 0,
            );
          }).toList();
          debugPrint('Successfully loaded ${_surahs.length} surahs from alquran.cloud API');
          return;
        }
      }
      throw 'API response invalid';
    } catch (e) {
      throw 'Failed to fetch surahs from alquran.cloud API: $e';
    }
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastReadSurah = prefs.getInt('${AppConstants.lastReadQuranKey}_surah');
      _lastReadAyah = prefs.getInt('${AppConstants.lastReadQuranKey}_ayah');
      _fontSize = prefs.getDouble('quran_font_size') ?? 18.0;
      _showTranslation = prefs.getBool('quran_show_translation') ?? true;
      _showTransliteration = prefs.getBool('quran_show_transliteration') ?? false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Quran preferences: $e');
    }
  }
  
  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = prefs.getStringList(AppConstants.bookmarksKey);
      if (bookmarksJson != null) {
        _bookmarks = bookmarksJson
            .map((json) => QuranBookmark.fromJson(jsonDecode(json)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }
  
  Future<void> loadSurahAyahs(int surahNumber) async {
    _isLoading = true;
    _error = null;
    _currentSurah = surahNumber;
    notifyListeners();
    
    try {
      // Validate surah number
      if (surahNumber < 1 || surahNumber > 114) {
        throw 'Invalid surah number: $surahNumber';
      }
      
      // Try to load from API first
      try {
        await _loadAyahsFromAPI(surahNumber);
      } catch (e) {
        // Fallback to sample data if API fails
        _currentSurahAyahs = _getSampleAyahs(surahNumber);
        debugPrint('Failed to load ayahs from API, using sample data: $e');
      }
      
    } catch (e) {
      _error = 'Failed to load Surah: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadAyahsFromAPI(int surahNumber) async {
    try {
      // Load Arabic text
      final arabicResponse = await http.get(
        Uri.parse('${AppConstants.quranApiUrl}/surah/$surahNumber/ar.alafasy'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      // Load English translation
      final translationResponse = await http.get(
        Uri.parse('${AppConstants.quranApiUrl}/surah/$surahNumber/en.sahih'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));
      
      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);
        
        if (arabicData['data'] != null && arabicData['data']['ayahs'] != null &&
            translationData['data'] != null && translationData['data']['ayahs'] != null) {
          
          final List<dynamic> arabicAyahs = arabicData['data']['ayahs'];
          final List<dynamic> translationAyahs = translationData['data']['ayahs'];
          
          _currentSurahAyahs = [];
          
          for (int i = 0; i < arabicAyahs.length; i++) {
            final arabicAyah = arabicAyahs[i];
            final translationAyah = i < translationAyahs.length ? translationAyahs[i] : null;
            
            _currentSurahAyahs.add(QuranAyah(
              number: arabicAyah['numberInSurah'] ?? (i + 1),
              text: arabicAyah['text'] ?? '',
              translation: translationAyah?['text'] ?? '',
              surah: surahNumber,
              juz: arabicAyah['juz'] ?? 1,
              manzil: arabicAyah['manzil'] ?? 1,
              page: arabicAyah['page'] ?? 1,
              ruku: arabicAyah['ruku'] ?? 1,
              hizbQuarter: arabicAyah['hizbQuarter'] ?? 1,
            ));
          }
          
          debugPrint('Successfully loaded ${_currentSurahAyahs.length} ayahs for surah $surahNumber from alquran.cloud API');
          return;
        }
      }
      throw 'API response invalid';
    } catch (e) {
      throw 'Failed to fetch ayahs from alquran.cloud API: $e';
    }
  }
  
  Future<void> setLastRead(int surahNumber, int ayahNumber) async {
    _lastReadSurah = surahNumber;
    _lastReadAyah = ayahNumber;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('${AppConstants.lastReadQuranKey}_surah', surahNumber);
      await prefs.setInt('${AppConstants.lastReadQuranKey}_ayah', ayahNumber);
    } catch (e) {
      debugPrint('Error saving last read: $e');
    }
    
    notifyListeners();
  }
  
  Future<void> addBookmark(int surahNumber, int ayahNumber, String surahName, {String note = ''}) async {
    final bookmark = QuranBookmark(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahName: surahName,
      note: note,
      createdAt: DateTime.now(),
    );
    
    _bookmarks.add(bookmark);
    await _saveBookmarks();
    notifyListeners();
  }
  
  Future<void> removeBookmark(String bookmarkId) async {
    _bookmarks.removeWhere((bookmark) => bookmark.id == bookmarkId);
    await _saveBookmarks();
    notifyListeners();
  }
  
  Future<void> _saveBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarksJson = _bookmarks
          .map((bookmark) => jsonEncode(bookmark.toJson()))
          .toList();
      await prefs.setStringList(AppConstants.bookmarksKey, bookmarksJson);
    } catch (e) {
      debugPrint('Error saving bookmarks: $e');
    }
  }
  
  Future<void> updateFontSize(double size) async {
    _fontSize = size;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('quran_font_size', size);
    } catch (e) {
      debugPrint('Error saving font size: $e');
    }
    notifyListeners();
  }
  
  Future<void> toggleTranslation() async {
    _showTranslation = !_showTranslation;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quran_show_translation', _showTranslation);
    } catch (e) {
      debugPrint('Error saving translation preference: $e');
    }
    notifyListeners();
  }
  
  Future<void> toggleTransliteration() async {
    _showTransliteration = !_showTransliteration;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('quran_show_transliteration', _showTransliteration);
    } catch (e) {
      debugPrint('Error saving transliteration preference: $e');
    }
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refreshSurahs() async {
    _error = null;
    await _loadSurahs();
  }
  
  Future<void> refreshCurrentSurah() async {
    if (_currentSurah != null) {
      await loadSurahAyahs(_currentSurah!);
    }
  }
  
  bool isBookmarked(int surahNumber, int ayahNumber) {
    return _bookmarks.any((bookmark) => 
        bookmark.surahNumber == surahNumber && bookmark.ayahNumber == ayahNumber);
  }
  
  QuranSurah? getSurahByNumber(int number) {
    try {
      return _surahs.firstWhere((surah) => surah.number == number);
    } catch (e) {
      return null;
    }
  }
  
  // Sample data for ayahs - in a real app, this would come from a database or API
  List<QuranAyah> _getSampleAyahs(int surahNumber) {
    // Sample ayahs for Al-Fatihah
    if (surahNumber == 1) {
      return [
        QuranAyah(
          number: 1,
          text: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 2,
          text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          translation: '[All] praise is [due] to Allah, Lord of the worlds -',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 3,
          text: 'الرَّحْمَنِ الرَّحِيمِ',
          translation: 'The Entirely Merciful, the Especially Merciful,',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 4,
          text: 'مَالِكِ يَوْمِ الدِّينِ',
          translation: 'Sovereign of the Day of Recompense.',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 5,
          text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          translation: 'It is You we worship and You we ask for help.',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 6,
          text: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          translation: 'Guide us to the straight path -',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 7,
          text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          translation: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
          surah: 1,
          juz: 1,
          manzil: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
        ),
      ];
    }
    
    // Sample ayahs for Al-Baqarah (Surah 2) - first few verses
    if (surahNumber == 2) {
      return [
        QuranAyah(
          number: 1,
          text: 'الم',
          translation: 'Alif, Lam, Meem.',
          surah: 2,
          juz: 1,
          manzil: 1,
          page: 2,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 2,
          text: 'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ فِيهِ هُدًى لِّلْمُتَّقِينَ',
          translation: 'This is the Book about which there is no doubt, a guidance for those conscious of Allah -',
          surah: 2,
          juz: 1,
          manzil: 1,
          page: 2,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 3,
          text: 'الَّذِينَ يُؤْمِنُونَ بِالْغَيْبِ وَيُقِيمُونَ الصَّلَاةَ وَمِمَّا رَزَقْنَاهُمْ يُنفِقُونَ',
          translation: 'Who believe in the unseen, establish prayer, and spend out of what We have provided for them,',
          surah: 2,
          juz: 1,
          manzil: 1,
          page: 2,
          ruku: 1,
          hizbQuarter: 1,
        ),
      ];
    }
    
    // Sample ayahs for Surah Al-Ikhlas (112)
    if (surahNumber == 112) {
      return [
        QuranAyah(
          number: 1,
          text: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          translation: 'Say, "He is Allah, [who is] One,',
          surah: 112,
          juz: 30,
          manzil: 7,
          page: 604,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 2,
          text: 'اللَّهُ الصَّمَدُ',
          translation: 'Allah, the Eternal Refuge.',
          surah: 112,
          juz: 30,
          manzil: 7,
          page: 604,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 3,
          text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          translation: 'He neither begets nor is born,',
          surah: 112,
          juz: 30,
          manzil: 7,
          page: 604,
          ruku: 1,
          hizbQuarter: 1,
        ),
        QuranAyah(
          number: 4,
          text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          translation: 'Nor is there to Him any equivalent."',
          surah: 112,
          juz: 30,
          manzil: 7,
          page: 604,
          ruku: 1,
          hizbQuarter: 1,
        ),
      ];
    }
    
    // Return generic sample ayahs for other surahs
    if (surahNumber > 1 && surahNumber <= 114) {
      final surah = getSurahByNumber(surahNumber);
      if (surah != null) {
        // Generate sample content with actual Arabic text
        final numberOfSampleAyahs = surah.numberOfAyahs > 5 ? 5 : surah.numberOfAyahs; // Show max 5 for demo
        return List.generate(numberOfSampleAyahs, (index) {
          return QuranAyah(
            number: index + 1,
            text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ • نموذج آية ${index + 1}',
            translation: 'Sample verse ${index + 1} from ${surah.englishName}. (This is sample data - please check internet connection for complete verses)',
            surah: surahNumber,
            juz: 1,
            manzil: 1,
            page: 1,
            ruku: 1,
            hizbQuarter: 1,
          );
        });
      }
    }
    
    // Return empty list for invalid surah numbers
    return [];
  }
}