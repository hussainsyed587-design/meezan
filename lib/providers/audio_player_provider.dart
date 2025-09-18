import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart' as audioplayers;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/audio_recitation.dart';
import '../data/audio_recitations_data.dart';

class AudioPlayerProvider extends ChangeNotifier {
  late audioplayers.AudioPlayer _audioPlayer;
  
  // Player State
  AudioPlayerState _playerState = AudioPlayerState.stopped;
  AudioTrack? _currentTrack;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  PlaybackSpeed _playbackSpeed = PlaybackSpeed.normal;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _isShuffleEnabled = false;
  
  // Playlist
  List<AudioTrack> _playlist = [];
  int _currentTrackIndex = 0;
  
  // Recitations
  List<AudioRecitation> _availableRecitations = [];
  AudioRecitation? _selectedRecitation;
  
  // Downloads
  List<AudioTrack> _downloadedTracks = [];
  
  // Getters
  AudioPlayerState get playerState => _playerState;
  AudioTrack? get currentTrack => _currentTrack;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  PlaybackSpeed get playbackSpeed => _playbackSpeed;
  RepeatMode get repeatMode => _repeatMode;
  bool get isShuffleEnabled => _isShuffleEnabled;
  List<AudioTrack> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;
  List<AudioRecitation> get availableRecitations => _availableRecitations;
  AudioRecitation? get selectedRecitation => _selectedRecitation;
  List<AudioTrack> get downloadedTracks => _downloadedTracks;
  
  // Computed getters
  bool get isPlaying => _playerState == AudioPlayerState.playing;
  bool get isPaused => _playerState == AudioPlayerState.paused;
  bool get isLoading => _playerState == AudioPlayerState.loading;
  bool get isError => _playerState == AudioPlayerState.error;
  bool get hasNextTrack => _currentTrackIndex < _playlist.length - 1;
  bool get hasPreviousTrack => _currentTrackIndex > 0;
  double get progress => _totalDuration.inMilliseconds > 0 
      ? _currentPosition.inMilliseconds / _totalDuration.inMilliseconds 
      : 0.0;

  AudioPlayerProvider() {
    _initializePlayer();
    _loadRecitations();
    _loadSettings();
    _loadDownloadedTracks();
  }

  void _initializePlayer() {
    _audioPlayer = audioplayers.AudioPlayer();
    debugPrint('Audio player initialized');
    
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('Audio player state changed: $state');
      switch (state) {
        case audioplayers.PlayerState.playing:
          _playerState = AudioPlayerState.playing;
          break;
        case audioplayers.PlayerState.paused:
          _playerState = AudioPlayerState.paused;
          break;
        case audioplayers.PlayerState.stopped:
          _playerState = AudioPlayerState.stopped;
          break;
        case audioplayers.PlayerState.completed:
          _handleTrackCompleted();
          break;
        case audioplayers.PlayerState.disposed:
          _playerState = AudioPlayerState.stopped;
          break;
        default:
          debugPrint('Unknown player state: $state');
          break;
      }
      notifyListeners();
    }).onError((error) {
      debugPrint('Audio player state listener error: $error');
    });
    
    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    }).onError((error) {
      debugPrint('Audio player position listener error: $error');
    });
    
    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    }).onError((error) {
      debugPrint('Audio player duration listener error: $error');
    });
    
    // Set initial volume and playback rate
    _audioPlayer.setVolume(_volume);
    _audioPlayer.setPlaybackRate(_playbackSpeed.value);
  }

  void refreshRecitations() {
    _loadRecitations();
  }

  void _loadRecitations() {
    _availableRecitations = AudioRecitationsData.getAvailableRecitations();
    if (_availableRecitations.isNotEmpty) {
      // Try to select Yasser first as it's known to work
      _selectedRecitation = _availableRecitations.firstWhere(
        (recitation) => recitation.id == 'dosari',
        orElse: () => _availableRecitations.first,
      );
    }
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _volume = prefs.getDouble('audio_volume') ?? 1.0;
      final speedValue = prefs.getDouble('playback_speed') ?? 1.0;
      _playbackSpeed = PlaybackSpeed.speeds.firstWhere(
        (speed) => speed.value == speedValue,
        orElse: () => PlaybackSpeed.normal,
      );
      
      final repeatModeIndex = prefs.getInt('repeat_mode') ?? 0;
      _repeatMode = RepeatMode.values[repeatModeIndex];
      
      _isShuffleEnabled = prefs.getBool('shuffle_enabled') ?? false;
      
      final selectedRecitationId = prefs.getString('selected_recitation');
      if (selectedRecitationId != null) {
        _selectedRecitation = _availableRecitations.firstWhere(
          (recitation) => recitation.id == selectedRecitationId,
          orElse: () => _availableRecitations.first,
        );
        
        // Validate the selected recitation
        if (_selectedRecitation != null) {
          final testUrl = _selectedRecitation!.getAudioUrl(1);
          if (testUrl.isNotEmpty) {
            final isValid = await _isUrlValid(testUrl);
            if (!isValid) {
              debugPrint('Previously selected recitation is not valid, falling back to default');
              // Fall back to a known working recitation
              _selectedRecitation = _availableRecitations.firstWhere(
                (recitation) => recitation.id == 'dosari',
                orElse: () => _availableRecitations.first,
              );
            }
          }
        }
      }
      
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setPlaybackRate(_playbackSpeed.value);
      
    } catch (e) {
      debugPrint('Error loading audio settings: $e');
    }
  }

  Future<void> _loadDownloadedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = prefs.getStringList('downloaded_tracks');
      if (downloadsJson != null) {
        _downloadedTracks = downloadsJson
            .map((json) => AudioTrack.fromJson(jsonDecode(json)))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading downloaded tracks: $e');
    }
  }

  Future<bool> _isUrlValid(String url) async {
    try {
      final uri = Uri.parse(url);
      final response = await http.head(uri).timeout(const Duration(seconds: 10));
      final isValid = response.statusCode == 200;
      debugPrint('URL validation result for $url: ${response.statusCode} - isValid: $isValid');
      return isValid;
    } catch (e) {
      debugPrint('Error validating URL $url: $e');
      return false;
    }
  }

  Future<void> playTrack(AudioTrack track) async {
    try {
      _playerState = AudioPlayerState.loading;
      _currentTrack = track;
      notifyListeners();

      final audioUrl = track.isDownloaded && track.localPath != null
          ? track.localPath!
          : track.audioUrl;

      debugPrint('Playing audio from URL: $audioUrl');
      
      // Validate the URL
      if (audioUrl.isEmpty) {
        throw 'Audio URL is empty';
      }
      
      // Check if URL is valid
      final isValid = await _isUrlValid(audioUrl);
      if (!isValid) {
        debugPrint('Audio URL is not valid: $audioUrl');
        throw 'Audio URL is not valid or accessible';
      }
      
      // Try to play the audio
      await _audioPlayer.play(audioplayers.UrlSource(audioUrl));
      
    } catch (e) {
      _playerState = AudioPlayerState.error;
      debugPrint('Error playing track: $e');
      notifyListeners();
      
      // Re-throw the error so callers can handle it
      rethrow;
    }
  }

  Future<void> playPause() async {
    try {
      debugPrint('Play/Pause called. Current state: $_playerState');
      if (_playerState == AudioPlayerState.playing) {
        debugPrint('Pausing audio');
        await _audioPlayer.pause();
      } else if (_playerState == AudioPlayerState.paused) {
        debugPrint('Resuming audio');
        await _audioPlayer.resume();
      } else if (_currentTrack != null) {
        debugPrint('Playing track');
        await playTrack(_currentTrack!);
      } else {
        debugPrint('No track to play');
      }
    } catch (e) {
      debugPrint('Error in play/pause: $e');
    }
  }

  Future<void> stop() async {
    try {
      debugPrint('Stopping audio player');
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _playerState = AudioPlayerState.stopped;
      notifyListeners();
    } catch (e) {
      debugPrint('Error stopping playback: $e');
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('audio_volume', _volume);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  Future<void> setPlaybackSpeed(PlaybackSpeed speed) async {
    try {
      _playbackSpeed = speed;
      await _audioPlayer.setPlaybackRate(speed.value);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('playback_speed', speed.value);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting playback speed: $e');
    }
  }

  Future<void> setRepeatMode(RepeatMode mode) async {
    try {
      _repeatMode = mode;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('repeat_mode', mode.index);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting repeat mode: $e');
    }
  }

  Future<void> toggleShuffle() async {
    try {
      _isShuffleEnabled = !_isShuffleEnabled;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('shuffle_enabled', _isShuffleEnabled);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling shuffle: $e');
    }
  }

  Future<void> nextTrack() async {
    debugPrint('Next track called. Current index: $_currentTrackIndex, Playlist length: ${_playlist.length}');
    if (!hasNextTrack) {
      if (_repeatMode == RepeatMode.all) {
        _currentTrackIndex = 0;
      } else {
        debugPrint('No next track available');
        return;
      }
    } else {
      _currentTrackIndex++;
    }

    if (_currentTrackIndex < _playlist.length) {
      debugPrint('Playing track at index $_currentTrackIndex');
      await playTrack(_playlist[_currentTrackIndex]);
    }
  }

  Future<void> previousTrack() async {
    debugPrint('Previous track called. Current index: $_currentTrackIndex');
    if (!hasPreviousTrack) {
      if (_repeatMode == RepeatMode.all) {
        _currentTrackIndex = _playlist.length - 1;
      } else {
        debugPrint('No previous track available');
        return;
      }
    } else {
      _currentTrackIndex--;
    }

    if (_currentTrackIndex >= 0 && _currentTrackIndex < _playlist.length) {
      debugPrint('Playing track at index $_currentTrackIndex');
      await playTrack(_playlist[_currentTrackIndex]);
    }
  }

  void _handleTrackCompleted() {
    debugPrint('Track completed. Repeat mode: $_repeatMode');
    switch (_repeatMode) {
      case RepeatMode.one:
        if (_currentTrack != null) {
          debugPrint('Repeating current track');
          playTrack(_currentTrack!);
        }
        break;
      case RepeatMode.all:
        debugPrint('Playing next track in playlist');
        nextTrack();
        break;
      case RepeatMode.surah:
        // Implement surah repeat logic if needed
        debugPrint('Playing next track (surah repeat)');
        nextTrack();
        break;
      case RepeatMode.none:
        if (hasNextTrack) {
          debugPrint('Playing next track');
          nextTrack();
        } else {
          debugPrint('No more tracks, stopping');
          _playerState = AudioPlayerState.stopped;
          notifyListeners();
        }
        break;
    }
  }

  void setPlaylist(List<AudioTrack> tracks, {int startIndex = 0}) {
    _playlist = tracks;
    _currentTrackIndex = startIndex.clamp(0, tracks.length - 1);
    
    if (_isShuffleEnabled) {
      _shufflePlaylist();
    }
    
    notifyListeners();
  }

  void _shufflePlaylist() {
    if (_playlist.length <= 1) return;
    
    final currentTrack = _playlist[_currentTrackIndex];
    _playlist.shuffle();
    
    // Ensure current track stays at current index
    final newIndex = _playlist.indexOf(currentTrack);
    if (newIndex != _currentTrackIndex) {
      _playlist.removeAt(newIndex);
      _playlist.insert(_currentTrackIndex, currentTrack);
    }
  }

  Future<void> selectRecitation(AudioRecitation recitation) async {
    try {
      // Test if the recitation URL works with a sample surah (Al-Fatihah)
      final testUrl = recitation.getAudioUrl(1);  // Surah 1 = Al-Fatihah
      if (testUrl.isNotEmpty) {
        final isValid = await _isUrlValid(testUrl);
        if (!isValid) {
          debugPrint('Recitation URL is not valid: $testUrl');
          // Don't select this recitation, show an error
          return;
        }
      }
      
      _selectedRecitation = recitation;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_recitation', recitation.id);
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error selecting recitation: $e');
    }
  }

  List<AudioTrack> getTracksForSurah(int surahNumber, String surahName) {
    if (_selectedRecitation == null) {
      debugPrint('No selected recitation');
      return [];
    }
    
    final audioUrl = _selectedRecitation!.getAudioUrl(surahNumber);
    debugPrint('Generated audio URL for surah $surahNumber: $audioUrl');

    // Validate URL format
    if (audioUrl.isEmpty) {
      debugPrint('Generated empty audio URL');
      return [];
    }

    final track = AudioTrack(
      id: '${_selectedRecitation!.id}_$surahNumber',
      surahNumber: surahNumber,
      title: surahName,
      audioUrl: audioUrl,
      recitation: _selectedRecitation!,
    );
    
    debugPrint('Created audio track: ${track.toJson()}');
    
    return [track];
  }

  Future<void> downloadTrack(AudioTrack track) async {
    // TODO: Implement download functionality
    // This would involve downloading the audio file and storing it locally
    debugPrint('Download functionality to be implemented for: ${track.title}');
  }

  Future<void> removeDownload(AudioTrack track) async {
    try {
      _downloadedTracks.removeWhere((t) => t.id == track.id);
      await _saveDownloadedTracks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error removing download: $e');
    }
  }

  Future<void> _saveDownloadedTracks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final downloadsJson = _downloadedTracks
          .map((track) => jsonEncode(track.toJson()))
          .toList();
      await prefs.setStringList('downloaded_tracks', downloadsJson);
    } catch (e) {
      debugPrint('Error saving downloaded tracks: $e');
    }
  }

  bool isTrackDownloaded(AudioTrack track) {
    return _downloadedTracks.any((t) => t.id == track.id);
  }

  @override
  void dispose() {
    debugPrint('Disposing audio player provider');
    _audioPlayer.dispose();
    super.dispose();
  }
}