import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_preferences_provider.dart';
import '../../providers/location_provider.dart';
import '../navigation/main_navigation.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  // Onboarding data
  String _selectedLanguage = 'en';
  String _selectedMadhab = 'Hanafi';
  int _selectedCalculationMethod = 4; // ISNA
  bool _notificationsEnabled = true;
  bool _athanEnabled = true;
  String _selectedAthanSound = 'default';

  final List<String> _languages = [
    'English',
    'العربية',
    'اردو',
    'Türkçe',
    'Français',
    'Bahasa Malaysia'
  ];

  final List<String> _languageCodes = [
    'en',
    'ar', 
    'ur',
    'tr',
    'fr',
    'ms'
  ];

  final List<String> _madhabs = [
    'Hanafi',
    'Shafi\'i',
    'Maliki',
    'Hanbali'
  ];

  final List<Map<String, dynamic>> _calculationMethods = [
    {'name': 'Islamic Society of North America (ISNA)', 'id': 4},
    {'name': 'Muslim World League', 'id': 3},
    {'name': 'Umm Al-Qura University, Makkah', 'id': 7},
    {'name': 'University of Islamic Sciences, Karachi', 'id': 1},
    {'name': 'Egyptian General Authority of Survey', 'id': 5},
  ];

  final List<Map<String, String>> _athanSounds = [
    {'name': 'Default Athan', 'value': 'default'},
    {'name': 'Makkah Athan', 'value': 'makkah'},
    {'name': 'Madinah Athan', 'value': 'madinah'},
    {'name': 'Short Beep', 'value': 'beep'},
    {'name': 'Silent', 'value': 'silent'},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.greenGradient,
                stops: [0.0, 0.3, 1.0],
              ),
            ),
          ),
          
          // Content
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildWelcomePage(),
              _buildLanguagePage(),
              _buildLocationPage(),
              _buildPrayerSettingsPage(),
              _buildNotificationSettingsPage(),
            ],
          ),
          
          // Page indicator and navigation
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_totalPages, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: _currentPage == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                            ? AppColors.white 
                            : AppColors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                
                const SizedBox(height: 24),
                
                // Navigation buttons
                Row(
                  children: [
                    if (_currentPage > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.white),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    
                    if (_currentPage > 0) const SizedBox(width: 16),
                    
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _currentPage == _totalPages - 1 
                            ? _completeOnboarding 
                            : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),
                        child: Text(_currentPage == _totalPages - 1 ? 'Get Started' : 'Next'),
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

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // App logo/icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque,
              size: 60,
              color: AppColors.primaryGreen,
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'مرحباً بكم في ميزان',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arabic',
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Welcome to Meezan',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Your comprehensive Islamic companion for prayer times, Quran, and spiritual guidance.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.9),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Features preview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureIcon(Icons.schedule, 'Prayer Times'),
              _buildFeatureIcon(Icons.book, 'Holy Quran'),
              _buildFeatureIcon(Icons.explore, 'Qibla'),
              _buildFeatureIcon(Icons.calendar_month, 'Calendar'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 100),
          
          Icon(
            Icons.language,
            size: 80,
            color: AppColors.white,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Choose Your Language',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Select your preferred language for the app interface',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          Expanded(
            child: ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final code = _languageCodes[index];
                final isSelected = _selectedLanguage == code;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.9),
                    child: ListTile(
                      title: Text(
                        language,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected 
                          ? const Icon(Icons.check, color: AppColors.primaryGreen)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = code;
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 100),
          
          Icon(
            Icons.location_on,
            size: 80,
            color: AppColors.white,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Enable Location Access',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'We need your location to provide accurate prayer times and Qibla direction for your area.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.8),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.white.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Your Privacy Matters',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your location data is stored locally on your device and is never shared with third parties.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return Column(
                children: [
                  if (locationProvider.hasLocation) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppColors.success),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Location: ${locationProvider.locationString}',
                              style: const TextStyle(color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: locationProvider.isLoading 
                            ? null 
                            : () => locationProvider.getCurrentLocation(),
                        icon: locationProvider.isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.location_on),
                        label: Text(locationProvider.isLoading 
                            ? 'Getting Location...' 
                            : 'Enable Location'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        // Set manual location later option
                      },
                      child: const Text(
                        'Set Location Manually Later',
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 80),
          
          Icon(
            Icons.mosque,
            size: 80,
            color: AppColors.white,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Prayer Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Configure your prayer calculation preferences',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Madhab Selection
                  Text(
                    'Madhab (School of Thought)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_madhabs.map((madhab) {
                    final isSelected = _selectedMadhab == madhab;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text(
                            madhab,
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check, color: AppColors.primaryGreen)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedMadhab = madhab;
                            });
                          },
                        ),
                      ),
                    );
                  })).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Calculation Method
                  Text(
                    'Calculation Method',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...(_calculationMethods.map((method) {
                    final isSelected = _selectedCalculationMethod == method['id'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Card(
                        color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.9),
                        child: ListTile(
                          title: Text(
                            method['name'],
                            style: TextStyle(
                              color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 14,
                            ),
                          ),
                          trailing: isSelected 
                              ? const Icon(Icons.check, color: AppColors.primaryGreen)
                              : null,
                          onTap: () {
                            setState(() {
                              _selectedCalculationMethod = method['id'];
                            });
                          },
                        ),
                      ),
                    );
                  })).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const SizedBox(height: 80),
          
          Icon(
            Icons.notifications,
            size: 80,
            color: AppColors.white,
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Notification Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Customize how you receive prayer reminders',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Prayer Notifications
                  Card(
                    color: AppColors.white.withOpacity(0.9),
                    child: SwitchListTile(
                      title: const Text(
                        'Prayer Notifications',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Get notified for prayer times'),
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                          if (!value) _athanEnabled = false;
                        });
                      },
                      activeColor: AppColors.primaryGreen,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Athan Sound
                  Card(
                    color: AppColors.white.withOpacity(0.9),
                    child: SwitchListTile(
                      title: const Text(
                        'Athan Sound',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Play Athan call for prayers'),
                      value: _athanEnabled && _notificationsEnabled,
                      onChanged: _notificationsEnabled ? (value) {
                        setState(() {
                          _athanEnabled = value;
                        });
                      } : null,
                      activeColor: AppColors.primaryGreen,
                    ),
                  ),
                  
                  if (_athanEnabled && _notificationsEnabled) ...[
                    const SizedBox(height: 24),
                    
                    Text(
                      'Athan Sound Selection',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    ...(_athanSounds.map((sound) {
                      final isSelected = _selectedAthanSound == sound['value'];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          color: isSelected ? AppColors.white : AppColors.white.withOpacity(0.9),
                          child: ListTile(
                            title: Text(
                              sound['name']!,
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryGreen : AppColors.textPrimary,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    // Play preview sound
                                  },
                                  icon: const Icon(Icons.play_arrow),
                                  color: AppColors.primaryGreen,
                                ),
                                if (isSelected) 
                                  const Icon(Icons.check, color: AppColors.primaryGreen),
                              ],
                            ),
                            onTap: () {
                              setState(() {
                                _selectedAthanSound = sound['value']!;
                              });
                            },
                          ),
                        ),
                      );
                    })).toList(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final preferencesProvider = Provider.of<UserPreferencesProvider>(context, listen: false);
    
    // Save all selected preferences
    await preferencesProvider.updateLanguage(_selectedLanguage);
    await preferencesProvider.updateMadhab(_selectedMadhab);
    await preferencesProvider.updateCalculationMethod(_selectedCalculationMethod);
    await preferencesProvider.updateNotificationSettings(
      enabled: _notificationsEnabled,
      athanEnabled: _athanEnabled,
      athanSound: _selectedAthanSound,
    );
    
    // Mark onboarding as completed
    await preferencesProvider.completeOnboarding();
    
    // Navigate to main app
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigation(),
        ),
      );
    }
  }
}