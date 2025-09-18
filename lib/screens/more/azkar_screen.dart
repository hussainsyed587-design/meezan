import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

class AzkarScreen extends StatefulWidget {
  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final Map<String, List<AzkarItem>> _azkarCategories = {
    'Morning': [
      AzkarItem(
        id: '1',
        arabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
        transliteration: 'A\'oothu billaahi minash-shaytaanir-rajeem',
        translation: 'I seek refuge in Allah from Satan the outcast',
        count: 1,
        completedCount: 0,
      ),
      AzkarItem(
        id: '2',
        arabic: 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        transliteration: 'Bismillaahir-Rahmaanir-Raheem',
        translation: 'In the name of Allah, the Most Gracious, the Most Merciful',
        count: 1,
        completedCount: 0,
      ),
      AzkarItem(
        id: '3',
        arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: 'Alhamdu lillaahi rabbil-\'aalameen',
        translation: 'All praise is for Allah, Lord of the worlds',
        count: 3,
        completedCount: 0,
      ),
    ],
    'Evening': [
      AzkarItem(
        id: '4',
        arabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ',
        transliteration: 'Amsaynaa wa-amsal-mulku lillaahi',
        translation: 'We have reached the evening and at this very time the whole kingdom belongs to Allah',
        count: 1,
        completedCount: 0,
      ),
      AzkarItem(
        id: '5',
        arabic: 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا',
        transliteration: 'Allaahumma bika amsaynaa wa bika asbahnaa',
        translation: 'O Allah, by You we have reached the evening and by You we have reached the morning',
        count: 1,
        completedCount: 0,
      ),
    ],
    'After Prayer': [
      AzkarItem(
        id: '6',
        arabic: 'اللَّهُ أَكْبَرُ',
        transliteration: 'Allaahu Akbar',
        translation: 'Allah is the Greatest',
        count: 34,
        completedCount: 0,
      ),
      AzkarItem(
        id: '7',
        arabic: 'الْحَمْدُ لِلَّهِ',
        transliteration: 'Alhamdu lillaah',
        translation: 'All praise is for Allah',
        count: 33,
        completedCount: 0,
      ),
      AzkarItem(
        id: '8',
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Subhaanallaah',
        translation: 'Glory be to Allah',
        count: 33,
        completedCount: 0,
      ),
    ],
    'Sleep': [
      AzkarItem(
        id: '9',
        arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
        transliteration: 'Bismika Allaahumma amootu wa ahyaa',
        translation: 'In Your name O Allah, I die and I live',
        count: 1,
        completedCount: 0,
      ),
    ],
    'Protection': [
      AzkarItem(
        id: '10',
        arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        transliteration: 'Qul huwa Allaahu ahad',
        translation: 'Say: He is Allah, the One',
        count: 3,
        completedCount: 0,
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _azkarCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.mosqueGreen,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Azkar & Dhikr',
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
                        AppColors.mosqueGreen,
                        AppColors.mosqueGreen.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.auto_awesome,
                      size: 80,
                      color: AppColors.white.withOpacity(0.3),
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _resetAllProgress,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset Progress',
                ),
              ],
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: AppColors.primaryGreen,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primaryGreen,
                  tabs: _azkarCategories.keys.map((category) {
                    return Tab(text: category);
                  }).toList(),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _azkarCategories.entries.map((entry) {
            return _buildAzkarList(entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildAzkarList(String category, List<AzkarItem> azkarList) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: azkarList.length,
      itemBuilder: (context, index) {
        final azkar = azkarList[index];
        return _buildAzkarCard(azkar);
      },
    );
  }

  Widget _buildAzkarCard(AzkarItem azkar) {
    final progress = azkar.count > 0 ? azkar.completedCount / azkar.count : 0.0;
    final isCompleted = azkar.completedCount >= azkar.count;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Arabic Text
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
              child: Text(
                azkar.arabic,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Arabic',
                  color: AppColors.textPrimary,
                  height: 2.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Transliteration
            Text(
              azkar.transliteration,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Translation
            Text(
              azkar.translation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Progress and Counter
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            '${azkar.completedCount}/${azkar.count}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? AppColors.success : AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppColors.lightGrey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? AppColors.success : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                
                // Counter Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isCompleted 
                        ? AppColors.success 
                        : AppColors.primaryGreen,
                  ),
                  child: IconButton(
                    onPressed: isCompleted ? null : () => _incrementCount(azkar),
                    icon: Icon(
                      isCompleted ? Icons.check : Icons.add,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
            
            // Reset button for completed azkar
            if (isCompleted) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _resetAzkar(azkar),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _incrementCount(AzkarItem azkar) {
    setState(() {
      if (azkar.completedCount < azkar.count) {
        azkar.completedCount++;
      }
    });
    
    // Haptic feedback
    // HapticFeedback.lightImpact();
    
    // Show completion message
    if (azkar.completedCount == azkar.count) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${azkar.transliteration} completed! 🎉'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _resetAzkar(AzkarItem azkar) {
    setState(() {
      azkar.completedCount = 0;
    });
  }

  void _resetAllProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Progress'),
        content: const Text('Are you sure you want to reset all Azkar progress?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                for (final category in _azkarCategories.values) {
                  for (final azkar in category) {
                    azkar.completedCount = 0;
                  }
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All progress reset'),
                  backgroundColor: AppColors.primaryGreen,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class AzkarItem {
  final String id;
  final String arabic;
  final String transliteration;
  final String translation;
  final int count;
  int completedCount;

  AzkarItem({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translation,
    required this.count,
    required this.completedCount,
  });
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}