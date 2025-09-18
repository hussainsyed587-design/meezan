import 'package:flutter/material.dart';
import '../../models/quran.dart';

class QuranSurahCard extends StatelessWidget {
  final QuranSurah surah;
  final VoidCallback onTap;

  const QuranSurahCard({super.key, required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(surah.number.toString()),
        ),
        title: Text(surah.englishName),
        subtitle: Text(surah.name),
        onTap: onTap,
      ),
    );
  }
}
