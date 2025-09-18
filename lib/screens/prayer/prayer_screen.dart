import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../models/prayer_times.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePrayerData();
    });
  }
  
  Future<void> _initializePrayerData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context, listen: false);
    final prefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);

    // Ensure location is available
    if (!locationProvider.hasLocation) {
      await locationProvider.getCurrentLocation();
    }

    // Fetch prayer times if location is available
    if (locationProvider.hasLocation && 
        (prayerProvider.prayerTimes == null || prayerProvider.needsUpdate())) {
      await prayerProvider.fetchPrayerTimes(
        locationProvider.currentLocation!,
        prefsProvider.preferences.calculationMethod,
      );
    }
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
        title: const Text('Prayer Times'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Select Date',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Prayer Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayView(),
          _buildWeeklyView(),
          _buildMonthlyView(),
        ],
      ),
    );
  }

  Widget _buildTodayView() {
    return Consumer3<PrayerTimesProvider, LocationProvider, UserPreferencesProvider>(
      builder: (context, prayerProvider, locationProvider, prefsProvider, child) {
        if (prayerProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        }

        if (prayerProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                Text(
                  'Failed to load prayer times',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  prayerProvider.error!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    prayerProvider.clearError();
                    if (locationProvider.currentLocation != null) {
                      await prayerProvider.fetchPrayerTimes(
                        locationProvider.currentLocation!,
                        prefsProvider.preferences.calculationMethod,
                      );
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (prayerProvider.prayerTimes == null || !locationProvider.hasLocation) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 64, color: AppColors.mediumGrey),
                const SizedBox(height: 16),
                Text(
                  'Location Required',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enable location access to get accurate prayer times',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    await locationProvider.getCurrentLocation();
                    if (locationProvider.hasLocation) {
                      await prayerProvider.fetchPrayerTimes(
                        locationProvider.currentLocation!,
                        prefsProvider.preferences.calculationMethod,
                      );
                    }
                  },
                  child: const Text('Enable Location'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (locationProvider.currentLocation != null) {
              await prayerProvider.fetchPrayerTimes(
                locationProvider.currentLocation!,
                prefsProvider.preferences.calculationMethod,
              );
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLocationCard(locationProvider),
                const SizedBox(height: 16),
                _buildDateCard(prayerProvider),
                const SizedBox(height: 16),
                _buildNextPrayerCard(prayerProvider),
                const SizedBox(height: 16),
                _buildPrayerTimesList(prayerProvider.prayerTimes!),
                const SizedBox(height: 16),
                _buildAdditionalTimesCard(prayerProvider.prayerTimes!),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLocationCard(LocationProvider locationProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Location',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    locationProvider.locationString,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: locationProvider.isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              onPressed: locationProvider.isLoading
                  ? null
                  : () => locationProvider.getCurrentLocation(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateCard(PrayerTimesProvider prayerProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayerProvider.formattedGregorianDate,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (prayerProvider.formattedHijriDate.isNotEmpty)
                    Text(
                      prayerProvider.formattedHijriDate,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextPrayerCard(PrayerTimesProvider prayerProvider) {
    final nextPrayer = prayerProvider.getNextPrayer();
    final timeUntilNext = prayerProvider.getTimeUntilNextPrayerFormatted();

    if (nextPrayer == null) return Container();

    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: AppColors.prayerTimeGradient,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Prayer',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  nextPrayer.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  nextPrayer.time,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (timeUntilNext.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'in $timeUntilNext',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.white.withOpacity(0.9),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerTimesList(PrayerTimes prayerTimes) {
    final prayers = prayerTimes.prayerList;
    final nextPrayer = Provider.of<PrayerTimesProvider>(context, listen: false).getNextPrayer();

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Prayer Times',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...prayers.map((prayer) {
            final isNext = nextPrayer?.name == prayer.name;
            return Container(
              decoration: BoxDecoration(
                color: isNext ? AppColors.primaryGreen.withOpacity(0.1) : null,
                border: isNext ? Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.3),
                  width: 1,
                ) : null,
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isNext 
                        ? AppColors.primaryGreen 
                        : AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPrayerIcon(prayer.name),
                    color: isNext ? AppColors.white : AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                title: Text(
                  prayer.name,
                  style: TextStyle(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? AppColors.primaryGreen : null,
                  ),
                ),
                trailing: Text(
                  prayer.time,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                    color: isNext ? AppColors.primaryGreen : null,
                  ),
                ),
                onTap: () {
                  // Show prayer details or set reminder
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAdditionalTimesCard(PrayerTimes prayerTimes) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Additional Times',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny, color: AppColors.gold),
            title: const Text('Sunrise'),
            trailing: Text(
              prayerTimes.sunrise,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined, color: AppColors.gold),
            title: const Text('Sunset'),
            trailing: Text(
              prayerTimes.sunset,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.nights_stay, color: AppColors.ramadanBlue),
            title: const Text('Midnight'),
            trailing: Text(
              prayerTimes.midnight,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyView() {
    return Consumer3<PrayerTimesProvider, LocationProvider, UserPreferencesProvider>(
      builder: (context, prayerProvider, locationProvider, prefsProvider, child) {
        if (!locationProvider.hasLocation) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: AppColors.mediumGrey),
                SizedBox(height: 16),
                Text('Location Required'),
                SizedBox(height: 8),
                Text('Please enable location to see weekly prayer times'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Weekly Prayer Times',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Week selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.chevron_left),
                          ),
                          Text(
                            'Week of ${_formatWeekRange()}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Weekly prayer times grid
              ...List.generate(7, (index) {
                final date = DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1));
                return _buildDayPrayerCard(date, prayerProvider);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayPrayerCard(DateTime date, PrayerTimesProvider prayerProvider) {
    final dayName = _getDayName(date.weekday);
    final isToday = date.day == DateTime.now().day && 
                   date.month == DateTime.now().month && 
                   date.year == DateTime.now().year;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isToday ? AppColors.primaryGreen.withOpacity(0.1) : null,
          border: isToday ? Border.all(color: AppColors.primaryGreen, width: 1) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  dayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isToday ? AppColors.primaryGreen : null,
                  ),
                ),
                const Spacer(),
                Text(
                  '${date.day}/${date.month}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Prayer times for this day
            if (prayerProvider.prayerTimes != null) 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniPrayerTime('Fajr', prayerProvider.prayerTimes!.fajr),
                  _buildMiniPrayerTime('Dhuhr', prayerProvider.prayerTimes!.dhuhr),
                  _buildMiniPrayerTime('Asr', prayerProvider.prayerTimes!.asr),
                  _buildMiniPrayerTime('Maghrib', prayerProvider.prayerTimes!.maghrib),
                  _buildMiniPrayerTime('Isha', prayerProvider.prayerTimes!.isha),
                ],
              )
            else
              const Text(
                'Prayer times not available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPrayerTime(String name, String time) {
    return Column(
      children: [
        Text(
          name,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  String _formatWeekRange() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Monday';
      case 2: return 'Tuesday';
      case 3: return 'Wednesday';
      case 4: return 'Thursday';
      case 5: return 'Friday';
      case 6: return 'Saturday';
      case 7: return 'Sunday';
      default: return '';
    }
  }

  Widget _buildMonthlyView() {
    return Consumer3<PrayerTimesProvider, LocationProvider, UserPreferencesProvider>(
      builder: (context, prayerProvider, locationProvider, prefsProvider, child) {
        if (!locationProvider.hasLocation) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_off, size: 64, color: AppColors.mediumGrey),
                SizedBox(height: 16),
                Text('Location Required'),
                SizedBox(height: 8),
                Text('Please enable location to see monthly prayer times'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Monthly Prayer Times',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Month selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Text(
                        _getMonthYearText(),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Monthly calendar view placeholder
              Card(
                child: Container(
                  height: 400,
                  padding: const EdgeInsets.all(20),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month,
                          size: 64,
                          color: AppColors.mediumGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Monthly Calendar View',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Prayer times calendar coming soon!',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getMonthYearText() {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName.toLowerCase()) {
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

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
      // Fetch prayer times for selected date
    }
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Prayer Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Change Location'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to location settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.calculate),
              title: const Text('Calculation Method'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to calculation method settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Prayer Notifications'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to notification settings
              },
            ),
          ],
        ),
      ),
    );
  }
}