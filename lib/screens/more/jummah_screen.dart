import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';
import '../../providers/prayer_times_provider.dart';
import '../../widgets/quran_reader_view.dart';
import '../../models/quran.dart';

class JummahScreen extends StatefulWidget {
  const JummahScreen({super.key});

  @override
  State<JummahScreen> createState() => _JummahScreenState();
}

class _JummahScreenState extends State<JummahScreen> {
  final List<JummahTask> _jummahTasks = [
    JummahTask(
      id: '1',
      title: 'Take Ghusl (Full Bath)',
      arabic: 'الغُسل',
      description: 'Purify yourself with a complete bath',
      isCompleted: false,
    ),
    JummahTask(
      id: '2',
      title: 'Read Surah Al-Kahf',
      arabic: 'سورة الكهف',
      description: 'Recite the 18th chapter of the Quran',
      isCompleted: false,
    ),
    JummahTask(
      id: '3',
      title: 'Send Salawat on Prophet ﷺ',
      arabic: 'الصلاة على النبي',
      description: 'Send blessings upon Prophet Muhammad ﷺ',
      isCompleted: false,
    ),
    JummahTask(
      id: '4',
      title: 'Make Special Dua',
      arabic: 'الدعاء الخاص',
      description: 'Make sincere supplications',
      isCompleted: false,
    ),
    JummahTask(
      id: '5',
      title: 'Arrive Early for Khutbah',
      arabic: 'الحضور المبكر',
      description: 'Reach mosque before Khutbah starts',
      isCompleted: false,
    ),
    JummahTask(
      id: '6',
      title: 'Wear Clean Clothes',
      arabic: 'الثياب النظيفة',
      description: 'Dress in your best clean attire',
      isCompleted: false,
    ),
  ];

  final List<String> _hadithCollection = [
    "The Prophet ﷺ said: 'Friday is the best of days. Adam was created on it, and on it he died.' [Muslim]",
    "The Prophet ﷺ said: 'Whoever reads Surah Al-Kahf on Friday, it will illuminate him with light from one Friday to the next.' [Al-Hakim]",
    "The Prophet ﷺ said: 'Send Salawat upon me abundantly on Friday, for your Salawat is presented to me.' [Abu Dawud]",
    "The Prophet ﷺ said: 'On Friday there is an hour when Allah answers the dua of every Muslim who asks for something good.' [Bukhari & Muslim]",
    "The Prophet ﷺ said: 'Whoever takes a bath on Friday and comes early to the mosque, it is as if he offered a camel in sacrifice.' [Bukhari & Muslim]",
  ];

  int _currentHadithIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isJummah = DateTime.now().weekday == DateTime.friday;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar with Jummah Greeting
          SliverAppBar(
            expandedHeight: 160,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.gold,
            flexibleSpace: FlexibleSpaceBar(
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '🌙 جمعة مباركة',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      fontFamily: 'Arabic',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Jummah Mubarak',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.gold,
                      AppColors.gold.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.wb_sunny,
                    size: 80,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jummah Status
                  _buildJummahStatusCard(isJummah),
                  
                  const SizedBox(height: 24),

                  // Jummah Prayer Time
                  _buildJummahPrayerTime(),
                  
                  const SizedBox(height: 24),

                  // Jummah Checklist
                  _buildJummahChecklist(),
                  
                  const SizedBox(height: 24),

                  // Surah Al-Kahf Section
                  _buildSurahKahfSection(),
                  
                  const SizedBox(height: 24),

                  // Friday Duas
                  _buildFridayDuas(),
                  
                  const SizedBox(height: 24),

                  // Hadith Slider
                  _buildHadithSlider(),
                  
                  const SizedBox(height: 24),

                  // Share Jummah Greetings
                  _buildShareSection(),
                  
                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJummahStatusCard(bool isJummah) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isJummah 
              ? [AppColors.primaryGreen, AppColors.mosqueGreen]
              : [AppColors.mediumGrey, AppColors.lightGrey],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            isJummah ? Icons.check_circle : Icons.schedule,
            size: 48,
            color: AppColors.white,
          ),
          const SizedBox(height: 12),
          Text(
            isJummah ? 'Today is Jummah!' : 'Next Jummah',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isJummah 
                ? 'May Allah accept your prayers'
                : _getNextJummahText(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildJummahPrayerTime() {
    return Consumer<PrayerTimesProvider>(
      builder: (context, prayerProvider, child) {
        final jummahTime = prayerProvider.prayerTimes?.dhuhr ?? 'Not Available';
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.access_time,
                  color: AppColors.primaryGreen,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jummah Prayer Time',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        jummahTime,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildJummahChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jummah Preparation Checklist',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._jummahTasks.map((task) => _buildChecklistItem(task)),
      ],
    );
  }

  Widget _buildChecklistItem(JummahTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: task.isCompleted,
        onChanged: (value) {
          setState(() {
            task.isCompleted = value ?? false;
          });
        },
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted 
                ? TextDecoration.lineThrough 
                : TextDecoration.none,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              task.arabic,
              style: const TextStyle(
                fontFamily: 'Arabic',
                fontSize: 16,
                color: AppColors.primaryGreen,
              ),
            ),
            Text(task.description),
          ],
        ),
        activeColor: AppColors.primaryGreen,
      ),
    );
  }

  Widget _buildSurahKahfSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.book,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Surah Al-Kahf (Chapter 18)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'سورة الكهف',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontFamily: 'Arabic',
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'It is recommended to read Surah Al-Kahf every Friday. The Prophet ﷺ said: "Whoever reads Surah Al-Kahf on Friday, it will illuminate him with light from one Friday to the next."',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to Surah Al-Kahf in Quran reader
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Navigate to Surah Al-Kahf in Quran section'),
                      backgroundColor: AppColors.primaryGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Read Surah Al-Kahf'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFridayDuas() {
    final fridayDuas = [
      {
        'title': 'Dua between Asr and Maghrib',
        'arabic': 'اللَّهُمَّ اغْفِرْ لِي ذَنْبِي',
        'transliteration': 'Allahumma-ghfir li dhanbi',
        'translation': 'O Allah, forgive my sins',
      },
      {
        'title': 'Salawat on Prophet ﷺ',
        'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ',
        'transliteration': 'Allahumma salli ala Muhammadin wa ala ali Muhammad',
        'translation': 'O Allah, send blessings upon Muhammad and his family',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Friday Duas',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...fridayDuas.map((dua) => _buildDuaCard(dua)),
      ],
    );
  }

  Widget _buildDuaCard(Map<String, String> dua) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dua['title']!,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              dua['arabic']!,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Arabic',
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              dua['transliteration']!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dua['translation']!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHadithSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Friday Hadith',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: _previousHadith,
                  icon: const Icon(Icons.arrow_back_ios),
                  color: AppColors.primaryGreen,
                ),
                Text(
                  '${_currentHadithIndex + 1}/${_hadithCollection.length}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  onPressed: _nextHadith,
                  icon: const Icon(Icons.arrow_forward_ios),
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.format_quote,
                  size: 32,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 12),
                Text(
                  _hadithCollection[_currentHadithIndex],
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildShareSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              Icons.share,
              size: 32,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            Text(
              'Share Jummah Greetings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Spread the blessings of Friday',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _shareJummahGreeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Share Jummah Mubarak'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousHadith() {
    setState(() {
      _currentHadithIndex = (_currentHadithIndex - 1 + _hadithCollection.length) % _hadithCollection.length;
    });
  }

  void _nextHadith() {
    setState(() {
      _currentHadithIndex = (_currentHadithIndex + 1) % _hadithCollection.length;
    });
  }

  void _shareJummahGreeting() {
    // Implement share functionality
    const message = """
🌙 جمعة مباركة - Jummah Mubarak! 🌙

May Allah accept your prayers and bless your Friday.

"Friday is the best of days." - Prophet Muhammad ﷺ

#JummahMubarak #Meezan
""";
    
    // You can use share_plus package to implement sharing
    // Share.share(message);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Jummah greeting copied to share!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  String _getNextJummahText() {
    final now = DateTime.now();
    final daysUntilFriday = (DateTime.friday - now.weekday) % 7;
    final nextFriday = now.add(Duration(days: daysUntilFriday == 0 ? 7 : daysUntilFriday));
    final formatter = DateFormat('EEEE, MMM d');
    return 'Next Jummah: ${formatter.format(nextFriday)}';
  }
}

class JummahTask {
  final String id;
  final String title;
  final String arabic;
  final String description;
  bool isCompleted;

  JummahTask({
    required this.id,
    required this.title,
    required this.arabic,
    required this.description,
    required this.isCompleted,
  });
}