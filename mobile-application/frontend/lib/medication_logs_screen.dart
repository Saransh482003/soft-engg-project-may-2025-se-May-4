import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'services/medication_log_service.dart';
import 'services/pdf_service.dart';
import 'services/data_storage_service.dart';
import 'theme_constants.dart';

class MedicationLogsScreen extends StatefulWidget {
  const MedicationLogsScreen({Key? key}) : super(key: key);

  @override
  State<MedicationLogsScreen> createState() => _MedicationLogsScreenState();
}

class _MedicationLogsScreenState extends State<MedicationLogsScreen> 
    with TickerProviderStateMixin {  List<Map<String, dynamic>> _logs = [];
  Map<String, int> _stats = {};  bool _isLoading = true;
  final String _filter = 'all'; // 'all', 'taken', 'forgot'
  
  // Animation controllers
  late AnimationController _swipeIndicatorController;
  late TabController _tabController;
  
  // Track drag state for visual feedback
  bool _isDragging = false;
  double _dragOffset = 0.0;

  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize animation controller for swipe indicator
    _swipeIndicatorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Start the animation
    _swipeIndicatorController.repeat(reverse: true);
    
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    print('🔄 Loading medication logs...');
    setState(() => _isLoading = true);
    
    try {
      List<Map<String, dynamic>> logs = await MedicationLogService.getMedicationLogs();
      
      // Apply filter if needed
      if (_filter != 'all') {
        logs = logs.where((log) => log['action'] == _filter).toList();
      }
      
      final stats = await MedicationLogService.getActionStats();
      
      if (logs.isNotEmpty) {
        // Sort logs by action time (most recent first)
        logs.sort((a, b) => 
          DateTime.parse(b['actionTime']).compareTo(DateTime.parse(a['actionTime']))
        );
      }
      
      if (mounted) {
        setState(() {
          _logs = logs;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ ERROR loading logs: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading logs: $e')),
        );
      }
    }
  }

  String _formatDateTime(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(String dateTimeStr) {
    final dateTime = DateTime.parse(dateTimeStr);
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  Future<void> _generateFakeAdherenceData() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
              ),
              const SizedBox(height: 16),
              const Text('Generating demo adherence data...'),
              const SizedBox(height: 8),
              Text(
                'Creating 90 days of realistic medication\nadherence patterns for analysis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Generate fake adherence data
      final success = await DataStorageService.generateFakeAdherenceData();
      
      // Also generate data specifically for MedicationLogService
      final logSuccess = await DataStorageService.generateFakeMedicationLogs();

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (success && logSuccess) {
        // Refresh the logs to show new data
        await _loadLogs();

        // Get analytics data to show in summary
        final analyticsData = await DataStorageService.getAdherenceAnalytics();
        
        // Show success dialog with analytics summary
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.trending_up,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Adherence Data Generated!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Successfully generated realistic adherence patterns:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Analytics summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.assessment, 
                              color: ThemeConstants.primaryColor, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Adherence Summary (90 days)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• Total Doses: ${analyticsData['summary']['total_doses']}'),
                        Text('• Taken: ${analyticsData['summary']['taken_doses']}'),
                        Text('• Missed: ${analyticsData['summary']['missed_doses']}'),
                        Text('• Adherence Rate: ${analyticsData['summary']['adherence_rate']}%'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.insights, 
                              color: Colors.orange[600], size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'Analysis Features Available',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text('• Weekly adherence trends'),
                        const Text('• Time-of-day patterns'),
                        const Text('• Medicine-specific rates'),
                        const Text('• Day-of-week analysis'),
                        const Text('• Delay patterns'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'This realistic data includes patterns like weekend effects, time-of-day variations, and gradual improvement over time.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Clear fake adherence data option
                  final shouldClear = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Adherence Data'),
                      content: const Text('Do you want to remove the generated adherence data?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Keep'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldClear == true) {
                    await DataStorageService.clearFakeAdherenceData();
                    await DataStorageService.clearFakeMedicationLogs();
                    await _loadLogs();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Adherence demo data cleared successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: Text(
                  'Clear Data',
                  style: TextStyle(color: Colors.orange[600]),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to generate adherence data'),
              ],
            ),
            backgroundColor: ThemeConstants.secondaryColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error generating adherence data: $e')),
            ],
          ),
          backgroundColor: ThemeConstants.secondaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _debugStorage() async {
    try {
      // Debug MedicationLogService storage
      await MedicationLogService.debugStorage();
      await MedicationLogService.debugAllStorage();
      
      // Debug DataStorageService storage
      final dataStorageData = await DataStorageService.getData();
      print('🔍 DataStorageService data: $dataStorageData');
      
      final summary = await DataStorageService.getDataSummary();
      print('🔍 DataStorageService summary: $summary');
      
      // Show debug info in UI
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Storage Debug Info'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Debug information has been logged to console.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DataStorageService Summary:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('• Medicines: ${summary['medicines']}'),
                Text('• Prescriptions: ${summary['prescriptions']}'),
                Text('• Total: ${summary['total']}'),
                const SizedBox(height: 16),
                Text(
                  'Current Logs: ${_logs.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Current Stats: $_stats',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Debug error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Debug error: $e'),
          backgroundColor: ThemeConstants.secondaryColor,
        ),
      );
    }
  }

  Future<void> _generateSpecificAdherencePattern(String pattern) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(ThemeConstants.primaryColor),
              ),
              const SizedBox(height: 16),
              Text('Generating ${_getPatternDisplayName(pattern)} data...'),
              const SizedBox(height: 8),
              Text(
                'Creating realistic medication patterns\nfor medical analysis',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

      // Generate specific pattern data
      final success = await _generatePatternData(pattern);

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (success) {
        // Refresh the logs to show new data
        await _loadLogs();

        // Get analytics data to show in summary
        final analyticsData = await DataStorageService.getAdherenceAnalytics();
        
        // Show success dialog with pattern-specific information
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getPatternColor(pattern).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getPatternIcon(pattern),
                    color: _getPatternColor(pattern),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_getPatternDisplayName(pattern)} Generated!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Successfully generated ${_getPatternDisplayName(pattern).toLowerCase()} pattern:',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Pattern-specific summary
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getPatternColor(pattern).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _getPatternColor(pattern).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(_getPatternIcon(pattern), 
                              color: _getPatternColor(pattern), size: 18),
                            const SizedBox(width: 6),
                            const Text(
                              'Pattern Summary (30 days)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('• Total Doses: ${analyticsData['summary']['total_doses']}'),
                        Text('• Taken: ${analyticsData['summary']['taken_doses']}'),
                        Text('• Missed: ${analyticsData['summary']['missed_doses']}'),
                        Text('• Adherence Rate: ${analyticsData['summary']['adherence_rate']}%'),
                        const SizedBox(height: 8),
                        Text(
                          _getPatternDescription(pattern),
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'This ${pattern.replaceAll('_', ' ')} pattern provides realistic data for testing different adherence scenarios in medical analysis.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getPatternColor(pattern),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Great!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Text('Failed to generate adherence pattern'),
              ],
            ),
            backgroundColor: ThemeConstants.secondaryColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if it's open
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Error generating pattern: $e')),
            ],
          ),
          backgroundColor: ThemeConstants.secondaryColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _generatePatternData(String pattern) async {
    // Clear previous fake data first
    await DataStorageService.clearFakeAdherenceData();
    
    final random = DateTime.now().millisecondsSinceEpoch;
    final baseDate = DateTime.now().subtract(const Duration(days: 30));
    
    final medicineNames = [
      'Metformin', 'Lisinopril', 'Atorvastatin', 'Levothyroxine', 
      'Amlodipine', 'Omeprazole'
    ];

    List<Map<String, dynamic>> adherenceData = [];
    
    // Generate 30 days of data
    for (int day = 0; day < 30; day++) {
      final logDate = baseDate.add(Duration(days: day));
      
      // 3 doses per day (morning, afternoon, evening)
      for (int dose = 0; dose < 3; dose++) {
        final medicineIndex = (day + dose) % medicineNames.length;
        final medicine = medicineNames[medicineIndex];
        
        final baseHour = dose == 0 ? 8 : dose == 1 ? 14 : 20;
        final logTime = logDate.add(Duration(
          hours: baseHour + (dose % 2),
          minutes: (dose * 15) % 60,
        ));
        
        // Calculate adherence based on pattern
        double adherenceRate = _calculatePatternAdherence(pattern, day, dose, logDate);
        
        final randomFactor = ((random + day + dose) % 100) / 100.0;
        final action = randomFactor < adherenceRate ? 'taken' : 'forgot';
        
        int delayMinutes = 0;
        if (action == 'taken' && pattern != 'excellent') {
          final delayRandom = ((random + day * dose) % 100) / 100.0;
          if (delayRandom > 0.7) {
            delayMinutes = pattern == 'poor' || pattern == 'very_poor' 
              ? 30 + ((random + dose) % 120) // 30min-2.5h late
              : 10 + ((random + dose) % 30);  // 10-40min late
          }
        }
        
        final actualTime = logTime.add(Duration(minutes: delayMinutes));
        
        adherenceData.add({
          'medicine_id': 'PATTERN_${pattern.toUpperCase()}_${medicine}_${day}_$dose',
          'medicine_name': medicine,
          'dosage': '1 tablet',
          'action': action,
          'actionTime': actualTime.toIso8601String(),
          'reminderTime': logTime.toIso8601String(),
          'delay_minutes': delayMinutes,
          'notes': action == 'taken' 
            ? delayMinutes == 0 
              ? 'Taken on time' 
              : 'Taken $delayMinutes minutes late'
            : 'Missed - ${_getPatternMissReason(pattern, random + day + dose)}',
          'timestamp': actualTime.millisecondsSinceEpoch,
          'day_of_week': logDate.weekday,
          'hour_of_day': actualTime.hour,
          'dose_time': dose == 0 ? 'morning' : dose == 1 ? 'afternoon' : 'evening',
          'adherence_score': action == 'taken' 
            ? delayMinutes == 0 ? 100 : (100 - (delayMinutes / 3)).round().clamp(0, 100)
            : 0,
          'pattern_type': pattern,
        });
      }
    }

    // Add pattern adherence data
    await DataStorageService.addMedicines(adherenceData);
    return true;
  }

  double _calculatePatternAdherence(String pattern, int day, int dose, DateTime date) {
    switch (pattern) {
      case 'excellent':
        double base = 0.97; // 97% base rate
        if (dose == 2) base += 0.02; // Evening doses slightly better
        return base.clamp(0.0, 1.0);
        
      case 'good':
        double base = 0.85; // 85% base rate
        if (day > 20) base += 0.05; // Recent improvement
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          base -= 0.08; // Weekend effect
        }
        return base.clamp(0.0, 1.0);
        
      case 'poor':
        double base = 0.65; // 65% base rate
        if (dose == 0) base -= 0.10; // Morning doses harder
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          base -= 0.15; // Strong weekend effect
        }
        return base.clamp(0.0, 1.0);
        
      case 'very_poor':
        double base = 0.40; // 40% base rate
        if (day < 10) base += 0.10; // Started better
        if (dose == 0) base -= 0.15; // Morning very problematic
        return base.clamp(0.0, 1.0);
        
      case 'improving':
        double base = 0.50 + (day / 30.0 * 0.40); // 50% to 90% improvement
        if (dose == 2) base += 0.05; // Evening consistency
        return base.clamp(0.0, 1.0);
        
      case 'declining':
        double base = 0.90 - (day / 30.0 * 0.35); // 90% to 55% decline
        if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
          base -= 0.10; // Weekend compounds decline
        }
        return base.clamp(0.0, 1.0);
        
      default:
        return 0.85; // Default good adherence
    }
  }

  String _getPatternMissReason(String pattern, int seed) {
    final reasons = {
      'excellent': ['Minor schedule conflict', 'Ran out temporarily'],
      'good': ['Forgot morning dose', 'Was traveling', 'Busy at work'],
      'poor': ['Frequently forgets', 'Side effects concern', 'Feels better without it', 'Schedule too difficult'],
      'very_poor': ['Stopped taking regularly', 'Doesn\'t believe it helps', 'Too many side effects', 'Can\'t remember'],
      'improving': ['Learning routine', 'Setting better reminders', 'Getting used to schedule'],
      'declining': ['Losing motivation', 'Schedule becoming difficult', 'Questioning necessity'],
    };
    
    final patternReasons = reasons[pattern] ?? reasons['good']!;
    return patternReasons[seed % patternReasons.length];
  }

  String _getPatternDisplayName(String pattern) {
    switch (pattern) {
      case 'excellent': return 'Excellent Adherence';
      case 'good': return 'Good Adherence';
      case 'poor': return 'Poor Adherence';
      case 'very_poor': return 'Very Poor Adherence';
      case 'improving': return 'Improving Pattern';
      case 'declining': return 'Declining Pattern';
      default: return 'Adherence Pattern';
    }
  }

  IconData _getPatternIcon(String pattern) {
    switch (pattern) {
      case 'excellent': return Icons.star;
      case 'good': return Icons.thumb_up;
      case 'poor': return Icons.warning;
      case 'very_poor': return Icons.error;
      case 'improving': return Icons.trending_up;
      case 'declining': return Icons.trending_down;
      default: return Icons.analytics;
    }
  }

  Color _getPatternColor(String pattern) {
    switch (pattern) {
      case 'excellent': return Colors.green;
      case 'good': return Colors.blue;
      case 'poor': return Colors.orange;
      case 'very_poor': return Colors.red;
      case 'improving': return Colors.purple;
      case 'declining': return Colors.brown;
      default: return ThemeConstants.primaryColor;
    }
  }

  String _getPatternDescription(String pattern) {
    switch (pattern) {
      case 'excellent': 
        return 'Near-perfect adherence with minimal delays and consistent timing across all doses.';
      case 'good': 
        return 'Good overall adherence with occasional missed doses and minor delays, especially on weekends.';
      case 'poor': 
        return 'Inconsistent adherence with frequent missed morning doses and significant weekend effects.';
      case 'very_poor': 
        return 'Very low adherence rates with multiple missed doses daily and irregular timing.';
      case 'improving': 
        return 'Shows steady improvement over time as patient establishes better routines and habits.';
      case 'declining': 
        return 'Demonstrates gradual decline in adherence, possibly due to side effects or motivation loss.';
      default: 
        return 'Standard adherence pattern for medical analysis.';
    }
  }

  // Generate weekly data for charts
  List<FlSpot> _getWeeklyTakenData() {
    Map<int, int> weeklyData = {};
    final now = DateTime.now();
    
    // Initialize the last 7 days
    for (int i = 6; i >= 0; i--) {
      weeklyData[6 - i] = 0;
    }
    
    // Count taken medications for each day
    for (var log in _logs) {
      if (log['action'] == 'taken') {
        final logDate = DateTime.parse(log['actionTime']);
        final daysDiff = now.difference(logDate).inDays;
        if (daysDiff >= 0 && daysDiff < 7) {
          weeklyData[6 - daysDiff] = (weeklyData[6 - daysDiff] ?? 0) + 1;
        }
      }
    }
    
    return weeklyData.entries.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList();
  }

  // Get monthly adherence data with side-by-side bars
  List<BarChartGroupData> _getMonthlyAdherenceData() {
    Map<int, Map<String, int>> monthlyData = {};
    final now = DateTime.now();
    
    // Initialize the last 4 weeks
    for (int i = 3; i >= 0; i--) {
      monthlyData[3 - i] = {'taken': 0, 'forgot': 0};
    }
    
    // Count medications for each week
    for (var log in _logs) {
      final logDate = DateTime.parse(log['actionTime']);
      final weeksDiff = (now.difference(logDate).inDays / 7).floor();
      if (weeksDiff >= 0 && weeksDiff < 4) {
        final weekIndex = 3 - weeksDiff;
        monthlyData[weekIndex]![log['action']] = 
          (monthlyData[weekIndex]![log['action']] ?? 0) + 1;
      }
    }
    
    return monthlyData.entries.map((e) => 
      BarChartGroupData(
        x: e.key,
        barsSpace: 4,
        barRods: [
          BarChartRodData(
            toY: e.value['taken']!.toDouble(),
            color: const Color.fromARGB(255, 0, 120, 10),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
          BarChartRodData(
            toY: e.value['forgot']!.toDouble(),
            color: const Color.fromARGB(255, 216, 0, 36),
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      )
    ).toList();
  }

  // Navigate back to dashboard with smooth transition
  void _navigateBackToDashboard() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx > 0) {
          _navigateBackToDashboard();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Medication Analytics'),
          backgroundColor: ThemeConstants.primaryColor,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.science_outlined, color: Colors.white, size: 24),
              onPressed: _generateFakeAdherenceData,
              tooltip: 'Generate Demo Adherence Data',
            ),
            IconButton(
              icon: const Icon(Icons.bug_report_outlined, color: Colors.white, size: 20),
              onPressed: _debugStorage,
              tooltip: 'Debug Storage',
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              tooltip: 'Advanced Adherence Patterns',
              onSelected: (String value) => _generateSpecificAdherencePattern(value),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'excellent',
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text('Excellent Adherence (95%+)'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'good',
                  child: Row(
                    children: [
                      Icon(Icons.thumb_up, color: Colors.blue, size: 20),
                      SizedBox(width: 8),
                      Text('Good Adherence (80-95%)'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'poor',
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text('Poor Adherence (50-80%)'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'very_poor',
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Text('Very Poor Adherence (<50%)'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'improving',
                  child: Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.purple, size: 20),
                      SizedBox(width: 8),
                      Text('Improving Pattern'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'declining',
                  child: Row(
                    children: [
                      Icon(Icons.trending_down, color: Colors.brown, size: 20),
                      SizedBox(width: 8),
                      Text('Declining Pattern'),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            tabs: const [
              Tab(icon: Icon(Icons.analytics), text: 'Analysis'),
              Tab(icon: Icon(Icons.list), text: 'Logs'),
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'Save & Open PDF'),
            ],
          ),
        ),
        body: GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            setState(() {
              _isDragging = true;
              _dragOffset = 0.0;
            });
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            setState(() {
              _dragOffset = details.localPosition.dx;
            });
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            setState(() {
              _isDragging = false;
              _dragOffset = 0.0;
            });
            
            if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
              _navigateBackToDashboard();
            }
          },
          child: Transform.translate(
            offset: Offset(_isDragging ? _dragOffset * 0.1 : 0, 0),
            child: Stack(
              children: [
                TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnalysisTab(),
                    _buildLogsTab(),
                    _buildDownloadTab(),
                  ],
                ),
                // Animated swipe indicator
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: AnimatedBuilder(
                    animation: _swipeIndicatorController,
                    builder: (context, child) {
                      final animationValue = (_swipeIndicatorController.value * 0.7) + 0.3;
                      
                      return Opacity(
                        opacity: _isDragging ? 1.0 : animationValue,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _isDragging 
                                ? ThemeConstants.primaryColor.withOpacity(0.9)
                                : Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: Offset(
                                  _isDragging 
                                      ? _dragOffset * 0.05 
                                      : animationValue * 3, 
                                  0
                                ),
                                child: Icon(
                                  _isDragging ? Icons.touch_app : Icons.arrow_forward_ios,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isDragging ? 'Release to go back' : 'Swipe right to go back',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Analysis Tab with Charts
  Widget _buildAnalysisTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No data for analysis',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Charts will appear here once you have medication logs',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Stats Overview Card
          _buildStatsOverviewCard(),
          const SizedBox(height: 16),
          // Weekly Trend Chart
          _buildWeeklyTrendCard(),
          const SizedBox(height: 16),
          // Adherence Rate Pie Chart
          _buildAdherenceRateCard(),
          const SizedBox(height: 16),
          // Monthly Bar Chart
          _buildMonthlyBarCard(),
        ],
      ),
    );
  }

  // Stats Overview Card
  Widget _buildStatsOverviewCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medication Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total', _stats['total'].toString(), ThemeConstants.primaryColor),
                _buildStatItem('Taken', _stats['taken'].toString(), const Color.fromARGB(255, 0, 120, 10)),
                _buildStatItem('Missed', _stats['forgot'].toString(), const Color.fromARGB(255, 216, 0, 36)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Weekly Trend Chart Card
  Widget _buildWeeklyTrendCard() {
    final weeklyData = _getWeeklyTakenData();
    final maxValue = weeklyData.isNotEmpty 
        ? weeklyData.map((spot) => spot.y).reduce((a, b) => a > b ? a : b) 
        : 5.0;
    final totalTaken = weeklyData.fold(0.0, (sum, spot) => sum + spot.y);
    final averagePerDay = weeklyData.isNotEmpty ? totalTaken / weeklyData.length : 0.0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Adherence Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Average ${averagePerDay.toStringAsFixed(1)} medications taken per day this week',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: (maxValue + 2).ceilToDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                    getDrawingVerticalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          if (value.toInt() >= 0 && value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weeklyData,
                      isCurved: true,
                      curveSmoothness: 0.3,
                      color: ThemeConstants.primaryColor,
                      barWidth: 3,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: ThemeConstants.primaryColor,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            ThemeConstants.primaryColor.withOpacity(0.3),
                            ThemeConstants.primaryColor.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adherence Rate Card
  Widget _buildAdherenceRateCard() {
    final taken = _stats['taken'] ?? 0;
    final total = _stats['total'] ?? 1;
    final adherenceRate = total > 0 ? (taken / total) * 100 : 0.0;
    
    String observation = '';
    if (adherenceRate >= 90) {
      observation = 'Excellent adherence! Keep up the great work.';
    } else if (adherenceRate >= 80) {
      observation = 'Good adherence rate, but there\'s room for improvement.';
    } else if (adherenceRate >= 60) {
      observation = 'Moderate adherence - consider setting more reminders.';
    } else {
      observation = 'Low adherence detected - please consult your healthcare provider.';
    }
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adherence Rate',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              observation,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: [
                          PieChartSectionData(
                            value: taken.toDouble(),
                            color: const Color.fromARGB(255, 0, 120, 10),
                            title: '$taken',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          PieChartSectionData(
                            value: (total - taken).toDouble(),
                            color: const Color.fromARGB(255, 216, 0, 36),
                            title: '${total - taken}',
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${adherenceRate.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: adherenceRate >= 80 ? const Color.fromARGB(255, 0, 120, 10) : 
                                 adherenceRate >= 60 ? const Color.fromARGB(255, 255, 165, 0) : const Color.fromARGB(255, 216, 0, 36),
                        ),
                      ),
                      const Text(
                        'Adherence Rate',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 0, 120, 10),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Taken', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 216, 0, 36),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Missed', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Monthly Bar Chart Card
  Widget _buildMonthlyBarCard() {
    final monthlyData = _getMonthlyAdherenceData();
    final maxValue = monthlyData.isNotEmpty 
        ? monthlyData.map((group) => group.barRods.map((rod) => rod.toY).reduce((a, b) => a > b ? a : b)).reduce((a, b) => a > b ? a : b)
        : 5.0;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Overview',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ThemeConstants.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Weekly breakdown showing taken vs missed medications over the last month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: BarChart(
                BarChartData(
                  maxY: (maxValue + 2).ceilToDouble(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final weeks = ['Week 1', 'Week 2', 'Week 3', 'Week 4'];
                          if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                weeks[value.toInt()],
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 9),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  barGroups: monthlyData,
                  groupsSpace: 12,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  color: const Color.fromARGB(255, 0, 120, 10),
                ),
                const SizedBox(width: 8),
                const Text('Taken', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  color: const Color.fromARGB(255, 216, 0, 36),
                ),
                const SizedBox(width: 8),
                const Text('Missed', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Logs Tab
  Widget _buildLogsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_logs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medication, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No medication logs found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Logs will appear here when you interact with medication reminders',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Group logs by date
    Map<String, List<Map<String, dynamic>>> groupedLogs = {};
    for (var log in _logs) {
      final date = _formatDate(log['actionTime']);
      if (!groupedLogs.containsKey(date)) {
        groupedLogs[date] = [];
      }
      groupedLogs[date]!.add(log);
    }

    final sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) {
        final dateA = DateTime.parse(groupedLogs[a]!.first['actionTime']);
        final dateB = DateTime.parse(groupedLogs[b]!.first['actionTime']);
        return dateB.compareTo(dateA);
      });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final logsForDate = groupedLogs[date]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date separator
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ThemeConstants.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ThemeConstants.primaryColor,
                ),
              ),
            ),
            // Logs for this date
            ...logsForDate.map((log) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: _buildLogItem(log),
            )),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
  // Download PDF Tab
  Widget _buildDownloadTab() {
    return SingleChildScrollView(  // Add scrollable container
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,  // Change from center to start
        children: [
          const SizedBox(height: 40),  // Add top spacing instead of center alignment
          Icon(
            Icons.picture_as_pdf,
            size: 80,
            color: ThemeConstants.primaryColor.withOpacity(0.6),
          ),
          const SizedBox(height: 20),
          const Text(
            'Generate Medication Report',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ThemeConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a comprehensive PDF report containing:\n• Patient information\n• Medication adherence statistics\n• Complete medication logs\n• Visual summaries',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _showPDFActionDialog,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download),
            label: Text(_isLoading ? 'Generating...' : 'Save & Open PDF Report'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_logs.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Report will include ${_logs.length} medication logs',
                      style: TextStyle(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 40),  // Add bottom spacing
        ],
      ),
    );
  }


  @override
  void dispose() {
    _swipeIndicatorController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final action = log['action'];
    final medicineName = log['medicineName'];
    final reminderTime = _formatDateTime(log['reminderTime']);
    final actionTime = _formatDateTime(log['actionTime']);
    
    final isTaken = action == 'taken';
    final iconData = isTaken ? Icons.check_circle : Icons.cancel;
    final iconColor = isTaken ? const Color.fromARGB(255, 0, 120, 10) : const Color.fromARGB(255, 216, 0, 36);
    final backgroundColor = isTaken ? const Color.fromARGB(255, 220, 248, 220) : const Color.fromARGB(255, 255, 220, 220);

    return Card(
      elevation: 2,
      color: backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(iconData, color: iconColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Action: ${isTaken ? 'Taken' : 'Missed'}',
                    style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Reminder: $reminderTime',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  Text(
                    'Logged: $actionTime',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );  }

  // Fix the method signature and implementation
  void _showPDFActionDialog() async {
    try {
      // Generate PDF bytes first
      final pdfBytes = await PDFService.generateMedicationReportBytes();
      
      // Then show the dialog with the generated bytes
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('PDF Report Options'),
            content: const Text('Choose how you want to handle your medication report:'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _previewPDF(pdfBytes);
                },
                child: const Text('Preview & Share'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _saveAndOpenPDF(pdfBytes);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ThemeConstants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save & Open'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _previewPDF(Uint8List pdfBytes) async {
    try {
      setState(() => _isLoading = true);
      await PDFService.previewPDF(pdfBytes);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ PDF preview opened successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error previewing PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  Future<void> _saveAndOpenPDF(Uint8List pdfBytes) async {
    try {
      setState(() => _isLoading = true);
      final filePath = await PDFService.saveAndOpenPDF(pdfBytes, 'medication_report.pdf');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ PDF saved and opened: $filePath'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error saving PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
