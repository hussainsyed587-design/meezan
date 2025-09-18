import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

class NamazTrackerScreen extends StatefulWidget {
  const NamazTrackerScreen({super.key});

  @override
  State<NamazTrackerScreen> createState() => _NamazTrackerScreenState();
}

class _NamazTrackerScreenState extends State<NamazTrackerScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  
  // Prayer tracking data - In a real app, this would be stored in a database
  final Map<DateTime, Set<Prayer>> _prayerRecords = {};
  
  final List<Prayer> _prayers = [
    Prayer('Fajr', Icons.wb_twilight, AppColors.info),
    Prayer('Dhuhr', Icons.wb_sunny, AppColors.gold),
    Prayer('Asr', Icons.wb_sunny_outlined, AppColors.arabicAccent),
    Prayer('Maghrib', Icons.wb_twighlight, AppColors.ramadanBlue),
    Prayer('Isha', Icons.nightlight, AppColors.textPrimary),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Add some sample data for demonstration
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    _prayerRecords[yesterday] = {
      _prayers[0], // Fajr
      _prayers[1], // Dhuhr
      _prayers[2], // Asr
      _prayers[3], // Maghrib
    };
    
    _prayerRecords[today] = {
      _prayers[0], // Fajr
      _prayers[1], // Dhuhr
    };
  }

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
                'Namaz Tracker',
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
                child: Center(
                  child: Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _showMonthlyStats,
                icon: const Icon(Icons.bar_chart),
                tooltip: 'Monthly Statistics',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Calendar
                  _buildCalendar(),
                  
                  const SizedBox(height: 24),
                  
                  // Selected Day Prayer Tracking
                  _buildDayPrayerTracking(),
                  
                  const SizedBox(height: 24),
                  
                  // Monthly Progress
                  _buildMonthlyProgress(),
                  
                  const SizedBox(height: 100), // Bottom spacing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prayer Calendar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TableCalendar<Prayer>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) => (_prayerRecords[_normalizeDate(day)] ?? <Prayer>{}).toList(),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              calendarStyle: CalendarStyle(
                outsideDaysVisible: false,
                weekendTextStyle: const TextStyle(color: AppColors.textSecondary),
                holidayTextStyle: const TextStyle(color: AppColors.primaryGreen),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 5,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPrayerTracking() {
    final selectedDateNormalized = _normalizeDate(_selectedDay);
    final completedPrayers = _prayerRecords[selectedDateNormalized] ?? {};
    final isToday = isSameDay(_selectedDay, DateTime.now());
    final isFuture = _selectedDay.isAfter(DateTime.now());

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isToday 
                        ? 'Today\'s Prayers'
                        : 'Prayers for ${DateFormat('MMM d, y').format(_selectedDay)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (isFuture) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.info.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.info),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Future date - prayers not yet due'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 20),
              
              // Prayer completion progress
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen.withOpacity(0.1),
                      AppColors.primaryGreen.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${completedPrayers.length}/5',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prayers Completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: completedPrayers.length / 5,
                      backgroundColor: AppColors.lightGrey,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Individual prayer checkboxes
              ..._prayers.map((prayer) {
                final isCompleted = completedPrayers.contains(prayer);
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    elevation: 1,
                    child: CheckboxListTile(
                      value: isCompleted,
                      onChanged: (value) => _togglePrayer(prayer, value ?? false),
                      title: Row(
                        children: [
                          Icon(
                            prayer.icon,
                            color: prayer.color,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            prayer.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : TextDecoration.none,
                            ),
                          ),
                        ],
                      ),
                      activeColor: AppColors.primaryGreen,
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyProgress() {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    int totalPrayers = 0;
    int completedPrayers = 0;
    
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(now.year, now.month, day);
      if (date.isAfter(now)) break; // Don't count future days
      
      totalPrayers += 5; // 5 prayers per day
      final dayRecords = _prayerRecords[_normalizeDate(date)] ?? {};
      completedPrayers += dayRecords.length;
    }
    
    final completionRate = totalPrayers > 0 ? (completedPrayers / totalPrayers) * 100 : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'This Month\'s Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Completion Rate',
                    '${completionRate.toStringAsFixed(1)}%',
                    Icons.percent,
                    AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Total Prayers',
                    '$completedPrayers/$totalPrayers',
                    Icons.check_circle,
                    AppColors.success,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Monthly completion bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Monthly Goal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '${(completionRate).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: AppColors.lightGrey,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _togglePrayer(Prayer prayer, bool isCompleted) {
    setState(() {
      final selectedDateNormalized = _normalizeDate(_selectedDay);
      
      if (!_prayerRecords.containsKey(selectedDateNormalized)) {
        _prayerRecords[selectedDateNormalized] = <Prayer>{};
      }
      
      if (isCompleted) {
        _prayerRecords[selectedDateNormalized]!.add(prayer);
      } else {
        _prayerRecords[selectedDateNormalized]!.remove(prayer);
      }
    });
  }

  void _showMonthlyStats() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Statistics'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add detailed monthly statistics here
              Text(
                'Detailed statistics will be implemented here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class Prayer {
  final String name;
  final IconData icon;
  final Color color;

  Prayer(this.name, this.icon, this.color);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Prayer && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}