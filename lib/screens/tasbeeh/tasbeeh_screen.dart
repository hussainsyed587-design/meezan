import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/tasbeeh_provider.dart';

class TasbeehScreen extends StatelessWidget {
  const TasbeehScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasbeehProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tasbeeh Counter'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          actions: [
            Consumer<TasbeehProvider>(
              builder: (context, tasbeehProvider, child) {
                return IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => _showSettings(context, tasbeehProvider),
                );
              },
            ),
          ],
        ),
        body: Consumer<TasbeehProvider>(
          builder: (context, tasbeehProvider, child) {
            return Column(
              children: [
                // Current Dhikr Display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: AppColors.greenGradient,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        tasbeehProvider.currentDhikr,
                        style: AppTheme.arabicTextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getDhikrTranslation(tasbeehProvider.currentDhikr),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Progress Indicator
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progress',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            '${tasbeehProvider.count}/${tasbeehProvider.targetCount}',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: tasbeehProvider.progress,
                        backgroundColor: AppColors.lightGrey,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          tasbeehProvider.isComplete 
                              ? AppColors.success 
                              : AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Counter Display
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Count Display
                        Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.primaryGreen.withOpacity(0.1),
                                AppColors.primaryGreen.withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(
                              color: AppColors.primaryGreen,
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              tasbeehProvider.count.toString(),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Tap to Count Button
                        GestureDetector(
                          onTap: tasbeehProvider.increment,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGreen,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGreen.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.touch_app,
                              size: 48,
                              color: AppColors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        Text(
                          'Tap to Count',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),

                        if (tasbeehProvider.isComplete) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Target Reached! 🎉',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Bottom Controls
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: tasbeehProvider.reset,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reset'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showDhikrSelection(context, tasbeehProvider),
                          icon: const Icon(Icons.swap_horiz),
                          label: const Text('Change Dhikr'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, TasbeehProvider tasbeehProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tasbeeh Settings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            
            // Target Count
            Row(
              children: [
                const Icon(Icons.flag),
                const SizedBox(width: 16),
                const Text('Target Count'),
                const Spacer(),
                DropdownButton<int>(
                  value: tasbeehProvider.targetCount,
                  items: [33, 99, 100, 1000].map((count) {
                    return DropdownMenuItem(
                      value: count,
                      child: Text(count.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      tasbeehProvider.setTarget(value);
                    }
                  },
                ),
              ],
            ),
            
            // Vibration Toggle
            SwitchListTile(
              title: const Text('Vibrate on Count'),
              subtitle: const Text('Haptic feedback when counting'),
              value: tasbeehProvider.vibrateOnCount,
              onChanged: (_) => tasbeehProvider.toggleVibration(),
            ),
            
            // History
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('View History'),
              onTap: () {
                Navigator.pop(context);
                _showHistory(context, tasbeehProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDhikrSelection(BuildContext context, TasbeehProvider tasbeehProvider) {
    final dhikrList = [
      'سبحان الله',
      'الحمد لله',
      'الله أكبر',
      'لا إله إلا الله',
      'سبحان الله وبحمده',
      'سبحان الله العظيم',
      'استغفر الله',
      'لا حول ولا قوة إلا بالله',
      'اللهم صل على محمد',
      'رب اغفر لي',
    ];

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Dhikr',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: dhikrList.length,
                itemBuilder: (context, index) {
                  final dhikr = dhikrList[index];
                  final isSelected = dhikr == tasbeehProvider.currentDhikr;
                  
                  return ListTile(
                    title: Text(
                      dhikr,
                      style: AppTheme.arabicTextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(_getDhikrTranslation(dhikr)),
                    leading: isSelected 
                        ? const Icon(Icons.check_circle, color: AppColors.primaryGreen)
                        : null,
                    onTap: () {
                      tasbeehProvider.setDhikr(dhikr);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHistory(BuildContext context, TasbeehProvider tasbeehProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tasbeeh History'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: tasbeehProvider.history.isEmpty
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  itemCount: tasbeehProvider.history.length,
                  itemBuilder: (context, index) {
                    final entry = tasbeehProvider.history[index];
                    return ListTile(
                      title: Text(entry),
                      dense: true,
                    );
                  },
                ),
        ),
        actions: [
          if (tasbeehProvider.history.isNotEmpty)
            TextButton(
              onPressed: () {
                tasbeehProvider.clearHistory();
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getDhikrTranslation(String dhikr) {
    switch (dhikr) {
      case 'سبحان الله':
        return 'Glory be to Allah';
      case 'الحمد لله':
        return 'Praise be to Allah';
      case 'الله أكبر':
        return 'Allah is Greatest';
      case 'لا إله إلا الله':
        return 'There is no god but Allah';
      case 'سبحان الله وبحمده':
        return 'Glory be to Allah and praise be to Him';
      case 'سبحان الله العظيم':
        return 'Glory be to Allah the Great';
      case 'استغفر الله':
        return 'I seek forgiveness from Allah';
      case 'لا حول ولا قوة إلا بالله':
        return 'There is no power except with Allah';
      case 'اللهم صل على محمد':
        return 'O Allah, send blessings upon Muhammad';
      case 'رب اغفر لي':
        return 'My Lord, forgive me';
      default:
        return '';
    }
  }
}