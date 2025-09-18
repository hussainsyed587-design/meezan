import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../constants/app_colors.dart';

class HadithScreen extends StatefulWidget {
  const HadithScreen({super.key});

  @override
  State<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends State<HadithScreen> {
  int _currentHadithIndex = 0;
  
  final List<HadithItem> _hadithCollection = [
    HadithItem(
      id: 1,
      arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
      transliteration: 'Innama al-a\'malu bin-niyyat',
      translation: 'Actions are but by intention.',
      narrator: 'Umar ibn al-Khattab',
      source: 'Sahih al-Bukhari',
      hadithNumber: '1',
      category: 'Intention',
    ),
    HadithItem(
      id: 2,
      arabic: 'الدِّينُ النَّصِيحَةُ',
      transliteration: 'Ad-deenu an-naseehah',
      translation: 'Religion is sincere advice.',
      narrator: 'Tamim ibn Aws ad-Dari',
      source: 'Sahih Muslim',
      hadithNumber: '55',
      category: 'Advice',
    ),
    HadithItem(
      id: 3,
      arabic: 'لَا يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لِأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
      transliteration: 'La yu\'minu ahadukum hatta yuhibba li-akheehi ma yuhibbu li-nafsihi',
      translation: 'None of you truly believes until he loves for his brother what he loves for himself.',
      narrator: 'Anas ibn Malik',
      source: 'Sahih al-Bukhari',
      hadithNumber: '13',
      category: 'Brotherhood',
    ),
    HadithItem(
      id: 4,
      arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الْآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
      transliteration: 'Man kana yu\'minu billahi wal-yawm al-akhiri fal-yaqul khayran aw liyasmut',
      translation: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
      narrator: 'Abu Hurairah',
      source: 'Sahih al-Bukhari',
      hadithNumber: '6018',
      category: 'Speech',
    ),
    HadithItem(
      id: 5,
      arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
      transliteration: 'Al-muslimu man salima al-muslimuna min lisanihi wa yadihi',
      translation: 'A Muslim is one from whose tongue and hand other Muslims are safe.',
      narrator: 'Abdullah ibn Amr',
      source: 'Sahih al-Bukhari',
      hadithNumber: '10',
      category: 'Character',
    ),
    HadithItem(
      id: 6,
      arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ',
      transliteration: 'Ittaqi Allaha haythu ma kunt',
      translation: 'Be conscious of Allah wherever you are.',
      narrator: 'Abu Dharr al-Ghifari',
      source: 'Sunan at-Tirmidhi',
      hadithNumber: '1987',
      category: 'Taqwa',
    ),
    HadithItem(
      id: 7,
      arabic: 'خَيْرُ النَّاسِ أَنْفَعُهُمْ لِلنَّاسِ',
      transliteration: 'Khayru an-nasi anfa\'uhum lin-nas',
      translation: 'The best of people are those who benefit others.',
      narrator: 'Jabir ibn Abdullah',
      source: 'Sunan ad-Daraqutni',
      hadithNumber: '4682',
      category: 'Service',
    ),
    HadithItem(
      id: 8,
      arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
      transliteration: 'Tabassumukasfee wajhi akheeka sadaqah',
      translation: 'Your smile in the face of your brother is charity.',
      narrator: 'Abu Dharr al-Ghifari',
      source: 'Sunan at-Tirmidhi',
      hadithNumber: '1956',
      category: 'Kindness',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentHadith = _hadithCollection[_currentHadithIndex];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.arabicAccent,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Hadith of the Day',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.arabicAccent,
                      AppColors.arabicAccent.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.menu_book,
                    size: 80,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _shareHadith,
                icon: const Icon(Icons.share),
                tooltip: 'Share Hadith',
              ),
              IconButton(
                onPressed: _showFavorites,
                icon: const Icon(Icons.favorite_border),
                tooltip: 'Favorites',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Hadith Navigation
                  _buildHadithNavigation(),
                  
                  const SizedBox(height: 24),
                  
                  // Main Hadith Card
                  _buildHadithCard(currentHadith),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  _buildActionButtons(currentHadith),
                  
                  const SizedBox(height: 24),
                  
                  // Category Browse
                  _buildCategoryBrowse(),
                  
                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithNavigation() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: _currentHadithIndex > 0 ? _previousHadith : null,
              icon: const Icon(Icons.arrow_back_ios),
              tooltip: 'Previous Hadith',
            ),
            
            Expanded(
              child: Column(
                children: [
                  Text(
                    'Hadith ${_currentHadithIndex + 1} of ${_hadithCollection.length}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.arabicAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _hadithCollection[_currentHadithIndex].category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.arabicAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            IconButton(
              onPressed: _currentHadithIndex < _hadithCollection.length - 1 ? _nextHadith : null,
              icon: const Icon(Icons.arrow_forward_ios),
              tooltip: 'Next Hadith',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard(HadithItem hadith) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arabic Text
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.arabicAccent.withOpacity(0.05),
                    AppColors.arabicAccent.withOpacity(0.02),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.arabicAccent.withOpacity(0.2),
                ),
              ),
              child: Text(
                hadith.arabic,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Arabic',
                  color: AppColors.textPrimary,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Transliteration
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hadith.transliteration,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Translation
            Text(
              hadith.translation,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textPrimary,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Hadith Source Information
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Narrator: ${hadith.narrator}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.book,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Source: ${hadith.source} #${hadith.hadithNumber}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(HadithItem hadith) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _copyHadith(hadith),
            icon: const Icon(Icons.copy),
            label: const Text('Copy'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _shareHadith(),
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _addToFavorites(hadith),
            icon: const Icon(Icons.favorite_border),
            label: const Text('Save'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.arabicAccent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBrowse() {
    final categories = _hadithCollection
        .map((h) => h.category)
        .toSet()
        .toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse by Category',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final count = _hadithCollection.where((h) => h.category == category).length;
                return FilterChip(
                  label: Text('$category ($count)'),
                  onSelected: (selected) {
                    if (selected) {
                      _browseByCategory(category);
                    }
                  },
                  backgroundColor: AppColors.background,
                  selectedColor: AppColors.primaryGreen.withOpacity(0.2),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _previousHadith() {
    setState(() {
      if (_currentHadithIndex > 0) {
        _currentHadithIndex--;
      }
    });
  }

  void _nextHadith() {
    setState(() {
      if (_currentHadithIndex < _hadithCollection.length - 1) {
        _currentHadithIndex++;
      }
    });
  }

  void _copyHadith(HadithItem hadith) {
    final text = '''
${hadith.arabic}

${hadith.transliteration}

${hadith.translation}

Narrator: ${hadith.narrator}
Source: ${hadith.source} #${hadith.hadithNumber}

#Hadith #Meezan
''';
    
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hadith copied to clipboard'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _shareHadith() {
    final hadith = _hadithCollection[_currentHadithIndex];
    final text = '''
${hadith.arabic}

${hadith.transliteration}

"${hadith.translation}"

- Narrator: ${hadith.narrator}
- Source: ${hadith.source} #${hadith.hadithNumber}

Shared from Meezan: Prayer & Quran App
''';
    
    // In a real app, you would use the share_plus package
    // Share.share(text);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hadith ready to share!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _addToFavorites(HadithItem hadith) {
    // In a real app, save to favorites
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added "${hadith.category}" hadith to favorites'),
        backgroundColor: AppColors.arabicAccent,
      ),
    );
  }

  void _browseByCategory(String category) {
    final categoryHadiths = _hadithCollection
        .asMap()
        .entries
        .where((entry) => entry.value.category == category)
        .toList();
    
    if (categoryHadiths.isNotEmpty) {
      setState(() {
        _currentHadithIndex = categoryHadiths.first.key;
      });
    }
  }

  void _showFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Favorite Hadiths'),
        content: const Text('Favorites feature will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class HadithItem {
  final int id;
  final String arabic;
  final String transliteration;
  final String translation;
  final String narrator;
  final String source;
  final String hadithNumber;
  final String category;

  const HadithItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.narrator,
    required this.source,
    required this.hadithNumber,
    required this.category,
  });
}