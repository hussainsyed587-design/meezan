
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../models/quran.dart';
import '../../providers/quran_provider.dart';
import '../../widgets/audio_player_controls.dart';

class QuranReaderScreen extends StatelessWidget {
  final QuranSurah surah;

  const QuranReaderScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context) {
    final quranProvider = Provider.of<QuranProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(surah.englishName),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah heading
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  Text(
                    surah.name,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    surah.englishName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    '${surah.revelationType} - ${surah.ayahs.length} verses',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  // Audio player controls
                  AudioPlayerControls(),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            // Ayahs
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: surah.ayahs.length,
              itemBuilder: (context, index) {
                final ayah = surah.ayahs[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '${ayah.numberInSurah}. ${ayah.text}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: quranProvider.fontSize,
                        ),
                      ),
                      if (quranProvider.showTransliteration) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          ayah.enTransliteration,
                          style: TextStyle(
                            fontSize: quranProvider.fontSize - 4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (quranProvider.showTranslation) ...[
                        const SizedBox(height: 8.0),
                        Text(
                          ayah.enTranslation,
                          style: TextStyle(
                            fontSize: quranProvider.fontSize - 4,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
