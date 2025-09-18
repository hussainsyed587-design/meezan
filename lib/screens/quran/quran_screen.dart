import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/quran_provider.dart';
import '../../models/quran.dart';
import '../../widgets/quran_surah_card.dart';
import '../../widgets/quran_reader_view.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Holy Quran'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearch,
            tooltip: 'Search',
          ),
          IconButton(
            icon: const Icon(Icons.bookmark),
            onPressed: _showBookmarks,
            tooltip: 'Bookmarks',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Surahs'),
            Tab(text: 'Juz'),
            Tab(text: 'Recent'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSurahsView(),
          _buildJuzView(),
          _buildRecentView(),
        ],
      ),
    );
  }

  Widget _buildSurahsView() {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        // Debug print to see what's happening
        debugPrint('Surahs loaded: ${quranProvider.surahs.length}');
        
        if (quranProvider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppColors.primaryGreen),
                SizedBox(height: 16),
                Text('Loading Quran...',
                    style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          );
        }
        
        if (quranProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text('Error: ${quranProvider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to reload
                    quranProvider.clearError();
                    quranProvider.refreshSurahs();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        if (quranProvider.surahs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.book, size: 64, color: AppColors.mediumGrey),
                const SizedBox(height: 16),
                const Text('No Surahs Available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Please check your internet connection',
                    style: TextStyle(color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    quranProvider.refreshSurahs();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final filteredSurahs = _searchQuery.isEmpty
            ? quranProvider.surahs
            : quranProvider.surahs.where((surah) =>
                surah.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                surah.name.contains(_searchQuery) ||
                surah.englishTranslation.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        return Column(
          children: [
            // Continue Reading Card
            if (quranProvider.lastReadSurah != null) ...[
              Container(
                margin: const EdgeInsets.all(16),
                child: _buildContinueReadingCard(quranProvider),
              ),
            ],

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Surahs...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            
            // Surahs count info
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Showing ${filteredSurahs.length} of ${quranProvider.surahs.length} Surahs',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Surahs List
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = filteredSurahs[index];
                  return QuranSurahCard(
                    surah: surah,
                    onTap: () => _openSurah(surah),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContinueReadingCard(QuranProvider quranProvider) {
    final lastSurah = quranProvider.getSurahByNumber(quranProvider.lastReadSurah!);
    if (lastSurah == null) return Container();

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: AppColors.greenGradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.bookmark,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Continue Reading',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lastSurah.englishName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              lastSurah.name,
              style: AppTheme.arabicTextStyle(
                fontSize: 18,
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ayah ${quranProvider.lastReadAyah ?? 1}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openSurah(lastSurah),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.primaryGreen,
              ),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJuzView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: AppColors.mediumGrey,
          ),
          SizedBox(height: 16),
          Text(
            'Juz View',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Coming Soon!',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentView() {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, child) {
        if (quranProvider.bookmarks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Bookmarks Yet',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start reading and bookmark your favorite verses',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quranProvider.bookmarks.length,
          itemBuilder: (context, index) {
            final bookmark = quranProvider.bookmarks[index];
            return Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bookmark,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: Text(bookmark.surahName),
                subtitle: Text('Ayah ${bookmark.ayahNumber}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _confirmDeleteBookmark(bookmark),
                ),
                onTap: () {
                  final surah = quranProvider.getSurahByNumber(bookmark.surahNumber);
                  if (surah != null) {
                    _openSurah(surah, initialAyah: bookmark.ayahNumber);
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  void _openSurah(QuranSurah surah, {int? initialAyah}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranReaderView(
          surah: surah,
          initialAyah: initialAyah,
        ),
      ),
    );
  }

  void _showSearch() {
    showSearch(
      context: context,
      delegate: QuranSearchDelegate(
        Provider.of<QuranProvider>(context, listen: false),
      ),
    );
  }

  void _showBookmarks() {
    _tabController.animateTo(2);
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Quran Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                
                // Font Size
                Row(
                  children: [
                    const Icon(Icons.text_fields),
                    const SizedBox(width: 16),
                    const Text('Font Size'),
                    const Spacer(),
                    Text('${quranProvider.fontSize.toInt()}'),
                  ],
                ),
                Slider(
                  value: quranProvider.fontSize,
                  min: 12,
                  max: 32,
                  divisions: 20,
                  onChanged: (value) => quranProvider.updateFontSize(value),
                ),
                
                // Translation Toggle
                SwitchListTile(
                  title: const Text('Show Translation'),
                  value: quranProvider.showTranslation,
                  onChanged: (_) => quranProvider.toggleTranslation(),
                ),
                
                // Transliteration Toggle
                SwitchListTile(
                  title: const Text('Show Transliteration'),
                  value: quranProvider.showTransliteration,
                  onChanged: (_) => quranProvider.toggleTransliteration(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _confirmDeleteBookmark(QuranBookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bookmark'),
        content: Text('Are you sure you want to delete this bookmark for ${bookmark.surahName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<QuranProvider>(context, listen: false)
                  .removeBookmark(bookmark.id);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class QuranSearchDelegate extends SearchDelegate<QuranSurah?> {
  final QuranProvider quranProvider;

  QuranSearchDelegate(this.quranProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    final filteredSurahs = query.isEmpty
        ? quranProvider.surahs
        : quranProvider.surahs.where((surah) =>
            surah.englishName.toLowerCase().contains(query.toLowerCase()) ||
            surah.name.contains(query) ||
            surah.englishTranslation.toLowerCase().contains(query.toLowerCase())
          ).toList();

    return ListView.builder(
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surah = filteredSurahs[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primaryGreen,
            child: Text(
              surah.number.toString(),
              style: const TextStyle(color: AppColors.white),
            ),
          ),
          title: Text(surah.englishName),
          subtitle: Text(surah.englishTranslation),
          trailing: Text(
            surah.name,
            style: AppTheme.arabicTextStyle(),
          ),
          onTap: () => close(context, surah),
        );
      },
    );
  }
}