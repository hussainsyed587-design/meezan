import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import '../../constants/app_colors.dart';
import '../../providers/location_provider.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double? _deviceHeading;
  
  @override
  void initState() {
    super.initState();
    _initializeCompass();
    
    // Initialize location when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  void _initializeLocation() async {
    final locationProvider = Provider.of<LocationProvider>(context, listen: false);
    
    // Ensure location is available
    if (!locationProvider.hasLocation) {
      await locationProvider.getCurrentLocation();
    }
  }

  void _initializeCompass() {
    try {
      FlutterCompass.events?.listen((CompassEvent event) {
        if (mounted) {
          setState(() {
            _deviceHeading = event.heading;
          });
        }
      }, onError: (error) {
        debugPrint('Compass error: $error');
        // Set a default heading if compass fails
        if (mounted) {
          setState(() {
            _deviceHeading = 0.0; // Default to North
          });
        }
      });
      
      // Set timeout for compass initialization
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _deviceHeading == null) {
          setState(() {
            _deviceHeading = 0.0; // Default to North if no compass data after 3 seconds
          });
          debugPrint('Compass timeout - using default heading');
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize compass: $e');
      // Fallback to default heading
      _deviceHeading = 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Finder'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showInstructions,
            tooltip: 'Instructions',
          ),
        ],
      ),
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryGreen),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            );
          }

          if (locationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    locationProvider.error!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      locationProvider.clearError();
                      locationProvider.getCurrentLocation();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (locationProvider.currentLocation == null || !locationProvider.hasLocation) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 64, color: AppColors.mediumGrey),
                  const SizedBox(height: 16),
                  Text(
                    'Location Required',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please enable location access to find Qibla direction',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await locationProvider.getCurrentLocation();
                    },
                    child: const Text('Enable Location'),
                  ),
                ],
              ),
            );
          }

          if (locationProvider.qiblaDirection == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: AppColors.primaryGreen),
                  const SizedBox(height: 16),
                  const Text('Calculating Qibla direction...'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => locationProvider.calculateQiblaDirection(),
                    child: const Text('Recalculate'),
                  ),
                ],
              ),
            );
          }

          return _buildQiblaCompass(locationProvider);
        },
      ),
    );
  }

  Widget _buildQiblaCompass(LocationProvider locationProvider) {
    final qiblaDirection = locationProvider.qiblaDirection!;
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Location Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppColors.primaryGreen),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locationProvider.locationString,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Distance to Kaaba: ${qiblaDirection.distanceInKm}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => locationProvider.getCurrentLocation(),
                  ),
                ],
              ),
            ),
          ),

          // Compass
          Container(
            height: 350,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _deviceHeading == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primaryGreen),
                          const SizedBox(height: 16),
                          const Text('Calibrating compass...'),
                          const SizedBox(height: 8),
                          Text(
                            'If this takes too long, your device may not support compass features.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _deviceHeading = 0.0; // Use manual mode
                              });
                            },
                            child: const Text('Use Manual Mode'),
                          ),
                        ],
                      )
                    : _buildCompassWidget(qiblaDirection.direction),
              ),
            ),
          ),

          // Instructions Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: AppColors.info),
                      const SizedBox(width: 8),
                      Text(
                        'Instructions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('1. Hold your device flat horizontally'),
                  const SizedBox(height: 4),
                  const Text('2. Keep away from magnetic objects'),
                  const SizedBox(height: 4),
                  const Text('3. The green arrow points to Qibla direction'),
                  const SizedBox(height: 4),
                  const Text('4. Face the direction when the arrow aligns with North'),
                ],
              ),
            ),
          ),

          // Qibla Info Card
          Card(
            margin: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: AppColors.greenGradient,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.mosque,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Holy Kaaba',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Mecca, Saudi Arabia',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Direction',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            '${qiblaDirection.direction.toStringAsFixed(1)}°',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Distance',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.white.withOpacity(0.8),
                            ),
                          ),
                          Text(
                            qiblaDirection.distanceInKm,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompassWidget(double qiblaDirection) {
    final compassHeading = _deviceHeading ?? 0;
    final qiblaAngle = qiblaDirection - compassHeading;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Compass Background
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primaryGreen, width: 3),
            gradient: RadialGradient(
              colors: [
                AppColors.background,
                AppColors.primaryGreen.withOpacity(0.1),
              ],
            ),
          ),
        ),

        // Compass Markings
        ...List.generate(12, (index) {
          final angle = index * 30.0;
          final isMainDirection = index % 3 == 0;
          return Transform.rotate(
            angle: angle * math.pi / 180,
            child: Container(
              height: 280,
              width: 2,
              alignment: Alignment.topCenter,
              child: Container(
                height: isMainDirection ? 20 : 10,
                width: isMainDirection ? 3 : 2,
                color: AppColors.primaryGreen,
              ),
            ),
          );
        }),

        // Direction Labels
        Positioned(
          top: 10,
          child: Text(
            'N',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
        Positioned(
          right: 10,
          child: Text(
            'E',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: Text(
            'S',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        Positioned(
          left: 10,
          child: Text(
            'W',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),

        // Qibla Arrow
        Transform.rotate(
          angle: qiblaAngle * math.pi / 180,
          child: const Icon(
            Icons.navigation,
            size: 60,
            color: AppColors.qiblaArrow,
          ),
        ),

        // Center Dot
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryGreen,
          ),
        ),

        // Compass Heading Display
        Positioned(
          bottom: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${compassHeading.toStringAsFixed(0)}°',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('How to Use Qibla Finder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('1. Hold your device flat and horizontal'),
            SizedBox(height: 8),
            Text('2. Keep away from magnetic objects like speakers, metal objects'),
            SizedBox(height: 8),
            Text('3. The green arrow always points towards the Kaaba in Mecca'),
            SizedBox(height: 8),
            Text('4. Face the direction where the arrow points for prayer'),
            SizedBox(height: 8),
            Text('5. For better accuracy, ensure GPS is enabled'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}