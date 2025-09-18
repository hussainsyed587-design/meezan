import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_preferences_provider.dart';
import '../calendar/calendar_screen.dart';

import '../statistics/prayer_statistics_screen.dart';
import '../audio/audio_player_screen.dart';
import 'jummah_screen.dart';
import 'azkar_screen.dart';
import 'namaz_tracker_screen.dart';
import 'hadith_screen.dart';
import 'settings_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primaryGreen,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'More Features',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.greenGradient,
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Islamic Features Section
                  _buildSectionHeader(context, 'Islamic Features'),
                  const SizedBox(height: 12),
                  _buildFeaturesList([
                    MoreItem(
                      icon: Icons.wb_sunny,
                      title: 'Jummah',
                      subtitle: 'Friday Special Features',
                      color: AppColors.gold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const JummahScreen()),
                      ),
                    ),
                    MoreItem(
                      icon: Icons.auto_awesome,
                      title: 'Azkar',
                      subtitle: 'Morning & Evening Dhikr',
                      color: AppColors.mosqueGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AzkarScreen()),
                      ),
                    ),
                    MoreItem(
                      icon: Icons.check_circle,
                      title: 'Namaz Tracker',
                      subtitle: 'Track Your Daily Prayers',
                      color: AppColors.primaryGreen,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NamazTrackerScreen()),
                      ),
                    ),
                    MoreItem(
                      icon: Icons.menu_book,
                      title: 'Hadith of the Day',
                      subtitle: 'Daily Authentic Hadith',
                      color: AppColors.arabicAccent,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HadithScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Tools & Features Section
                  _buildSectionHeader(context, 'Tools & Features'),
                  const SizedBox(height: 12),
                  _buildFeaturesList([
                    MoreItem(
                      icon: Icons.calendar_month,
                      title: 'Islamic Calendar',
                      subtitle: 'Hijri Events & Fasting',
                      color: AppColors.info,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      ),
                    ),

                    MoreItem(
                      icon: Icons.bar_chart,
                      title: 'Prayer Statistics',
                      subtitle: 'Track Your Progress',
                      color: AppColors.ramadanBlue,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrayerStatisticsScreen()),
                      ),
                    ),
                    MoreItem(
                      icon: Icons.headphones,
                      title: 'Audio Recitations',
                      subtitle: 'Listen to Quran',
                      color: AppColors.quranicGold,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AudioPlayerScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Settings Section
                  _buildSectionHeader(context, 'App Settings'),
                  const SizedBox(height: 12),
                  _buildFeaturesList([
                    MoreItem(
                      icon: Icons.settings,
                      title: 'Settings',
                      subtitle: 'Preferences & Configuration',
                      color: AppColors.textSecondary,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsScreen()),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildFeaturesList(List<MoreItem> items) {
    return Column(
      children: items.map((item) => _MoreItemCard(item: item)).toList(),
    );
  }
}

class _MoreItemCard extends StatelessWidget {
  final MoreItem item;

  const _MoreItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Card(
        elevation: 1,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 24,
            ),
          ),
          title: Text(
            item.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            item.subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.textSecondary,
            size: 16,
          ),
          onTap: item.onTap,
        ),
      ),
    );
  }
}

class MoreItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const MoreItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}