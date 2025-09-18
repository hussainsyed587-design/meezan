import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../constants/app_colors.dart';

class AudioPlayerControls extends StatefulWidget {
  final AudioPlayer audioPlayer;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const AudioPlayerControls({
    super.key,
    required this.audioPlayer,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  @override
  State<AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<AudioPlayerControls> {
  double _playbackSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          
          const SizedBox(height: 24),
          
          // Main controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Previous button
              IconButton(
                onPressed: () {
                  debugPrint('Previous button pressed in audio controls');
                  widget.onPrevious();
                },
                icon: const Icon(Icons.skip_previous),
                iconSize: 36,
                color: AppColors.primaryGreen,
              ),
              
              // Play/Pause button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withAlpha(76),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: () {
                    debugPrint('Audio player controls play/pause pressed');
                    widget.onPlayPause();
                  },
                  icon: Icon(
                    widget.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: AppColors.white,
                  ),
                  iconSize: 40,
                ),
              ),
              
              // Next button
              IconButton(
                onPressed: () {
                  debugPrint('Next button pressed in audio controls');
                  widget.onNext();
                },
                icon: const Icon(Icons.skip_next),
                iconSize: 36,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Playback speed control
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.speed, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              DropdownButton<double>(
                value: _playbackSpeed,
                onChanged: (speed) {
                  if (speed != null) {
                    setState(() {
                      _playbackSpeed = speed;
                    });
                    widget.audioPlayer.setPlaybackRate(speed);
                  }
                },
                items: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0]
                    .map((speed) => DropdownMenuItem(
                          value: speed,
                          child: Text('${speed}x'),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            activeTrackColor: AppColors.primaryGreen,
            inactiveTrackColor: AppColors.lightGrey,
            thumbColor: AppColors.primaryGreen,
            overlayColor: AppColors.primaryGreen.withAlpha(51),
          ),
          child: Slider(
            value: widget.currentPosition.inSeconds.toDouble(),
            max: widget.totalDuration.inSeconds.toDouble(),
            onChanged: (value) {
              widget.audioPlayer.seek(Duration(seconds: value.toInt()));
            },
          ),
        ),
        
        // Time labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(widget.currentPosition),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(widget.totalDuration),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return '$hours:$minutes:$seconds';
    } else {
      return '$minutes:$seconds';
    }
  }
}