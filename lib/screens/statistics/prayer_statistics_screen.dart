import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/app_colors.dart';
import '../../providers/prayer_statistics_provider.dart';
import '../../models/prayer_statistics.dart';
import '../../widgets/prayer_completion_chart.dart';
import '../../widgets/prayer_trends_chart.dart';
import '../../widgets/statistics_card.dart';

class PrayerStatisticsScreen extends StatelessWidget {
  const PrayerStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrayerStatisticsProvider(),
      child: const _PrayerStatisticsContent(),
    );
  }
}

class _PrayerStatisticsContent extends StatefulWidget {
  const _PrayerStatisticsContent();

  @override
  State<_PrayerStatisticsContent> createState() => _PrayerStatisticsContentState();
}

class _PrayerStatisticsContentState extends State<_PrayerStatisticsContent> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Statistics'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showPeriodSelector,
            tooltip: 'Select Period',
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 16),
                    SizedBox(width: 8),
                    Text('Export Data'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 16, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Clear Data', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Trends'),
            Tab(text: 'Streaks'),
            Tab(text: 'Details'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildTrendsTab(),
          _buildStreaksTab(),
          _buildDetailsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer<PrayerStatisticsProvider>(
      builder: (context, statsProvider, child) {
        if (statsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (statsProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Error loading statistics',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  statsProvider.error!,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    statsProvider.clearError();
                    // Reload statistics
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final stats = statsProvider.currentStatistics;
        if (stats == null || stats.totalPrayers == 0) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.greenGradient,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.white),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stats.periodDescription,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_formatDate(stats.periodStart)} - ${_formatDate(stats.periodEnd)}',
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Key Metrics Row
              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: 'Completion',
                      value: '${stats.completionRate.toStringAsFixed(1)}%',
                      icon: Icons.check_circle,
                      color: AppColors.success,
                      subtitle: '${stats.completedPrayers}/${stats.totalPrayers}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatisticsCard(
                      title: 'Punctuality',
                      value: '${stats.punctualityRate.toStringAsFixed(1)}%',
                      icon: Icons.schedule,
                      color: AppColors.primaryGreen,
                      subtitle: 'On-time prayers',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: StatisticsCard(
                      title: 'Jamaat',
                      value: '${stats.jamaatRate.toStringAsFixed(1)}%',
                      icon: Icons.groups,
                      color: AppColors.gold,
                      subtitle: '${stats.jamaatPrayers} prayers',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatisticsCard(
                      title: 'Timeliness',
                      value: _formatTimeliness(stats.averageTimeliness),
                      icon: Icons.timer,
                      color: _getTimelinessColor(stats.averageTimeliness),
                      subtitle: 'Average',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Completion Chart
              Text(
                'Prayer Completion',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 200,
                child: PrayerCompletionChart(statistics: stats),
              ),

              const SizedBox(height: 24),

              // Prayer Breakdown
              Text(
                'Prayer Breakdown',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              ...stats.prayerCounts.entries.map((entry) {
                final prayer = entry.key;
                final count = entry.value;
                final completionRate = stats.prayerCompletionRates[prayer] ?? 0.0;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.lightGrey),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPrayerIcon(prayer),
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              prayer,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$count prayers recorded',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${completionRate.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.lightGrey,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              widthFactor: completionRate / 100,
                              alignment: Alignment.centerLeft,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTrendsTab() {
    return Consumer<PrayerStatisticsProvider>(
      builder: (context, statsProvider, child) {
        final trends = statsProvider.getPrayerCompletionTrends(30);
        
        if (trends.isEmpty) {
          return _buildEmptyState();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prayer Trends (Last 30 Days)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 300,
                child: PrayerTrendsChart(trends: trends),
              ),

              const SizedBox(height: 24),

              // Weekly Progress
              if (statsProvider.weeklyProgress != null) ...[
                Text(
                  'This Week Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildWeeklyProgressCard(statsProvider.weeklyProgress!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStreaksTab() {
    return Consumer<PrayerStatisticsProvider>(
      builder: (context, statsProvider, child) {
        final currentStreak = statsProvider.currentStreak;
        final longestStreak = statsProvider.longestStreak;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Streak
              if (currentStreak != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.greenGradient,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        size: 48,
                        color: AppColors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Current Streak',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${currentStreak.currentStreak}',
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'days',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.8),
                        ),
                      ),
                      if (currentStreak.streakStartDate != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Since ${_formatDate(currentStreak.streakStartDate!)}',
                          style: TextStyle(
                            color: AppColors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
              ],

              // Streak Types
              Text(
                'Streak Records',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildStreakCard(
                'Perfect Days',
                'Complete all 5 prayers',
                currentStreak?.currentStreak ?? 0,
                longestStreak?.longestStreak ?? 0,
                Icons.star,
                AppColors.gold,
              ),

              const SizedBox(height: 12),

              _buildStreakCard(
                'Consistent Days',
                'Complete 80% or more prayers',
                longestStreak?.currentStreak ?? 0,
                longestStreak?.longestStreak ?? 0,
                Icons.trending_up,
                AppColors.primaryGreen,
              ),

              const SizedBox(height: 24),

              // Motivational Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.lightGrey),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 48,
                      color: AppColors.gold,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Keep Going!',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getMotivationalMessage(currentStreak?.currentStreak ?? 0),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsTab() {
    return Consumer<PrayerStatisticsProvider>(
      builder: (context, statsProvider, child) {
        final records = statsProvider.prayerRecords;
        
        if (records.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[records.length - 1 - index]; // Reverse order
            return _buildRecordCard(record);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bar_chart,
            size: 64,
            color: AppColors.mediumGrey,
          ),
          SizedBox(height: 16),
          Text(
            'No Prayer Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start tracking your prayers to see statistics',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressCard(WeeklyProgress progress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Progress',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${progress.weeklyCompletionRate.toStringAsFixed(1)}%',
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Week days
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (index) {
              final weekday = index + 1;
              final dayStats = progress.dailyStats[weekday];
              final completionRate = dayStats?.completionRate ?? 0.0;
              
              return Column(
                children: [
                  Text(
                    _getWeekdayShort(weekday),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 8,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.lightGrey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      heightFactor: completionRate / 100,
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          
          const SizedBox(height: 12),
          Text(
            '${progress.totalCompletedPrayers}/${progress.totalPossiblePrayers} prayers completed',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(
    String title,
    String description,
    int current,
    int longest,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$current',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'Best: $longest',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(PrayerRecord record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.lightGrey),
      ),
      child: Row(
        children: [
          Icon(
            _getPrayerIcon(record.prayerName),
            color: _getStatusColor(record.status),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.prayerName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  _formatDateTime(record.scheduledTime),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getStatusText(record.status),
                style: TextStyle(
                  color: _getStatusColor(record.status),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (record.timeliness != null) ...[
                Text(
                  _formatTimeliness(record.timeliness!),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.wb_sunny_outlined;
      case 'maghrib':
        return Icons.wb_sunny_outlined;
      case 'isha':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }

  Color _getStatusColor(PrayerStatus status) {
    switch (status) {
      case PrayerStatus.completed:
      case PrayerStatus.onTime:
        return AppColors.success;
      case PrayerStatus.early:
        return AppColors.primaryGreen;
      case PrayerStatus.late:
        return AppColors.warning;
      case PrayerStatus.missed:
        return AppColors.error;
      case PrayerStatus.pending:
        return AppColors.mediumGrey;
    }
  }

  String _getStatusText(PrayerStatus status) {
    switch (status) {
      case PrayerStatus.completed:
        return 'Completed';
      case PrayerStatus.onTime:
        return 'On Time';
      case PrayerStatus.early:
        return 'Early';
      case PrayerStatus.late:
        return 'Late';
      case PrayerStatus.missed:
        return 'Missed';
      case PrayerStatus.pending:
        return 'Pending';
    }
  }

  Color _getTimelinessColor(double timeliness) {
    if (timeliness <= -5) return AppColors.primaryGreen; // Early
    if (timeliness >= 5) return AppColors.warning; // Late
    return AppColors.success; // On time
  }

  String _formatTimeliness(double minutes) {
    if (minutes == 0) return 'On time';
    if (minutes > 0) return '+${minutes.toStringAsFixed(0)}m';
    return '${minutes.toStringAsFixed(0)}m';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getWeekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMotivationalMessage(int streak) {
    if (streak == 0) {
      return 'Start your prayer journey today!';
    } else if (streak < 3) {
      return 'Great start! Keep building your routine.';
    } else if (streak < 7) {
      return 'You\'re doing amazing! Almost a week strong.';
    } else if (streak < 30) {
      return 'Excellent consistency! You\'re building a strong habit.';
    } else {
      return 'Outstanding dedication! You\'re an inspiration.';
    }
  }

  void _showPeriodSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: StatisticsPeriod.values.map((period) {
            return RadioListTile<StatisticsPeriod>(
              title: Text(_getPeriodName(period)),
              value: period,
              groupValue: Provider.of<PrayerStatisticsProvider>(context, listen: false).currentPeriod,
              onChanged: (value) {
                if (value != null) {
                  Provider.of<PrayerStatisticsProvider>(context, listen: false)
                      .setPeriod(value);
                  Navigator.pop(context);
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  String _getPeriodName(StatisticsPeriod period) {
    switch (period) {
      case StatisticsPeriod.today:
        return 'Today';
      case StatisticsPeriod.thisWeek:
        return 'This Week';
      case StatisticsPeriod.thisMonth:
        return 'This Month';
      case StatisticsPeriod.thisYear:
        return 'This Year';
      case StatisticsPeriod.allTime:
        return 'All Time';
      case StatisticsPeriod.custom:
        return 'Custom Range';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportData();
        break;
      case 'clear':
        _confirmClearData();
        break;
    }
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _confirmClearData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to clear all prayer tracking data? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<PrayerStatisticsProvider>(context, listen: false)
                  .clearAllRecords();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All prayer data cleared')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
