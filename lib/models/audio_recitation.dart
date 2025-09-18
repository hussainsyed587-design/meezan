import 'package:flutter/foundation.dart';

class AudioRecitation {
  final String id;
  final String name;
  final String description;
  final String reciterName;
  final String? reciterArabicName;
  final String baseUrl;
  final int totalSurahs;
  final String language;
  final RecitationStyle style;
  final int? reciterId;
  final String? imageUrl;
  final bool isDownloadable;
  final int? bitrate;

  const AudioRecitation({
    required this.id,
    required this.name,
    required this.description,
    required this.reciterName,
    this.reciterArabicName,
    required this.baseUrl,
    this.totalSurahs = 114,
    this.language = 'Arabic',
    this.style = RecitationStyle.hafs,
    this.reciterId,
    this.imageUrl,
    this.isDownloadable = true,
    this.bitrate,
  });

  factory AudioRecitation.fromJson(Map<String, dynamic> json) {
    return AudioRecitation(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      reciterName: json['reciterName'] ?? '',
      reciterArabicName: json['reciterArabicName'],
      baseUrl: json['baseUrl'] ?? '',
      totalSurahs: json['totalSurahs'] ?? 114,
      language: json['language'] ?? 'Arabic',
      style: RecitationStyle.values.firstWhere(
        (e) => e.name == json['style'],
        orElse: () => RecitationStyle.hafs,
      ),
      reciterId: json['reciterId'],
      imageUrl: json['imageUrl'],
      isDownloadable: json['isDownloadable'] ?? true,
      bitrate: json['bitrate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'reciterName': reciterName,
      'reciterArabicName': reciterArabicName,
      'baseUrl': baseUrl,
      'totalSurahs': totalSurahs,
      'language': language,
      'style': style.name,
      'reciterId': reciterId,
      'imageUrl': imageUrl,
      'isDownloadable': isDownloadable,
      'bitrate': bitrate,
    };
  }

  String getAudioUrl(int surahNumber, {int? ayahNumber}) {
    // Validate surah number
    if (surahNumber < 1 || surahNumber > 114) {
      debugPrint('Invalid surah number: $surahNumber');
      return '';
    }
    
    if (ayahNumber != null) {
      // For verse-by-verse recitation
      // Validate ayah number (approximate check)
      if (ayahNumber < 1 || ayahNumber > 300) {  // Most surahs have less than 300 ayahs
        debugPrint('Invalid ayah number: $ayahNumber');
        return '';
      }
      final url = '$baseUrl/$surahNumber/$ayahNumber.mp3';
      debugPrint('Generated ayah audio URL: $url');
      return url;
    } else {
      // For complete surah recitation
      final paddedSurah = surahNumber.toString().padLeft(3, '0');
      final url = '$baseUrl/$paddedSurah.mp3';
      debugPrint('Generated surah audio URL: $url');
      return url;
    }
  }
}

enum RecitationStyle {
  hafs,
  warsh,
  qaloon,
  douri,
  other,
}

class AudioTrack {
  final String id;
  final int surahNumber;
  final int? ayahNumber;
  final String title;
  final String audioUrl;
  final Duration? duration;
  final AudioRecitation recitation;
  final bool isDownloaded;
  final String? localPath;

  const AudioTrack({
    required this.id,
    required this.surahNumber,
    this.ayahNumber,
    required this.title,
    required this.audioUrl,
    this.duration,
    required this.recitation,
    this.isDownloaded = false,
    this.localPath,
  });

  bool get isFullSurah => ayahNumber == null;
  
  String get displayTitle {
    if (isFullSurah) {
      return 'Surah $title - ${recitation.reciterName}';
    } else {
      return 'Surah $title, Ayah $ayahNumber - ${recitation.reciterName}';
    }
  }

  AudioTrack copyWith({
    String? id,
    int? surahNumber,
    int? ayahNumber,
    String? title,
    String? audioUrl,
    Duration? duration,
    AudioRecitation? recitation,
    bool? isDownloaded,
    String? localPath,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      title: title ?? this.title,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      recitation: recitation ?? this.recitation,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] ?? '',
      surahNumber: json['surahNumber'] ?? 1,
      ayahNumber: json['ayahNumber'],
      title: json['title'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration']) 
          : null,
      recitation: AudioRecitation.fromJson(json['recitation'] ?? {}),
      isDownloaded: json['isDownloaded'] ?? false,
      localPath: json['localPath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'title': title,
      'audioUrl': audioUrl,
      'duration': duration?.inMilliseconds,
      'recitation': recitation.toJson(),
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }
}

enum AudioPlayerState {
  stopped,
  playing,
  paused,
  loading,
  error,
}

enum RepeatMode {
  none,
  one,
  all,
  surah,
}

class PlaybackSpeed {
  final double value;
  final String label;

  const PlaybackSpeed(this.value, this.label);

  static const List<PlaybackSpeed> speeds = [
    PlaybackSpeed(0.5, '0.5x'),
    PlaybackSpeed(0.75, '0.75x'),
    PlaybackSpeed(1.0, '1x'),
    PlaybackSpeed(1.25, '1.25x'),
    PlaybackSpeed(1.5, '1.5x'),
    PlaybackSpeed(2.0, '2x'),
  ];

  static PlaybackSpeed get normal => speeds[2]; // 1.0x
}

class PlaylistItem {
  final String id;
  final String name;
  final String description;
  final List<AudioTrack> tracks;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDefault;

  const PlaylistItem({
    required this.id,
    required this.name,
    required this.description,
    required this.tracks,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isDefault = false,
  });

  Duration get totalDuration {
    return tracks.fold(Duration.zero, (total, track) => 
        total + (track.duration ?? Duration.zero));
  }

  int get trackCount => tracks.length;

  factory PlaylistItem.fromJson(Map<String, dynamic> json) {
    return PlaylistItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      tracks: (json['tracks'] as List<dynamic>?)
          ?.map((t) => AudioTrack.fromJson(t))
          .toList() ?? [],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      isDefault: json['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'tracks': tracks.map((t) => t.toJson()).toList(),
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isDefault': isDefault,
    };
  }
}