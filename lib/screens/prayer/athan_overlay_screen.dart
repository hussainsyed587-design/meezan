import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../constants/app_colors.dart';

class AthanOverlayScreen extends StatefulWidget {
  final String prayerName;
  final DateTime prayerTime;
  final String? location;

  const AthanOverlayScreen({
    super.key,
    required this.prayerName,
    required this.prayerTime,
    this.location,
  });

  @override
  State<AthanOverlayScreen> createState() => _AthanOverlayScreenState();
}

class _AthanOverlayScreenState extends State<AthanOverlayScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  bool _isAthanPlaying = true;
  int _prayingCount = 847; // Mock number of people praying

  @override
  void initState() {
    super.initState();
    
    // Keep screen on during Athan
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    // Initialize animations
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    _pulseController.repeat(reverse: true);
    
    // Auto-dismiss after 30 seconds
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _dismissOverlay();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _dismissOverlay();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1B4332),
                Color(0xFF2D5A3D),
                Color(0xFF40916C),
              ],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  // Header
                  _buildHeader(),
                  
                  // Main content
                  Expanded(
                    child: _buildMainContent(),
                  ),
                  
                  // Bottom actions
                  _buildBottomActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Time and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat('HH:mm').format(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('EEEE, MMM d').format(DateTime.now()),
                style: TextStyle(
                  color: AppColors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          
          // Location
          if (widget.location != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.white,
                  size: 16,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.location!,
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Prayer name in Arabic
          Text(
            _getArabicPrayerName(widget.prayerName),
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'Arabic',
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Prayer name in English
          Text(
            '${widget.prayerName} Prayer',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Prayer time
          Text(
            DateFormat('h:mm a').format(widget.prayerTime),
            style: TextStyle(
              color: AppColors.white.withOpacity(0.9),
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Pulsing prayer icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: AppColors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Praying count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppColors.white.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.people,
                  color: AppColors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_prayingCount Muslims are praying now',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Athan status
          if (_isAthanPlaying)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Athan is playing...',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Quick actions
          Row(
            children: [
              // Quran button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.book,
                  label: 'Quran',
                  onTap: () {
                    // Navigate to Quran
                    _dismissOverlay();
                  },
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Qibla button
              Expanded(
                child: _buildActionButton(
                  icon: Icons.explore,
                  label: 'Qibla',
                  onTap: () {
                    // Navigate to Qibla
                    _dismissOverlay();
                  },
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Record prayer button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _recordPrayer,
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark Prayer as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white.withOpacity(0.2),
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: AppColors.white.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Dismiss button
          TextButton(
            onPressed: _dismissOverlay,
            child: Text(
              'Dismiss',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppColors.white,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _recordPrayer() {
    // Record the prayer as completed
    // In a real app, you would save this to your prayer tracking system
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.prayerName} prayer recorded'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    // Dismiss overlay after recording
    Future.delayed(const Duration(seconds: 1), () {
      _dismissOverlay();
    });
  }

  void _dismissOverlay() {
    // Stop Athan audio if playing
    setState(() {
      _isAthanPlaying = false;
    });
    
    // Navigate back
    Navigator.of(context).pop();
  }

  String _getArabicPrayerName(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return 'الصلاة';
    }
  }
}