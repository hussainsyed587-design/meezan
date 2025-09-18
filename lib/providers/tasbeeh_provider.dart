import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

class TasbeehProvider extends ChangeNotifier {
  int _count = 0;
  int _targetCount = 33;
  List<String> _history = [];
  String _currentDhikr = 'سبحان الله';
  bool _vibrateOnCount = true;
  
  int get count => _count;
  int get targetCount => _targetCount;
  List<String> get history => _history;
  String get currentDhikr => _currentDhikr;
  bool get vibrateOnCount => _vibrateOnCount;
  
  TasbeehProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _count = prefs.getInt('tasbeeh_count') ?? 0;
      _targetCount = prefs.getInt('tasbeeh_target') ?? 33;
      _history = prefs.getStringList('tasbeeh_history') ?? [];
      _currentDhikr = prefs.getString('tasbeeh_dhikr') ?? 'سبحان الله';
      _vibrateOnCount = prefs.getBool('tasbeeh_vibrate') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading Tasbeeh preferences: $e');
    }
  }
  
  Future<void> increment() async {
    _count++;
    
    if (_vibrateOnCount) {
      HapticFeedback.lightImpact();
    }
    
    if (_count == _targetCount) {
      _addToHistory();
      HapticFeedback.mediumImpact();
    }
    
    await _saveCount();
    notifyListeners();
  }
  
  Future<void> reset() async {
    if (_count > 0) {
      _addToHistory();
    }
    _count = 0;
    await _saveCount();
    notifyListeners();
  }
  
  Future<void> setTarget(int target) async {
    _targetCount = target;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbeeh_target', target);
    } catch (e) {
      debugPrint('Error saving target: $e');
    }
    notifyListeners();
  }
  
  Future<void> setDhikr(String dhikr) async {
    _currentDhikr = dhikr;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasbeeh_dhikr', dhikr);
    } catch (e) {
      debugPrint('Error saving dhikr: $e');
    }
    notifyListeners();
  }
  
  Future<void> toggleVibration() async {
    _vibrateOnCount = !_vibrateOnCount;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tasbeeh_vibrate', _vibrateOnCount);
    } catch (e) {
      debugPrint('Error saving vibration setting: $e');
    }
    notifyListeners();
  }
  
  Future<void> _saveCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('tasbeeh_count', _count);
    } catch (e) {
      debugPrint('Error saving count: $e');
    }
  }
  
  void _addToHistory() {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '$_currentDhikr: $_count ($timestamp)';
    _history.insert(0, entry);
    
    // Keep only last 50 entries
    if (_history.length > 50) {
      _history = _history.take(50).toList();
    }
    
    _saveHistory();
  }
  
  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('tasbeeh_history', _history);
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }
  
  void clearHistory() {
    _history.clear();
    _saveHistory();
    notifyListeners();
  }
  
  double get progress => _targetCount > 0 ? _count / _targetCount : 0.0;
  bool get isComplete => _count >= _targetCount;
}