import '../models/audio_recitation.dart';

class AudioRecitationsData {
  static List<AudioRecitation> getAvailableRecitations() {
    return [
      // Abdul Rahman Al-Sudais
      const AudioRecitation(
        id: 'sudais',
        name: 'Abdul Rahman Al-Sudais',
        description: 'Imam of the Grand Mosque in Mecca with beautiful melodious recitation',
        reciterName: 'Abdul Rahman Al-Sudais',
        reciterArabicName: 'عبد الرحمن السديس',
        baseUrl: 'https://server11.mp3quran.net/sudais',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 1,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Mishary Rashid Alafasy
      const AudioRecitation(
        id: 'alafasy',
        name: 'Mishary Rashid Alafasy',
        description: 'Kuwaiti Imam known for his powerful and emotional recitation',
        reciterName: 'Mishary Rashid Alafasy',
        reciterArabicName: 'مشاري بن راشد العفاسي',
        baseUrl: 'https://server8.mp3quran.net/alafasy',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 2,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Saad Al Ghamdi
      const AudioRecitation(
        id: 'ghamdi',
        name: 'Saad Al Ghamdi',
        description: 'Saudi reciter with clear and precise pronunciation',
        reciterName: 'Saad Al Ghamdi',
        reciterArabicName: 'سعد الغامدي',
        baseUrl: 'https://server7.mp3quran.net/s_gmd',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 3,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Abdul Basit Abdul Samad
      const AudioRecitation(
        id: 'abdulbasit',
        name: 'Abdul Basit Abdul Samad',
        description: 'Egyptian reciter with exceptional Tajweed and melodious voice',
        reciterName: 'Abdul Basit Abdul Samad',
        reciterArabicName: 'عبد الباسط عبد الصمد',
        baseUrl: 'https://server10.mp3quran.net/basit',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 4,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Ahmed Ali Al-Ajmi
      const AudioRecitation(
        id: 'ajmi',
        name: 'Ahmed Ali Al-Ajmi',
        description: 'Saudi reciter with beautiful and distinctive voice',
        reciterName: 'Ahmed Ali Al-Ajmi',
        reciterArabicName: 'أحمد علي العجمي',
        baseUrl: 'https://server10.mp3quran.net/ajm',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 5,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Maher Al Mueaqly
      const AudioRecitation(
        id: 'mueaqly',
        name: 'Maher Al Mueaqly',
        description: 'Imam of the Prophet\'s Mosque in Medina',
        reciterName: 'Maher Al Mueaqly',
        reciterArabicName: 'ماهر المعيقلي',
        baseUrl: 'https://server12.mp3quran.net/maher',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 6,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Abu Bakr Al Shatri
      const AudioRecitation(
        id: 'shatri',
        name: 'Abu Bakr Al Shatri',
        description: 'Kuwaiti reciter with excellent Tajweed',
        reciterName: 'Abu Bakr Al Shatri',
        reciterArabicName: 'أبو بكر الشاطري',
        baseUrl: 'https://server11.mp3quran.net/shatri',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 7,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Yasser Al Dosari
      const AudioRecitation(
        id: 'dosari',
        name: 'Yasser Al Dosari',
        description: 'Saudi reciter with emotional and beautiful recitation',
        reciterName: 'Yasser Al Dosari',
        reciterArabicName: 'ياسر الدوسري',
        baseUrl: 'https://server11.mp3quran.net/yasser',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 8,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Muhammad Ayyub
      const AudioRecitation(
        id: 'ayyub',
        name: 'Muhammad Ayyub',
        description: 'Former Imam of the Prophet\'s Mosque with classical style',
        reciterName: 'Muhammad Ayyub',
        reciterArabicName: 'محمد أيوب',
        baseUrl: 'https://server8.mp3quran.net/ayyub',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 9,
        isDownloadable: true,
        bitrate: 64,
      ),
      
      // Hani Ar Rifai
      const AudioRecitation(
        id: 'rifai',
        name: 'Hani Ar Rifai',
        description: 'Palestinian reciter with beautiful melodious voice',
        reciterName: 'Hani Ar Rifai',
        reciterArabicName: 'هاني الرفاعي',
        baseUrl: 'https://server13.mp3quran.net/rifai',
        totalSurahs: 114,
        style: RecitationStyle.hafs,
        reciterId: 10,
        isDownloadable: true,
        bitrate: 64,
      ),
    ];
  }

  static List<AudioRecitation> getFeaturedRecitations() {
    final all = getAvailableRecitations();
    return [
      all.firstWhere((r) => r.id == 'sudais'),
      all.firstWhere((r) => r.id == 'alafasy'),
      all.firstWhere((r) => r.id == 'ghamdi'),
      all.firstWhere((r) => r.id == 'abdulbasit'),
    ];
  }

  static AudioRecitation? getRecitationById(String id) {
    try {
      return getAvailableRecitations().firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<AudioRecitation> getRecitationsByStyle(RecitationStyle style) {
    return getAvailableRecitations()
        .where((r) => r.style == style)
        .toList();
  }

  static List<AudioRecitation> searchRecitations(String query) {
    final lowerQuery = query.toLowerCase();
    return getAvailableRecitations().where((recitation) {
      return recitation.name.toLowerCase().contains(lowerQuery) ||
             recitation.reciterName.toLowerCase().contains(lowerQuery) ||
             recitation.description.toLowerCase().contains(lowerQuery) ||
             (recitation.reciterArabicName?.contains(query) ?? false);
    }).toList();
  }

  // Popular Quranic recitation segments for quick access
  static List<Map<String, dynamic>> getPopularSegments() {
    return [
      {
        'title': 'Al-Fatihah',
        'description': 'The Opening - First chapter of the Quran',
        'surahNumber': 1,
        'isPopular': true,
      },
      {
        'title': 'Ayat al-Kursi',
        'description': 'The Throne Verse - Al-Baqarah 255',
        'surahNumber': 2,
        'ayahNumber': 255,
        'isPopular': true,
      },
      {
        'title': 'Al-Mulk',
        'description': 'The Sovereignty - Protection from grave punishment',
        'surahNumber': 67,
        'isPopular': true,
      },
      {
        'title': 'As-Sajdah',
        'description': 'The Prostration - Recommended for Fajr',
        'surahNumber': 32,
        'isPopular': true,
      },
      {
        'title': 'Al-Waqi\'ah',
        'description': 'The Inevitable - Protection from poverty',
        'surahNumber': 56,
        'isPopular': true,
      },
      {
        'title': 'Ar-Rahman',
        'description': 'The Merciful - The Beauty of Creation',
        'surahNumber': 55,
        'isPopular': true,
      },
      {
        'title': 'Ya-Sin',
        'description': 'Ya-Sin - The Heart of the Quran',
        'surahNumber': 36,
        'isPopular': true,
      },
      {
        'title': 'Al-Kahf',
        'description': 'The Cave - Recommended for Friday',
        'surahNumber': 18,
        'isPopular': true,
      },
      {
        'title': 'Last 10 Surahs',
        'description': 'Short surahs perfect for daily recitation',
        'surahNumbers': [105, 106, 107, 108, 109, 110, 111, 112, 113, 114],
        'isPopular': true,
      },
    ];
  }

  // Create playlists for common recitation patterns
  static List<PlaylistItem> getDefaultPlaylists() {
    final recitations = getAvailableRecitations();
    final sudais = recitations.firstWhere((r) => r.id == 'sudais');
    
    return [
      PlaylistItem(
        id: 'daily_recitation',
        name: 'Daily Recitation',
        description: 'Short surahs perfect for daily listening',
        tracks: [
          // Last 10 surahs
          for (int i = 105; i <= 114; i++)
            AudioTrack(
              id: 'daily_$i',
              surahNumber: i,
              title: 'Surah $i',
              audioUrl: sudais.getAudioUrl(i),
              recitation: sudais,
            ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      ),
      
      PlaylistItem(
        id: 'morning_adhkar',
        name: 'Morning Recitation',
        description: 'Recommended surahs for morning',
        tracks: [
          AudioTrack(
            id: 'morning_1',
            surahNumber: 1,
            title: 'Al-Fatihah',
            audioUrl: sudais.getAudioUrl(1),
            recitation: sudais,
          ),
          AudioTrack(
            id: 'morning_32',
            surahNumber: 32,
            title: 'As-Sajdah',
            audioUrl: sudais.getAudioUrl(32),
            recitation: sudais,
          ),
          AudioTrack(
            id: 'morning_67',
            surahNumber: 67,
            title: 'Al-Mulk',
            audioUrl: sudais.getAudioUrl(67),
            recitation: sudais,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      ),
      
      PlaylistItem(
        id: 'night_recitation',
        name: 'Night Recitation',
        description: 'Peaceful surahs for evening and night',
        tracks: [
          AudioTrack(
            id: 'night_36',
            surahNumber: 36,
            title: 'Ya-Sin',
            audioUrl: sudais.getAudioUrl(36),
            recitation: sudais,
          ),
          AudioTrack(
            id: 'night_55',
            surahNumber: 55,
            title: 'Ar-Rahman',
            audioUrl: sudais.getAudioUrl(55),
            recitation: sudais,
          ),
          AudioTrack(
            id: 'night_56',
            surahNumber: 56,
            title: 'Al-Waqi\'ah',
            audioUrl: sudais.getAudioUrl(56),
            recitation: sudais,
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isDefault: true,
      ),
    ];
  }
}