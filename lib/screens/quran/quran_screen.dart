import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/quran_provider.dart';
import '../../models/quran.dart';
import './quran_reader_screen.dart'; 
import '../../widgets/quran_surah_card.dart';

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

        final filteredSurahs = _searchQuery.isEmpty
            ? quranProvider.surahs
            : quranProvider.surahs.where((surah) =>
                surah.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                surah.name.contains(_searchQuery) ||
                surah.englishTranslation.toLowerCase().contains(_searchQuery.toLowerCase())
              ).toList();

        return Column(
          children: [
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

  void _openSurah(QuranSurah surah, {int? initialAyah}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuranReaderScreen(
          surah: surah,
        ),
      ),
    );
  }

}
