import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../providers/prayer_times_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../widgets/prayer_times_card.dart';
import '../../widgets/quick_access_grid.dart';
import '../../widgets/islamic_content_card.dart';
import '../../widgets/hijri_date_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context, listen: false);
    final prefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);

    // Ensure location is available - try to get current location if not already set
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

  Future<void> _refreshData() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    final prayerProvider = Provider.of<PrayerTimesProvider>(context, listen: false);
    final prefsProvider = Provider.of<UserPreferencesProvider>(context, listen: false);

    if (locationProvider.hasLocation) {
      await prayerProvider.fetchPrayerTimes(
        locationProvider.currentLocation!,
        prefsProvider.preferences.calculationMethod,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: AppColors.primaryGreen,
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.primaryGreen,
              flexibleSpace: FlexibleSpaceBar(
                title: Consumer<UserPreferencesProvider>(
                  builder: (context, prefsProvider, child) {
                    final greeting = _getIslamicGreeting();
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          greeting,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          AppConstants.appName,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
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
              actions: [
                Consumer<LocationProvider>(
                  builder: (context, locationProvider, child) {
                    return IconButton(
                      icon: const Icon(Icons.location_on, color: AppColors.white),
                      onPressed: () => locationProvider.getCurrentLocation(),
                      tooltip: locationProvider.locationString,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: AppColors.white),
                  onPressed: () {
                    // Navigate to settings
                  },
                ),
              ],
            ),

            // Main Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hijri Date Card
                    const HijriDateCard(),
                    
                    const SizedBox(height: 16),
                    
                    // Prayer Times Card
                    const PrayerTimesCard(),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Access Section
                    Text(
                      'Quick Access',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const QuickAccessGrid(),
                    
                    const SizedBox(height: 24),
                    
                    // Islamic Content Section
                    Text(
                      'Daily Islamic Content',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    const IslamicContentCard(),
                    
                    const SizedBox(height: 100), // Bottom spacing for navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getIslamicGreeting() {
    final hour = DateTime.now().hour;
    
    if (hour >= 5 && hour < 12) {
      return 'صباح الخير • Good Morning';
    } else if (hour >= 12 && hour < 15) {
      return 'ظهر مبارك • Blessed Noon';
    } else if (hour >= 15 && hour < 18) {
      return 'عصر مبارك • Blessed Afternoon';
    } else if (hour >= 18 && hour < 21) {
      return 'مساء الخير • Good Evening';
    } else {
      return 'ليلة مباركة • Blessed Night';
    }
  }
}