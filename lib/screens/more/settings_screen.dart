import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../providers/user_preferences_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        elevation: 0,
      ),
      body: Consumer<UserPreferencesProvider>(
        builder: (context, preferencesProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prayer Settings
                _buildSectionHeader('Prayer Settings'),
                _buildSettingsCard([
                  _buildListTile(
                    'Calculation Method',
                    'Islamic Society of North America (ISNA)',
                    Icons.calculate,
                    onTap: _showCalculationMethods,
                  ),
                  _buildListTile(
                    'Madhab',
                    'Hanafi',
                    Icons.book,
                    onTap: _showMadhabOptions,
                  ),
                  _buildSwitchTile(
                    'Prayer Notifications',
                    'Get notified for prayer times',
                    Icons.notifications,
                    preferencesProvider.preferences.notificationsEnabled,
                    (value) => preferencesProvider.updateNotificationSettings(enabled: value),
                  ),
                  _buildSwitchTile(
                    'Athan Sound',
                    'Play Athan for prayer calls',
                    Icons.volume_up,
                    preferencesProvider.preferences.athanEnabled,
                    (value) => preferencesProvider.updateNotificationSettings(athanEnabled: value),
                  ),
                ]),

                const SizedBox(height: 24),

                // App Settings
                _buildSectionHeader('App Settings'),
                _buildSettingsCard([
                  _buildListTile(
                    'Language',
                    'English',
                    Icons.language,
                    onTap: _showLanguageOptions,
                  ),
                  _buildListTile(
                    'Theme',
                    _getThemeName(preferencesProvider.preferences.themeMode),
                    Icons.palette,
                    onTap: () => _showThemeOptions(preferencesProvider),
                  ),
                  _buildListTile(
                    'Font Size',
                    '${preferencesProvider.preferences.fontSize.toInt()}pt',
                    Icons.text_fields,
                    onTap: () => _showFontSizeSlider(preferencesProvider),
                  ),
                ]),

                const SizedBox(height: 24),

                // Data & Privacy
                _buildSectionHeader('Data & Privacy'),
                _buildSettingsCard([
                  _buildListTile(
                    'Backup & Restore',
                    'Sync your data',
                    Icons.backup,
                    onTap: _showBackupOptions,
                  ),
                  _buildListTile(
                    'Clear Data',
                    'Reset app to defaults',
                    Icons.delete_sweep,
                    onTap: _showClearDataDialog,
                  ),
                  _buildListTile(
                    'Privacy Policy',
                    'How we protect your data',
                    Icons.privacy_tip,
                    onTap: _showPrivacyPolicy,
                  ),
                ]),

                const SizedBox(height: 24),

                // About
                _buildSectionHeader('About'),
                _buildSettingsCard([
                  _buildListTile(
                    'App Version',
                    '1.0.0',
                    Icons.info,
                    onTap: _showAboutDialog,
                  ),
                  _buildListTile(
                    'Rate App',
                    'Share your feedback',
                    Icons.star,
                    onTap: _rateApp,
                  ),
                  _buildListTile(
                    'Contact Support',
                    'Get help',
                    Icons.help,
                    onTap: _contactSupport,
                  ),
                ]),

                const SizedBox(height: 100), // Bottom spacing
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGreen,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primaryGreen),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primaryGreen,
    );
  }

  String _getThemeName(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showCalculationMethods() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calculation Method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMethodOption('ISNA', 'Islamic Society of North America'),
            _buildMethodOption('MWL', 'Muslim World League'),
            _buildMethodOption('Makkah', 'Umm Al-Qura University, Makkah'),
            _buildMethodOption('Karachi', 'University of Islamic Sciences, Karachi'),
          ],
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

  Widget _buildMethodOption(String code, String name) {
    return ListTile(
      title: Text(name),
      subtitle: Text(code),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $name')),
        );
      },
    );
  }

  void _showMadhabOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Madhab'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMadhabOption('Hanafi'),
            _buildMadhabOption('Shafi\'i'),
            _buildMadhabOption('Maliki'),
            _buildMadhabOption('Hanbali'),
          ],
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

  Widget _buildMadhabOption(String madhab) {
    return ListTile(
      title: Text(madhab),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $madhab')),
        );
      },
    );
  }

  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en'),
            _buildLanguageOption('العربية', 'ar'),
            _buildLanguageOption('Urdu', 'ur'),
            _buildLanguageOption('Türkçe', 'tr'),
          ],
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

  Widget _buildLanguageOption(String language, String code) {
    return ListTile(
      title: Text(language),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $language')),
        );
      },
    );
  }

  void _showThemeOptions(UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: provider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: provider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System Default'),
              value: ThemeMode.system,
              groupValue: provider.preferences.themeMode,
              onChanged: (value) {
                if (value != null) {
                  provider.updateThemeMode(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showFontSizeSlider(UserPreferencesProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sample Text',
                  style: TextStyle(fontSize: provider.preferences.fontSize),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: provider.preferences.fontSize,
                  min: 12.0,
                  max: 24.0,
                  divisions: 12,
                  label: '${provider.preferences.fontSize.toInt()}pt',
                  onChanged: (value) {
                    provider.updateFontSize(value);
                    setState(() {});
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showBackupOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Backup and restore functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Data'),
        content: const Text('This will reset all app data to defaults. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data cleared')),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Your privacy is important to us. This app does not collect any personal data without your consent. All your prayer data and preferences are stored locally on your device.',
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

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Meezan: Prayer & Quran',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.mosque,
          color: AppColors.white,
          size: 32,
        ),
      ),
      children: [
        const Text(
          'A comprehensive Islamic lifestyle app offering accurate prayer times, Quran recitation, and spiritual guidance.',
        ),
      ],
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you for your feedback!'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact support feature will be implemented'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}