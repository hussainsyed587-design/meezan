import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../providers/audio_player_provider.dart';
import '../../models/audio_recitation.dart';
import '../../widgets/audio_player_controls.dart';
import '../../widgets/recitation_selector.dart';

class AudioPlayerScreen extends StatefulWidget {
  const AudioPlayerScreen({super.key});

  @override
  State<AudioPlayerScreen> createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Quran Audio'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search Recitations',
          ),
          IconButton(
            icon: const Icon(Icons.library_music),
            onPressed: () => _tabController.animateTo(2),
            tooltip: 'Playlists',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.white,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Player'),
            Tab(text: 'Reciters'),
            Tab(text: 'Playlists'),
            Tab(text: 'Downloads'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mini Player (always visible)
          Consumer<AudioPlayerProvider>(
            builder: (context, audioProvider, child) {
              if (audioProvider.currentTrack == null) {
                return const SizedBox.shrink();
              }
              
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cardShadow,
                      blurRadius: 4,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Album Art
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.music_note,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Track Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            audioProvider.currentTrack!.title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            audioProvider.currentTrack!.recitation.reciterName,
                            style: TextStyle(
                              color: AppColors.white.withOpacity(0.8),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    
                    // Play/Pause Button
                    IconButton(
                      onPressed: () {
                        debugPrint('Mini player play/pause pressed');
                        audioProvider.playPause();
                      },
                      icon: Icon(
                        audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          
          // Main Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayerView(),
                _buildRecitersView(),
                _buildPlaylistsView(),
                _buildDownloadsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerView() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.currentTrack == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.music_note,
                  size: 80,
                  color: AppColors.mediumGrey.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No track selected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a recitation to start listening',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Browse Reciters'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Album Art
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.greenGradient,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_stories,
                  size: 120,
                  color: AppColors.white,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Track Title
              Text(
                audioProvider.currentTrack!.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Reciter Name
              Text(
                audioProvider.currentTrack!.recitation.reciterName,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (audioProvider.currentTrack!.recitation.reciterArabicName != null) ...[
                const SizedBox(height: 4),
                Text(
                  audioProvider.currentTrack!.recitation.reciterArabicName!,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Progress Bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primaryGreen,
                      inactiveTrackColor: AppColors.lightGrey,
                      thumbColor: AppColors.primaryGreen,
                      overlayColor: AppColors.primaryGreen.withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: audioProvider.progress,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (value * audioProvider.totalDuration.inMilliseconds).round(),
                        );
                        audioProvider.seek(position);
                      },
                    ),
                  ),
                  
                  // Time Labels
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(audioProvider.currentPosition),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(audioProvider.totalDuration),
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              // Player Controls Placeholder
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Progress bar placeholder
                    Slider(
                      value: audioProvider.progress,
                      onChanged: (value) {
                        final position = Duration(
                          milliseconds: (value * audioProvider.totalDuration.inMilliseconds).round(),
                        );
                        audioProvider.seek(position);
                      },
                      activeColor: AppColors.primaryGreen,
                    ),
                    const SizedBox(height: 16),
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: audioProvider.hasPreviousTrack ? () {
                            debugPrint('Previous track button pressed');
                            audioProvider.previousTrack();
                          } : null,
                          icon: const Icon(Icons.skip_previous),
                          iconSize: 36,
                          color: AppColors.primaryGreen,
                        ),
                        Container(
                          decoration: const BoxDecoration(
                            color: AppColors.primaryGreen,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () {
                              debugPrint('Main play/pause button pressed');
                              audioProvider.playPause();
                            },
                            icon: Icon(
                              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow, 
                              color: AppColors.white
                            ),
                            iconSize: 40,
                          ),
                        ),
                        IconButton(
                          onPressed: audioProvider.hasNextTrack ? () {
                            debugPrint('Next track button pressed');
                            audioProvider.nextTrack();
                          } : null,
                          icon: const Icon(Icons.skip_next),
                          iconSize: 36,
                          color: AppColors.primaryGreen,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Additional Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Volume Control
                  IconButton(
                    onPressed: _showVolumeDialog,
                    icon: Icon(
                      audioProvider.volume > 0.5
                          ? Icons.volume_up
                          : audioProvider.volume > 0
                              ? Icons.volume_down
                              : Icons.volume_off,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Speed Control
                  TextButton(
                    onPressed: _showSpeedDialog,
                    child: Text(
                      audioProvider.playbackSpeed.label,
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  // Download
                  IconButton(
                    onPressed: () => _downloadTrack(audioProvider.currentTrack!),
                    icon: Icon(
                      audioProvider.isTrackDownloaded(audioProvider.currentTrack!)
                          ? Icons.download_done
                          : Icons.download,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Share
                  IconButton(
                    onPressed: () => _shareTrack(audioProvider.currentTrack!),
                    icon: const Icon(
                      Icons.share,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecitersView() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioProvider.availableRecitations.length,
          itemBuilder: (context, index) {
            final recitation = audioProvider.availableRecitations[index];
            final isSelected = audioProvider.selectedRecitation?.id == recitation.id;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected ? AppColors.primaryGreen : AppColors.mediumGrey,
                  child: Icon(
                    isSelected ? Icons.check : Icons.person,
                    color: AppColors.white,
                  ),
                ),
                title: Text(recitation.reciterName),
                subtitle: Text(recitation.description),
                trailing: isSelected 
                    ? const Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                selected: isSelected,
                selectedTileColor: AppColors.primaryGreen.withOpacity(0.1),
                onTap: () async {
                  audioProvider.selectRecitation(recitation);
                  
                  // If there's no current track, set a default one (first surah)
                  if (audioProvider.currentTrack == null) {
                    final tracks = audioProvider.getTracksForSurah(1, 'Al-Fatihah');
                    if (tracks.isNotEmpty) {
                      try {
                        audioProvider.setPlaylist(tracks);
                        await audioProvider.playTrack(tracks.first);
                      } catch (e) {
                        String errorMessage = 'Error playing Al-Fatihah';
                        if (e.toString().contains('not valid')) {
                          errorMessage += '. The selected reciter may not be available.';
                        } else {
                          errorMessage += ': $e';
                        }
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              duration: const Duration(seconds: 5),
                            ),
                          );
                        }
                      }
                    }
                  }
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlaylistsView() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.playlist_play,
                size: 64,
                color: AppColors.mediumGrey,
              ),
              SizedBox(height: 16),
              Text(
                'Playlists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Coming soon!',
                style: TextStyle(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDownloadsView() {
    return Consumer<AudioPlayerProvider>(
      builder: (context, audioProvider, child) {
        if (audioProvider.downloadedTracks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.download,
                  size: 64,
                  color: AppColors.mediumGrey,
                ),
                SizedBox(height: 16),
                Text(
                  'No Downloads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Download tracks for offline listening',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: audioProvider.downloadedTracks.length,
          itemBuilder: (context, index) {
            final track = audioProvider.downloadedTracks[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryGreen,
                  child: Icon(
                    Icons.download_done,
                    color: AppColors.white,
                  ),
                ),
                title: Text(track.title),
                subtitle: Text(track.recitation.reciterName),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _confirmDeleteDownload(track),
                ),
                onTap: () => audioProvider.playTrack(track),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Recitations'),
        content: const Text('Search functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: Consumer<AudioPlayerProvider>(
          builder: (context, audioProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: audioProvider.volume,
                        onChanged: audioProvider.setVolume,
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                Text('${(audioProvider.volume * 100).round()}%'),
              ],
            );
          },
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

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Consumer<AudioPlayerProvider>(
          builder: (context, audioProvider, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: PlaybackSpeed.speeds.map((speed) {
                return RadioListTile<PlaybackSpeed>(
                  title: Text(speed.label),
                  value: speed,
                  groupValue: audioProvider.playbackSpeed,
                  onChanged: (value) {
                    if (value != null) {
                      audioProvider.setPlaybackSpeed(value);
                      Navigator.pop(context);
                    }
                  },
                );
              }).toList(),
            );
          },
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

  void _downloadTrack(AudioTrack track) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Download functionality coming soon!'),
      ),
    );
  }

  void _shareTrack(AudioTrack track) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${track.title}'),
      ),
    );
  }

  void _confirmDeleteDownload(AudioTrack track) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Download'),
        content: Text('Are you sure you want to delete ${track.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<AudioPlayerProvider>(context, listen: false)
                  .removeDownload(track);
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}