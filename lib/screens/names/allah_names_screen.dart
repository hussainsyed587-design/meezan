import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../models/allah_names.dart';

class AllahNamesScreen extends StatefulWidget {
  const AllahNamesScreen({super.key});

  @override
  State<AllahNamesScreen> createState() => _AllahNamesScreenState();
}

class _AllahNamesScreenState extends State<AllahNamesScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final List<AllahName> _allahNames = _get99Names();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('99 Names of Allah'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _showNamesList,
            tooltip: 'View All Names',
          ),
        ],
      ),
      body: Column(
        children: [
          // Current Name Display
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _allahNames.length,
              itemBuilder: (context, index) {
                final name = _allahNames[index];
                return _buildNameCard(name);
              },
            ),
          ),

          // Navigation Controls
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Page Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_allahNames.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Navigation Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _currentIndex > 0 ? _previousName : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _currentIndex < _allahNames.length - 1 ? _nextName : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(AllahName name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Name Number
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: AppColors.greenGradient,
              ),
            ),
            child: Center(
              child: Text(
                name.number.toString(),
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Arabic Name
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                name.arabicName,
                style: AppTheme.arabicTextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Transliteration
          Text(
            name.transliteration,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Meaning
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Meaning',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name.meaning,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Description
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  name.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _previousName() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextName() {
    if (_currentIndex < _allahNames.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showNamesList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '99 Names of Allah',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _allahNames.length,
                    itemBuilder: (context, index) {
                      final name = _allahNames[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppColors.primaryGreen,
                          child: Text(
                            name.number.toString(),
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          name.arabicName,
                          style: AppTheme.arabicTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text('${name.transliteration} - ${name.meaning}'),
                        onTap: () {
                          Navigator.pop(context);
                          _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static List<AllahName> _get99Names() {
    return [
      AllahName(
        number: 1,
        arabicName: 'الله',
        transliteration: 'Allah',
        meaning: 'The God',
        description: 'The proper name of the One true God, which can never be used to indicate anything other than Him.',
      ),
      AllahName(
        number: 2,
        arabicName: 'الرحمن',
        transliteration: 'Ar-Rahman',
        meaning: 'The Most Compassionate',
        description: 'The One who acts with extreme kindness and mercy, and who wills goodness and mercy for all His creatures.',
      ),
      AllahName(
        number: 3,
        arabicName: 'الرحيم',
        transliteration: 'Ar-Raheem',
        meaning: 'The Most Merciful',
        description: 'The One who acts with extreme mercy. The mercy of Allah ta\'ala that will be granted to believers in the afterlife.',
      ),
      AllahName(
        number: 4,
        arabicName: 'الملك',
        transliteration: 'Al-Malik',
        meaning: 'The King',
        description: 'The One who reigns dominion over the heavens and the earth and everything that exists.',
      ),
      AllahName(
        number: 5,
        arabicName: 'القدوس',
        transliteration: 'Al-Quddus',
        meaning: 'The Holy One',
        description: 'The One who is pure and free from any defects, free from children, parents, partners, equals or rivals.',
      ),
      // Adding more names for demonstration - in a real app, all 99 would be included
      AllahName(
        number: 6,
        arabicName: 'السلام',
        transliteration: 'As-Salaam',
        meaning: 'The Source of Peace',
        description: 'The One who is free from all defects and deficiencies, and the One who grants peace and security to His creation.',
      ),
      AllahName(
        number: 7,
        arabicName: 'المؤمن',
        transliteration: 'Al-Mu\'min',
        meaning: 'The Guardian of Faith',
        description: 'The One who grants security and peace to those who believe, and who protects the believers.',
      ),
      AllahName(
        number: 8,
        arabicName: 'المهيمن',
        transliteration: 'Al-Muhaymin',
        meaning: 'The Protector',
        description: 'The One who watches over His creation and protects them from all harm and danger.',
      ),
      AllahName(
        number: 9,
        arabicName: 'العزيز',
        transliteration: 'Al-Azeez',
        meaning: 'The Mighty One',
        description: 'The One who is invincible and cannot be overcome or defeated in any way.',
      ),
      AllahName(
        number: 10,
        arabicName: 'الجبار',
        transliteration: 'Al-Jabbar',
        meaning: 'The Compeller',
        description: 'The One whose will cannot be resisted and who compels all of creation to submit to His will.',
      ),
      // Continue with more names...
      AllahName(
        number: 99,
        arabicName: 'الصبور',
        transliteration: 'As-Sabur',
        meaning: 'The Patient One',
        description: 'The One who is patient and does not rush to punishment, giving His servants time to repent and return to Him.',
      ),
    ];
  }
}