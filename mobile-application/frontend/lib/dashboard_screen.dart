import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'medication_logs_screen.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart' as tz;
import 'dart:convert';
import 'theme_constants.dart';
import 'constants.dart';
import 'add_prescription_screen.dart';
import 'package:frontend/services/noti_serve.dart';
import 'services/auth_service.dart';
import 'services/data_storage_service.dart';

class DashboardScreen extends StatefulWidget {
  final String username;
  final String password;

  const DashboardScreen({
    Key? key,
    required this.username,
    required this.password,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> _upcomingReminders = [];
  List<Map<String, dynamic>> _allReminders = [];
  final GlobalKey _notificationKey = GlobalKey();
  bool _showNotificationsDropdown = false;
  Map<String, String> _medicineInfo = {};  // Store medicine info for each medicine
  List<Map<String, dynamic>> _completedReminders = [];
  bool isLoading = true;
  final TextEditingController _medicineNameController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _sideEffectsController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
    // Animation controller for swipe indicator
  late AnimationController _swipeIndicatorController;
  
  // Track drag state for visual feedback
  bool _isDragging = false;
  double _dragOffset = 0.0;  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for swipe indicator
    _swipeIndicatorController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Start the animation
    _swipeIndicatorController.repeat(reverse: true);
    
    _fetchUserData();
    _fetchReminders();
  }
  @override
  void dispose() {
    _medicineNameController.dispose();
    _dosageController.dispose();
    _sideEffectsController.dispose();
    _frequencyController.dispose();
    _swipeIndicatorController.dispose();
    super.dispose();
  }

  Future<void> _fetchReminders() async {
    setState(() => isLoading = true);
    try {
      final reminders = await NotiService().getRemainingRemindersForToday();
      final allReminders = await NotiService().getAllRemindersForToday();
      final now = tz.TZDateTime.now(tz.local);
      setState(() {
        _upcomingReminders = reminders;
        _allReminders = allReminders;
        _completedReminders = allReminders.where((reminder) {
          final scheduledTime = reminder['scheduledTime'] as tz.TZDateTime;
          return scheduledTime.isBefore(now);
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load reminders: $e')),
      );
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchReminders();
  }

  Future<void> _fetchUserData() async {
    if (!mounted) return;

    setState(() => isLoading = true);
    try {
      final prescriptions = await DataStorageService.getPrescriptions();
      setState(() {
        // userData = jsonDecode(responseData);
        userData = <String, dynamic>{};
        userData?["prescriptions"] = prescriptions;
        isLoading = false;
        _medicineInfo = {}; // Reset medicine info
      });
    } catch (e) {
      if (mounted) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }
  // Add these methods to your _DashboardScreenState class

  Future<void> _viewStoredData() async {
    try {
      // Get all stored data
      final allData = await DataStorageService.getData();
      print('=== ALL STORED DATA ===');
      print(allData);
      
      // Get medicines only
      final medicines = await DataStorageService.getMedicines();
      print('=== MEDICINES ===');
      print(medicines);
      
      // Get prescriptions only
      final prescriptions = await DataStorageService.getPrescriptions();
      print('=== PRESCRIPTIONS ===');
      print(prescriptions);
      
      // Get data summary
      final summary = await DataStorageService.getDataSummary();
      print('=== DATA SUMMARY ===');
      print(summary);
      
      // Show in UI as well
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data logged to console. Medicines: ${summary['medicines']}, Prescriptions: ${summary['prescriptions']}'),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      print('Error viewing stored data: $e');
    }
  }

  Future<void> _showDataDialog() async {
    try {
      final allData = await DataStorageService.getData();
      final summary = await DataStorageService.getDataSummary();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Stored Data'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Medicines Count: ${summary['medicines']}'),
                Text('Prescriptions Count: ${summary['prescriptions']}'),
                const SizedBox(height: 16),
                const Text('Full Data:'),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    allData.toString(),
                    style: const TextStyle(fontSize: 12),
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
          ],
        ),
      );
    } catch (e) {
      print('Error showing data dialog: $e');
    }
  }
Future<void> _deletePrescription(String presId, String medicineName) async {
  try {
    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.delete_forever,
                color: ThemeConstants.secondaryColor.withOpacity(0.6),
                size: 28,
              ),
              const SizedBox(width: 12),
              const Text(
                'Delete Prescription',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete the prescription for "$medicineName"? This action cannot be undone.',
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeConstants.secondaryColor.withOpacity(0.6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      bool success = false;
      String errorMessage = '';

      try {
        // First, try to delete from server (if needed)
        if (userData?['user_id'] != null) {
          final response = await http.delete(
            Uri.parse('$baseUrl/delete-prescriptions'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userData?['user_id'],
              'pres_id': presId,
            }),
          );
          
          if (response.statusCode == 200) {
            success = true;
          } else {
            errorMessage = 'Server deletion failed: ${response.statusCode}';
          }
        } else {
          // If no user_id, still allow local deletion
          success = true;
        }

        // Delete from local storage regardless of server response
        try {
          // Get current prescriptions
          final currentPrescriptions = await DataStorageService.getPrescriptions();
          
          // Remove the prescription with matching presId
          final updatedPrescriptions = currentPrescriptions.where((prescription) {
            return prescription['pres_id'] != presId;
          }).toList();
          
          // Save updated list back to storage
          await DataStorageService.savePrescriptions(updatedPrescriptions);
          
          success = true;
        } catch (localError) {
          errorMessage = 'Local deletion failed: $localError';
          success = false;
        }

      } catch (e) {
        errorMessage = 'Network error: $e';
        success = false;
      }

      // Close loading dialog
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (success) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Prescription for "$medicineName" deleted successfully'),
              ],
            ),
            backgroundColor: Colors.green[600],
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Refresh the data
        _fetchUserData();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Failed to delete prescription: $errorMessage')),
              ],
            ),
            backgroundColor: ThemeConstants.secondaryColor.withOpacity(0.6),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  } catch (e) {
    // Close loading dialog if it's open
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Error deleting prescription: $e')),
          ],
        ),
        backgroundColor: ThemeConstants.secondaryColor.withOpacity(0.6),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

  DateTime _parseExpiryDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length == 3) {
        const months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12
        };
        return DateTime(
          int.parse(parts[2]), // year
          months[parts[1]] ?? 1, // month
          int.parse(parts[0]), // day
        );
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime(1900); // Default date for invalid formats
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Health Dashboard',
          style: TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ThemeConstants.primaryColor,
                ThemeConstants.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              key: _notificationKey,
              icon: Stack(
                children: [
                  const Icon(Icons.notifications_outlined, color: Colors.white, size: 24),
                  if (_completedReminders.isNotEmpty)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: ThemeConstants.secondaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${_completedReminders.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              onPressed: () async {
                if (_showNotificationsDropdown) {
                  setState(() => _showNotificationsDropdown = false);
                } else {
                  await _fetchReminders();
                  setState(() => _showNotificationsDropdown = true);
                }
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.storage_rounded, color: Colors.white, size: 24),
              onPressed: _showDataDialog,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 24),
              onPressed: () async {
                await AuthService.clearStoredCredentials();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
            ),
          ),
        ],
      ),      body: Container(
        decoration: const BoxDecoration(
          // gradient: LinearGradient(
          //   begin: Alignment.topCenter,
          //   end: Alignment.bottomCenter,
          //   colors: [
          //     ThemeConstants.primaryColor.withOpacity(0.05),
          //     Colors.grey[50]!,
          //     Colors.white,
          //   ],
          //   stops: const [0.0, 0.3, 1.0],
          // ),
        ),
        child: GestureDetector(
          onHorizontalDragStart: (DragStartDetails details) {
            setState(() {
              _isDragging = false;
              _dragOffset = 0.0;
            });
          },
          onHorizontalDragUpdate: (DragUpdateDetails details) {
            if (details.delta.dx < 0) {
              setState(() {
                _isDragging = true;
                _dragOffset = details.localPosition.dx;
              });
            }
          },
          onHorizontalDragEnd: (DragEndDetails details) {
            setState(() {
              _isDragging = false;
              _dragOffset = 0.0;
            });
            
            if (details.primaryVelocity != null && details.primaryVelocity! < -300) {
              _navigateToMedicationLogs();
            }
          },
          child: Transform.translate(
            offset: Offset(_isDragging ? _dragOffset * 0.1 : 0, 0),
            child: Stack(
              children: [
                isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ThemeConstants.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Loading your health data...',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [                            // Enhanced Profile Section with Modern Design
                            Container(
                              margin: const EdgeInsets.only(top: 88),
                              child: Stack(
                                children: [
                                  // Background with sophisticated gradient
                                  Container(
                                    height: 400,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          ThemeConstants.primaryColor,
                                          ThemeConstants.primaryColor.withOpacity(0.9),
                                          ThemeConstants.primaryColor.withOpacity(0.8),
                                        ],
                                      ),
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(50),
                                        bottomRight: Radius.circular(50),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: ThemeConstants.primaryColor.withOpacity(0.3),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Animated background elements
                                  Positioned(
                                    right: -40,
                                    top: -30,
                                    child: Container(
                                      width: 200,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: -60,
                                    bottom: -40,
                                    child: Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 50,
                                    bottom: 80,
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.06),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  
                                  // Main content
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 24),
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 40),
                                        
                                        // Enhanced Profile Picture
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            // Outer glow effect
                                            Container(
                                              width: 160,
                                              height: 160,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: RadialGradient(
                                                  colors: [
                                                    Colors.white.withOpacity(0.3),
                                                    Colors.transparent,
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Profile picture with premium border
                                            Container(
                                              width: 140,
                                              height: 140,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Colors.grey[100]!,
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.2),
                                                    blurRadius: 20,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 8),
                                                  ),
                                                ],
                                              ),
                                              child: const CircleAvatar(
                                                backgroundColor: Colors.transparent,
                                                child: Icon(
                                                  Icons.person_rounded,
                                                  size: 70,
                                                  color: ThemeConstants.primaryColor,
                                                ),
                                              ),
                                            ),
                                            // Enhanced edit button
                                            Positioned(
                                              bottom: 5,
                                              right: MediaQuery.of(context).size.width * 0.22,
                                              child: Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  gradient: const LinearGradient(
                                                    colors: [
                                                      Colors.white,
                                                      Colors.white,
                                                    ],
                                                  ),
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: ThemeConstants.primaryColor,
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.2),
                                                      blurRadius: 8,
                                                      offset: const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(
                                                  Icons.camera_alt_rounded,
                                                  size: 20,
                                                  color: ThemeConstants.primaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 24),
                                        
                                        // Enhanced User Info
                                        Column(
                                          children: [
                                            const Text(
                                              "Shravan",
                                              style: TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 16,
                                                vertical: 8,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(20),
                                                border: Border.all(
                                                  color: Colors.white.withOpacity(0.3),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.email_rounded,
                                                    color: Colors.white,
                                                    size: 18,
                                                  ),
                                                  SizedBox(width: 8),
                                                  Text(
                                                    "hq.sharavan@iitm.ac.in",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            
                                            const SizedBox(height: 32),
                                            
                                            // Enhanced Quick Stats Card
                                            Container(
                                              margin: const EdgeInsets.symmetric(horizontal: 8),
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white,
                                                    Colors.grey[50]!,
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.circular(24),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black.withOpacity(0.15),
                                                    blurRadius: 25,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 15),
                                                  ),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                children: [
                                                  _buildEnhancedQuickStat(
                                                    'Total',
                                                    '${_allReminders.length}',
                                                    Icons.medication_liquid_rounded,
                                                    ThemeConstants.primaryColor,
                                                  ),
                                                  Container(
                                                    width: 1,
                                                    height: 50,
                                                    color: Colors.grey[300],
                                                  ),
                                                  _buildEnhancedQuickStat(
                                                    'Completed',
                                                    '${_allReminders.isEmpty ? 0 : ((_allReminders.length - _upcomingReminders.length) / _allReminders.length * 100).toStringAsFixed(0)}%',
                                                    Icons.check_circle_rounded,
                                                    Colors.green[600]!,
                                                  ),
                                                  Container(
                                                    width: 1,
                                                    height: 50,
                                                    color: Colors.grey[300],
                                                  ),
                                                  _buildEnhancedQuickStat(
                                                    'Upcoming',
                                                    '${_upcomingReminders.length}',
                                                    Icons.schedule_rounded,
                                                    Colors.orange[600]!,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        
                                        const SizedBox(height: 30),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),                            // Enhanced Information Section
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Personal Information Section
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: ThemeConstants.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(
                                            Icons.person_rounded,
                                            color: ThemeConstants.primaryColor,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Personal Information',
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Enhanced Info Cards
                                  _buildEnhancedInfoCard(
                                    icon: Icons.phone_rounded,
                                    title: 'Phone Number',
                                    value: "+918178703402",
                                    color: Colors.green[600]!,
                                  ),
                                  _buildEnhancedInfoCard(
                                    icon: Icons.cake_rounded,
                                    title: 'Date of Birth',
                                    value: "18 May 2025",
                                    color: Colors.purple[600]!,
                                  ),
                                  _buildEnhancedInfoCard(
                                    icon: Icons.person_pin_rounded,
                                    title: 'Gender',
                                    value: "Neutral",
                                    color: Colors.blue[600]!,
                                  ),
                                  
                                  const SizedBox(height: 32),
                                  
                                  // Enhanced Prescription Header
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: ThemeConstants.primaryColor.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.medication_liquid_rounded,
                                                color: ThemeConstants.primaryColor,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Prescription Details',
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ThemeConstants.primaryColor.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.refresh_rounded,
                                              color: ThemeConstants.primaryColor,
                                            ),
                                            onPressed: () {
                                              _fetchUserData();
                                              _fetchReminders();
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),                                  // Enhanced Prescription Cards
                                  if (userData?['prescriptions'] != null &&
                                      (userData!['prescriptions'] as List).isNotEmpty)
                                    Column(
                                      children: (userData!['prescriptions'] as List)
                                          .map(
                                            (prescription) => _buildEnhancedPrescriptionCard(
                                              medicineId: prescription['medicine_id'],
                                              medicineName: prescription['medicine_name'],
                                              presId: prescription['pres_id'],
                                              recommendedDosage: prescription['recommended_dosage'],
                                              sideEffects: prescription['side_effects'],
                                              frequency: prescription['frequency'],
                                              expiryDate: prescription['expiry_date'],
                                            ),
                                          )
                                          .toList(),
                                    )
                                  else
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 20),
                                      padding: const EdgeInsets.all(40),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.grey[50]!,
                                            Colors.grey[100]!,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.grey[300]!,
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[200],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.medication_outlined,
                                              size: 48,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No Prescriptions Found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Add your first prescription to get started with medication tracking',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 100), // Space for FAB
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                if (_showNotificationsDropdown) _buildNotificationsDropdown(),
                
                // Enhanced Swipe Indicator
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: AnimatedBuilder(
                    animation: _swipeIndicatorController,
                    builder: (context, child) {
                      final animationValue = (_swipeIndicatorController.value * 0.7) + 0.3;
                      
                      return Opacity(
                        opacity: _isDragging ? 1.0 : animationValue,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _isDragging 
                                  ? [ThemeConstants.primaryColor, ThemeConstants.primaryColor.withOpacity(0.8)]
                                  : [Colors.black87, Colors.black54],
                            ),
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isDragging ? 'Release to view logs' : 'Swipe left for logs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Transform.translate(
                                offset: Offset(
                                  _isDragging 
                                      ? _dragOffset * 0.05 
                                      : animationValue * 4, 
                                  0
                                ),
                                child: Icon(
                                  _isDragging ? Icons.touch_app_rounded : Icons.arrow_back_ios_rounded,
                                  color: Colors.white,
                                  size: 14,
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
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: ThemeConstants.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddPrescriptionScreen(
                  username: widget.username,
                  password: widget.password,
                  userId: userData?['user_id'] ?? '',
                ),
              ),
            );
            if (result == true) {
              _fetchUserData();
            }
          },
          backgroundColor: ThemeConstants.primaryColor,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
          label: const Text(
            'Add Prescription',
            style: TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
  // Navigate to medication logs with smooth transition
  void _navigateToMedicationLogs() {
    // Add haptic feedback for better UX
    HapticFeedback.lightImpact();
    
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const MedicationLogsScreen(),
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Combined slide and fade transition
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var slideTween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          var fadeTween = Tween(begin: 0.0, end: 1.0).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: ThemeConstants.primaryColor, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsDropdown() {
    return Positioned(
      right: 16,
      top: kToolbarHeight - 50,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ThemeConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ThemeConstants.primaryColor.withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.notifications,
                        color: ThemeConstants.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Completed Reminders',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: ThemeConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),

              // Reminders list
              if (_completedReminders.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'No completed reminders yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: _completedReminders.length,
                    itemBuilder: (context, index) {
                      final reminder = _completedReminders[index];
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  ThemeConstants.primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: ThemeConstants.primaryColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            reminder['medicine'],
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Taken at ${reminder['time'].format(context)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.grey[500],
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _completedReminders.removeAt(index);
                              });
                            },
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
    );
  }

  Widget _buildPeriodButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? ThemeConstants.primaryColor 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected 
                ? ThemeConstants.primaryColor 
                : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
  Widget _buildPrescriptionCard({
    required String medicineId,
    required String medicineName,
    required String presId,
    required String recommendedDosage,
    required String sideEffects,
    required int frequency,
    required String expiryDate,
  }) {
    // Check if medicine is expired
    bool isExpired = false;
    try {
      final parts = expiryDate.split('-');
      if (parts.length == 3) {
        const months = {
          'Jan': 1,
          'Feb': 2,
          'Mar': 3,
          'Apr': 4,
          'May': 5,
          'Jun': 6,
          'Jul': 7,
          'Aug': 8,
          'Sep': 9,
          'Oct': 10,
          'Nov': 11,
          'Dec': 12
        };
        final expiryDateTime = DateTime(
          int.parse(parts[2]), // year
          int.parse(parts[1]), // month
          int.parse(parts[0]), // day
        );
        final today = DateTime.now();
        isExpired = expiryDateTime
            .isBefore(DateTime(today.year, today.month, today.day));
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.05) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isExpired
            ? const BorderSide(color: ThemeConstants.secondaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? ThemeConstants.secondaryColor
                            .withOpacity(0.2) // Increased opacity for red
                        : ThemeConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.medication,
                    color: isExpired
                        ? ThemeConstants.secondaryColor.withOpacity(0.7)
                        : ThemeConstants.primaryColor, // Darker red
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,                    
                    children: [
                      Text(
                        medicineName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isExpired
                              ? ThemeConstants.secondaryColor.withOpacity(0.7)
                              : Colors.black, // Darker red
                          decoration: isExpired
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,                        ),
                      ),
                    ],
                  ),
                ),                
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isExpired
                        ? ThemeConstants.secondaryColor.withOpacity(0.2) // Increased opacity
                        : ThemeConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$frequency times/day',
                    style: TextStyle(
                      color: isExpired
                          ? ThemeConstants.secondaryColor.withOpacity(0.7)
                          : ThemeConstants.primaryColor, // Darker red
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button
                GestureDetector(
                  onTap: () => _deletePrescription(presId, medicineName),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: ThemeConstants.secondaryColor.withOpacity(0.6),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            // const SizedBox(height: 16),
            // _buildPrescriptionDetail(
            //   icon: Icons.schedule,
            //   title: 'Dosage',
            //   value: recommendedDosage,
            //   isExpired: isExpired, // Pass the isExpired flag
            // ),
            // const SizedBox(height: 8),            
            // _buildPrescriptionDetail(
            //   icon: Icons.warning_amber_rounded,
            //   title: 'Side Effects',
            //   value: sideEffects,
            //   isExpired: isExpired, // Pass the isExpired flag
            // ),   
            const SizedBox(height: 20),            
            _buildPrescriptionDetail(
              icon: Icons.event_available,
              title: 'Expiry Date : ',
              value: _formatExpiryDate(expiryDate),
              isExpired: isExpired, // Pass the isExpired flag
            ),
            const SizedBox(height: 1),            
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isExpired ? ThemeConstants.secondaryColor.withOpacity(0.7) : ThemeConstants.primaryColor).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.7) : ThemeConstants.primaryColor,
                ),
              ),
              title: Text(
                'Medicine Information',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.7) : Colors.black87,
                ),
              ),
              trailing: Icon(
                Icons.keyboard_arrow_down,
                color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.7) : ThemeConstants.primaryColor,
              ),
              onExpansionChanged: (expanded) async {
                if (expanded && !_medicineInfo.containsKey(presId)) {
                  try {
                    const apiKey = 'AIzaSyDChfe8INK6TpAJgFQ8gVKvSvf1Pgfiu6k';
                    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';
                    final now = DateTime.now();

                    final prompt = """
                      You are a medical assistant. You would be given a medicine name and you have to return the information about the medicine in a valid JSON format.

                      Medicine Name: $medicineName

                      The information should include just the information publically available about the medicine.
                      Incase you have no information available about the medicine, return "Information not available".
                      The information should be in text format and should not include any HTML tags or any other formatting. It should be 50 words in length.

                      # Example Input/Output:
                      Input: Paracetamol
                      Output:
                      {
                          "med_name": "Paracetamol",
                          "info": "Paracetamol is a common pain reliever and fever reducer used for headaches, muscle aches, and minor pain. It's generally safe when used as directed but can cause liver damage in high doses."
                      }
                      """;
                  
                    final headers = {
                      'Content-Type': 'application/json',
                    };

                    final body = json.encode({
                      'contents': [
                        {
                          'parts': [
                            {'text': prompt}
                          ]
                        }
                      ]
                    });

                    final response = await http.post(Uri.parse(url), headers: headers, body: body);
                    
                    if (response.statusCode == 200) {
                      final fullResponse = jsonDecode(response.body) as Map<String, dynamic>;
                      debugPrint('Full API Response: $fullResponse');

                      // Extract the generated content from Gemini API response structure
                      final candidates = fullResponse['candidates'] as List<dynamic>?;
                      if (candidates == null || candidates.isEmpty) {
                        throw Exception('No candidates in response');
                      }

                      final content = candidates[0]['content'] as Map<String, dynamic>?;
                      if (content == null) {
                        throw Exception('No content in response');
                      }

                      final parts = content['parts'] as List<dynamic>?;
                      if (parts == null || parts.isEmpty) {
                        throw Exception('No parts in content');
                      }

                      final text = parts[0]['text'] as String?;
                      if (text == null) {
                        throw Exception('No text in parts');
                      }
                      debugPrint('Extracted text: $text');

                      // Clean the text and extract JSON
                      String cleanedText = text.trim();
                      
                      // Remove markdown code blocks if present
                      if (cleanedText.startsWith('```json')) {
                        cleanedText = cleanedText.substring(7);
                      }
                      if (cleanedText.endsWith('```')) {
                        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
                      }
                      
                      // Remove any leading/trailing whitespace
                      cleanedText = cleanedText.trim();

                      // Parse the extracted JSON
                      final jsonResponse = jsonDecode(cleanedText) as Map<String, dynamic>;
                      debugPrint('Parsed JSON Response: $jsonResponse');
                      setState(() {
                        _medicineInfo[presId] = jsonResponse['info'] ?? 'No information available';
                      });
                    } 
                    return;
                  } catch (e) {
                    print('Error fetching medicine info: $e');
                      setState(() {
                        _medicineInfo[presId] = 'No information available';
                      });
                  } 
                }
              },
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: _medicineInfo.containsKey(presId)
                      ? Container(
                          key: ValueKey('info-$presId'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: (isExpired ? ThemeConstants.secondaryColor.withOpacity(0.01) : Colors.blue[50])?.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: (isExpired ? ThemeConstants.secondaryColor.withOpacity(0.2) : Colors.blue[200])!,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.medical_information,
                                    size: 18,
                                    color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.6) : Colors.blue[600],
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isExpired ? ThemeConstants.secondaryColor : Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _medicineInfo[presId]!,
                                style: TextStyle(
                                  color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.7) : Colors.black87,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          key: ValueKey('loading-$presId'),
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                          child: Column(
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isExpired ? ThemeConstants.secondaryColor.withOpacity(0.6) : ThemeConstants.primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Fetching medicine information...',
                                style: TextStyle(
                                  color: isExpired ? ThemeConstants.secondaryColor.withOpacity(0.6) : ThemeConstants.primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (isExpired) {
                    // Keep existing delete logic
                    try {
                      final response = await http.delete(
                        Uri.parse('$baseUrl/delete-prescriptions'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({
                          'user_id': userData?['user_id'],
                          'pres_id': presId,
                        }),
                      );
                      _fetchUserData();
                      // ... (keep existing delete handling code)
                    } catch (e) {
                      // ... (keep existing error handling)
                    }
                  } else {
                    int selectedHour = TimeOfDay.now().hour;
                    int selectedMinute = TimeOfDay.now().minute;
                    bool isPM = TimeOfDay.now().period == DayPeriod.pm;
                    final existingReminders = await NotiService()
                        .getScheduledTimesForMedicine(medicineName);
                    List<TimeOfDay> scheduledTimes = [...existingReminders];
                    List<int> notificationIds = existingReminders
                        .map((time) =>
                            '$presId-${time.hour}-${time.minute}'.hashCode)
                        .toList();

                    await showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'Set Reminder Times',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: ThemeConstants.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 24),

                                    // Display scheduled times
                                    if (scheduledTimes.isNotEmpty) ...[
                                      const Text(
                                        'Current Reminders:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Column(
                                        children: scheduledTimes.map((time) {
                                          final index =
                                              scheduledTimes.indexOf(time);
                                          return ListTile(
                                            leading: const Icon(
                                                Icons.notifications,
                                                color: ThemeConstants
                                                    .primaryColor),
                                            title: Text(time.format(context)),
                                            trailing: IconButton(
                                              icon: const Icon(Icons.cancel,
                                                  color: ThemeConstants.secondaryColor),
                                              onPressed: () async {
                                                await NotiService()
                                                    .cancelNotification(
                                                        notificationIds[index]);
                                                setState(() {
                                                  scheduledTimes
                                                      .removeAt(index);
                                                  notificationIds
                                                      .removeAt(index);
                                                });
                                              },
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                      const Divider(),
                                    ],
                                    // Add Time button - opens time picker modal
                                    ElevatedButton(
                                      onPressed: () async {                                        final time =
                                            await showDialog<TimeOfDay>(
                                          context: context,
                                          builder: (context) {
                                            int tempHour = selectedHour;
                                            int tempMinute = selectedMinute;
                                            bool tempIsPM = isPM;

                                            return StatefulBuilder(
                                              builder: (context, setTimeState) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(20),
                                                  ),
                                                  child: Container(
                                                    padding:
                                                    const EdgeInsets.all(24),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text(
                                                      'Select Time',
                                                      style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),

                                                    // Your custom time picker UI
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[50],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(16),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: ThemeConstants
                                                                .primaryColor
                                                                .withOpacity(
                                                                    0.05),
                                                            blurRadius: 10,
                                                            spreadRadius: 2,
                                                          ),
                                                        ],
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 16),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          // Hour picker
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'Hour',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              SizedBox(
                                                                height: 150,
                                                                width: 80,
                                                                child: // Hour Picker
// HOUR PICKER
                                                                    ListWheelScrollView
                                                                        .useDelegate(
                                                                  itemExtent:
                                                                      60,
                                                                  perspective:
                                                                      0.003,
                                                                  diameterRatio:
                                                                      2.0, // Makes the wheel appear flatter
                                                                  physics:
                                                                      const FixedExtentScrollPhysics(),                                                                  onSelectedItemChanged:
                                                                      (index) {
                                                                    setTimeState(() =>
                                                                        tempHour =
                                                                            index +
                                                                                1);
                                                                  },
                                                                  childDelegate:
                                                                      ListWheelChildBuilderDelegate(
                                                                    childCount:
                                                                        12,
                                                                    builder:
                                                                        (context,
                                                                            index) {
                                                                      final isCentered =
                                                                          tempHour ==
                                                                              index + 1;                                                                      return Container(
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color: isCentered
                                                                              ? ThemeConstants.primaryColor.withOpacity(0.1)
                                                                              : Colors.transparent,
                                                                          borderRadius:
                                                                              BorderRadius.circular(12),
                                                                          border: isCentered
                                                                              ? Border.all(
                                                                                  color: ThemeConstants.primaryColor,
                                                                                  width: 2,
                                                                                )
                                                                              : null,
                                                                        ),
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              Text(
                                                                            '${index + 1}'.padLeft(2,
                                                                                '0'),
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 24,
                                                                              fontWeight: isCentered ? FontWeight.bold : FontWeight.normal,
                                                                              color: isCentered ? ThemeConstants.primaryColor : Colors.grey.shade600,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          Container(
                                                            height: 100,
                                                            width: 1,
                                                            color: Colors
                                                                .grey[300],
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          // Minute picker
                                                          Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Text(
                                                                'Minute',
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                          .grey[
                                                                      600],
                                                                  fontSize: 16,
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                              SizedBox(
                                                                  height: 150,
                                                                  width: 80,
                                                                  child: ListWheelScrollView
                                                                      .useDelegate(
                                                                    itemExtent:
                                                                        60,
                                                                    diameterRatio:
                                                                        2.0,
                                                                    physics:
                                                                        const FixedExtentScrollPhysics(),                                                                    onSelectedItemChanged:
                                                                        (index) {
                                                                      setTimeState(() =>
                                                                          tempMinute =
                                                                              index * 5);
                                                                    },
                                                                    childDelegate:
                                                                        ListWheelChildBuilderDelegate(
                                                                      childCount:
                                                                          12,
                                                                      builder:
                                                                          (context,
                                                                              index) {
                                                                        final minuteValue =
                                                                            index *
                                                                                5;
                                                                        final isCentered =
                                                                            tempMinute ==
                                                                                minuteValue;                                                                        return Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color: isCentered
                                                                                ? ThemeConstants.primaryColor.withOpacity(0.1)
                                                                                : Colors.transparent,
                                                                            borderRadius:
                                                                                BorderRadius.circular(12),
                                                                            border: isCentered
                                                                                ? Border.all(
                                                                                    color: ThemeConstants.primaryColor,
                                                                                    width: 2,
                                                                                  )
                                                                                : null,
                                                                          ),
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                Text(
                                                                              minuteValue.toString().padLeft(2, '0'),
                                                                              style: TextStyle(
                                                                                fontSize: 24,
                                                                                fontWeight: isCentered ? FontWeight.bold : FontWeight.normal,
                                                                                color: isCentered ? ThemeConstants.primaryColor : Colors.grey.shade600,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  )),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    // AM/PM selector
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[100],
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [                                                          
                                                          _buildPeriodButton(
                                                            label: 'AM',
                                                            isSelected:
                                                                !tempIsPM,
                                                            onTap: () =>
                                                                setTimeState(() =>
                                                                    tempIsPM =
                                                                        false),
                                                          ),
                                                          const SizedBox(
                                                              width: 8),
                                                          _buildPeriodButton(
                                                            label: 'PM',
                                                            isSelected:
                                                                tempIsPM,
                                                            onTap: () =>
                                                                setTimeState(() =>
                                                                    tempIsPM =
                                                                        true),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 24),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: const Text(
                                                              'Cancel'),
                                                        ),
                                                        const SizedBox(
                                                            width: 16),
                                                        ElevatedButton(
                                                          onPressed: () {
                                                            final hour = tempIsPM
                                                                ? (tempHour ==
                                                                        12
                                                                    ? 12
                                                                    : tempHour +
                                                                        12)
                                                                : (tempHour ==
                                                                        12
                                                                    ? 0
                                                                    : tempHour);
                                                            Navigator.pop(
                                                                context,
                                                                TimeOfDay(
                                                                  hour: hour,
                                                                  minute:
                                                                      tempMinute,
                                                                ));
                                                          },
                                                          style: ElevatedButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                ThemeConstants
                                                                    .primaryColor,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                            ),
                                                          ),
                                                          child: const Text(
                                                            'Confirm',
                                                            style:
                                                                TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                              },
                                            );
                                          },
                                        );

                                        if (time != null &&
                                            !scheduledTimes.contains(time)) {
                                          setState(() {
                                            scheduledTimes.add(time);
                                            notificationIds.add(
                                                '$presId-${time.hour}-${time.minute}'
                                                    .hashCode);
                                          });
                                        }
                                      },
                                      style: ButtonStyle(
                                        backgroundColor: WidgetStateProperty
                                            .resolveWith<Color>((states) {
                                          if (states
                                              .contains(WidgetState.pressed)) {
                                            return ThemeConstants.primaryColor
                                                .withOpacity(
                                                    0.2); // 20% darker when pressed
                                          }
                                          return ThemeConstants.primaryColor
                                              .withOpacity(
                                                  0.1); // Default 10% opacity
                                        }),
                                        foregroundColor:
                                            WidgetStateProperty.all(
                                                ThemeConstants.primaryColor),
                                        elevation: WidgetStateProperty.all(
                                            0), // No shadow ever
                                        padding: WidgetStateProperty.all(
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 14),
                                        ),
                                        shape: WidgetStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            side: BorderSide(
                                              color: ThemeConstants.primaryColor
                                                  .withOpacity(0.3),
                                              width: 1,
                                            ),
                                          ),
                                        ),
                                        overlayColor: WidgetStateProperty.all(Colors
                                            .transparent), // Disable ripple effect
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.add, size: 20),
                                          SizedBox(width: 10),
                                          Text(
                                            'Add Time',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // Action buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (scheduledTimes.isNotEmpty) {
                                              for (int i = 0;
                                                  i < scheduledTimes.length;
                                                  i++) {
                                                await NotiService()
                                                    .scheduleNotification(
                                                  id: notificationIds[i],
                                                  title: 'Medicine Reminder',
                                                  body:
                                                      'Time to take $medicineName',
                                                  hour: scheduledTimes[i].hour,
                                                  minute:
                                                      scheduledTimes[i].minute,
                                                );
                                              }
                                              Navigator.pop(
                                                  context, scheduledTimes);
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Please add at least one time'),
                                                ),
                                              );
                                            }
                                            _fetchReminders();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                ThemeConstants.primaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Save',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                ),
                child: Text(
                  isExpired ? 'Delete Prescription' : 'Set Reminders',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _formatExpiryDate(String expiryDate) {
    try {
      // Parse the date string from "dd-mm-yyyy" format
      List<String> parts = expiryDate.split('-');
      if (parts.length != 3) {
        return expiryDate; // Return original if format is unexpected
      }
      
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      
      // Create DateTime object
      DateTime date = DateTime(year, month, day);
      
      // Format to "dd mmm yyyy" format
      List<String> months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      
      String formattedDay = day.toString().padLeft(2, '0');
      String monthName = months[month - 1];
      String formattedYear = year.toString();
      
      return '$formattedDay $monthName $formattedYear';
    } catch (e) {
      // If parsing fails, return the original value
      return expiryDate;
    }
  }
  
  Widget _buildPrescriptionDetail({
  required IconData icon,
  required String title,
  required String value,
  required bool isExpired,
}) {
  String displayValue = value;
  String daysRemaining = '';
  Color? textColor = isExpired ? ThemeConstants.secondaryColor : Colors.grey[600];
  Color? iconColor = isExpired ? ThemeConstants.secondaryColor : Colors.grey[600];

  if (title == 'Expiry Date : ' && value.isNotEmpty) {
    try {
      final parts = value.split(' ');
      if (parts.length == 3) {
        const months = {
          'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
          'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
        };
        displayValue = value;

        final expiryDateTime = DateTime(
          int.parse(parts[2]),
          months[parts[1]] ?? 1,
          int.parse(parts[0]),
        );
        final daysLeft = expiryDateTime.difference(DateTime.now()).inDays;

        if (daysLeft < 0) {
          daysRemaining = 'EXPIRED';
          textColor = ThemeConstants.secondaryColor;
        } else {
          daysRemaining = '$daysLeft days remaining';
          textColor = daysLeft < 30 ? Colors.orange : Colors.grey[600];
        }
      }
    } catch (e) {
      debugPrint('Error parsing date: $e');
    }
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: (isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? ThemeConstants.secondaryColor : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              if (daysRemaining.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                          color: isExpired
                          ? ThemeConstants.secondaryColor.withOpacity(0.1)
                          : (daysRemaining.contains('days remaining') && int.tryParse(daysRemaining.split(' ')[0]) != null && int.parse(daysRemaining.split(' ')[0]) < 30
                              ? Colors.orange[100]
                              : Colors.green[100]),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      daysRemaining,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isExpired ? ThemeConstants.secondaryColor
                            : (daysRemaining.contains('days remaining') && int.tryParse(daysRemaining.split(' ')[0]) != null && int.parse(daysRemaining.split(' ')[0]) < 30
                                ? Colors.orange[700]
                                : Colors.green[700]),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

  // Enhanced helper methods for modern UI
Widget _buildEnhancedQuickStat(String label, String value, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            // gradient: LinearGradient(
            //   colors: [
            //     color.withOpacity(0.2),
            //     color.withOpacity(0.1),
            //   ],
            // ),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 10),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}


Widget _buildEnhancedInfoCard({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 15,
          spreadRadius: 1,
          offset: const Offset(0, 5),
        ),
      ],
      border: Border.all(
        color: color.withOpacity(0.2),
        width: 1,
      ),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.3),
                color.withOpacity(0.1),
              ],
            ),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: color.withOpacity(0.5),
          size: 24,
        ),
      ],
    ),
  );
}


  Widget _buildEnhancedPrescriptionCard({
  required String medicineId,
  required String medicineName,
  required String presId,
  required String recommendedDosage,
  required String sideEffects,
  required int frequency,
  required String expiryDate,
}) {
  bool isExpired = false;
  try {
    final parts = expiryDate.split('-');
    if (parts.length == 3) {
      final expiryDateTime = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0]),
      );
      final today = DateTime.now();
      isExpired = expiryDateTime.isBefore(DateTime(today.year, today.month, today.day));
    }
  } catch (e) {
    print('Error parsing date: $e');
  }

  return Container(
    margin: const EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: isExpired 
              ? ThemeConstants.secondaryColor.withOpacity(0.1)
              : ThemeConstants.primaryColor.withOpacity(0.1),
          blurRadius: 15,
          spreadRadius: 0,
          offset: const Offset(0, 5),
        ),
      ],
      border: Border.all(
        color: isExpired
            ? ThemeConstants.secondaryColor.withOpacity(0.3)
            : ThemeConstants.primaryColor.withOpacity(0.2),
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: isExpired
                              ? [
                                  ThemeConstants.secondaryColor.withOpacity(0.2),
                                  ThemeConstants.secondaryColor.withOpacity(0.1),
                                ]
                              : [
                                  ThemeConstants.primaryColor.withOpacity(0.2),
                                  ThemeConstants.primaryColor.withOpacity(0.1),
                                ],
                        ),
                      ),
                      child: Icon(
                        Icons.medication_liquid_rounded,
                        color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicineName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isExpired ? ThemeConstants.secondaryColor : Colors.black87,
                              decoration: isExpired ? TextDecoration.lineThrough : TextDecoration.none,
                            ),
                          ),
                          if (isExpired)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Expired',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ThemeConstants.secondaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isExpired
                                  ? ThemeConstants.secondaryColor.withOpacity(0.1)
                                  : ThemeConstants.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$frequency/day',
                              style: TextStyle(
                                color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Delete button
                          GestureDetector(
                            onTap: () => _deletePrescription(presId, medicineName),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ThemeConstants.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.delete_outline_rounded,
                                color: ThemeConstants.secondaryColor.withOpacity(0.7),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildPrescriptionDetail(
                  icon: Icons.event_available,
                  title: 'Expiry Date : ',
                  value: _formatExpiryDate(expiryDate),
                  isExpired: isExpired,
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  childrenPadding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                    ),
                  ),
                  title: Text(
                    'Medicine Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isExpired ? ThemeConstants.secondaryColor : Colors.black87,
                    ),
                  ),
                  trailing: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                  ),
                  onExpansionChanged: (expanded) async {
                if (expanded && !_medicineInfo.containsKey(presId)) {
                  try {
                    const apiKey = 'AIzaSyDChfe8INK6TpAJgFQ8gVKvSvf1Pgfiu6k';
                    const url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey';
                    final now = DateTime.now();

                    final prompt = """
                      You are a medical assistant. You would be given a medicine name and you have to return the information about the medicine in a valid JSON format.

                      Medicine Name: $medicineName

                      The information should include just the information publically available about the medicine.
                      Incase you have no information available about the medicine, return "Information not available".
                      The information should be in text format and should not include any HTML tags or any other formatting. It should be 50 words in length.

                      # Example Input/Output:
                      Input: Paracetamol
                      Output:
                      {
                          "med_name": "Paracetamol",
                          "info": "Paracetamol is a common pain reliever and fever reducer used for headaches, muscle aches, and minor pain. It's generally safe when used as directed but can cause liver damage in high doses."
                      }
                      """;
                  
                    final headers = {
                      'Content-Type': 'application/json',
                    };

                    final body = json.encode({
                      'contents': [
                        {
                          'parts': [
                            {'text': prompt}
                          ]
                        }
                      ]
                    });

                    final response = await http.post(Uri.parse(url), headers: headers, body: body);
                    
                    if (response.statusCode == 200) {
                      final fullResponse = jsonDecode(response.body) as Map<String, dynamic>;
                      debugPrint('Full API Response: $fullResponse');

                      // Extract the generated content from Gemini API response structure
                      final candidates = fullResponse['candidates'] as List<dynamic>?;
                      if (candidates == null || candidates.isEmpty) {
                        throw Exception('No candidates in response');
                      }

                      final content = candidates[0]['content'] as Map<String, dynamic>?;
                      if (content == null) {
                        throw Exception('No content in response');
                      }

                      final parts = content['parts'] as List<dynamic>?;
                      if (parts == null || parts.isEmpty) {
                        throw Exception('No parts in content');
                      }

                      final text = parts[0]['text'] as String?;
                      if (text == null) {
                        throw Exception('No text in parts');
                      }
                      debugPrint('Extracted text: $text');

                      // Clean the text and extract JSON
                      String cleanedText = text.trim();
                      
                      // Remove markdown code blocks if present
                      if (cleanedText.startsWith('```json')) {
                        cleanedText = cleanedText.substring(7);
                      }
                      if (cleanedText.endsWith('```')) {
                        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
                      }
                      
                      // Remove any leading/trailing whitespace
                      cleanedText = cleanedText.trim();

                      // Parse the extracted JSON
                      final jsonResponse = jsonDecode(cleanedText) as Map<String, dynamic>;
                      debugPrint('Parsed JSON Response: $jsonResponse');
                      setState(() {
                        _medicineInfo[presId] = jsonResponse['info'] ?? 'No information available';
                      });
                    } 
                    return;
                  } catch (e) {
                    print('Error fetching medicine info: $e');
                      setState(() {
                        _medicineInfo[presId] = 'No information available';
                      });
                  } 
                }
              },
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _medicineInfo.containsKey(presId)
                          ? Container(
                              key: ValueKey('info-$presId'),
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.medical_information_rounded,
                                        size: 18,
                                        color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Details',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _medicineInfo[presId]!,
                                    style: TextStyle(
                                      color: Colors.grey[800],
                                      fontSize: 14,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              key: ValueKey('loading-$presId'),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Loading information...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isExpired ? ThemeConstants.secondaryColor : ThemeConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (isExpired) {
                        try {
                          final response = await http.delete(
                            Uri.parse('$baseUrl/delete-prescriptions'),
                            headers: {'Content-Type': 'application/json'},
                            body: jsonEncode({
                              'user_id': userData?['user_id'],
                              'pres_id': presId,
                            }),
                          );
                          _fetchUserData();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error deleting prescription: $e'),
                            ),
                          );
                        }
                      } else {
                        int selectedHour = TimeOfDay.now().hour;
                        int selectedMinute = TimeOfDay.now().minute;
                        bool isPM = TimeOfDay.now().period == DayPeriod.pm;
                        final existingReminders = await NotiService()
                            .getScheduledTimesForMedicine(medicineName);
                        List<TimeOfDay> scheduledTimes = [...existingReminders];
                        List<int> notificationIds = existingReminders
                            .map((time) =>
                                '$presId-${time.hour}-${time.minute}'.hashCode)
                            .toList();

                        await showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setState) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'Set Reminder Times',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        // Timer roller (unchanged)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              height: 120,
                                              width: 60,
                                              child: ListWheelScrollView.useDelegate(
                                                itemExtent: 40,
                                                physics: const FixedExtentScrollPhysics(),
                                                onSelectedItemChanged: (index) {
                                                  setState(() {
                                                    selectedHour = index + 1;
                                                  });
                                                },
                                                childDelegate: ListWheelChildBuilderDelegate(
                                                  builder: (context, index) {
                                                    if (index < 0 || index >= 12) return null;
                                                    return Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: (index + 1) == selectedHour
                                                              ? ThemeConstants.primaryColor
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  childCount: 12,
                                                ),
                                              ),
                                            ),
                                            const Text(':', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                            SizedBox(
                                              height: 120,
                                              width: 60,
                                              child: ListWheelScrollView.useDelegate(
                                                itemExtent: 40,
                                                physics: const FixedExtentScrollPhysics(),
                                                onSelectedItemChanged: (index) {
                                                  setState(() {
                                                    selectedMinute = index;
                                                  });
                                                },
                                                childDelegate: ListWheelChildBuilderDelegate(
                                                  builder: (context, index) {
                                                    if (index < 0 || index >= 60) return null;
                                                    return Center(
                                                      child: Text(
                                                        index.toString().padLeft(2, '0'),
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                          color: index == selectedMinute
                                                              ? ThemeConstants.primaryColor
                                                              : Colors.grey,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  childCount: 60,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 20),
                                            Column(
                                              children: [
                                                GestureDetector(
                                                  onTap: () => setState(() => isPM = false),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: !isPM ? ThemeConstants.primaryColor : Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text('AM', style: TextStyle(
                                                      color: !isPM ? Colors.white : Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                GestureDetector(
                                                  onTap: () => setState(() => isPM = true),
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: isPM ? ThemeConstants.primaryColor : Colors.grey[200],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text('PM', style: TextStyle(
                                                      color: isPM ? Colors.white : Colors.black,
                                                      fontWeight: FontWeight.bold,
                                                    )),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 30),
                                        if (scheduledTimes.isNotEmpty) ...[
                                          const Text('Scheduled Times:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                          const SizedBox(height: 10),
                                          SizedBox(
                                            height: 60,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: scheduledTimes.length,
                                              itemBuilder: (context, index) {
                                                final time = scheduledTimes[index];
                                                return Container(
                                                  margin: const EdgeInsets.only(right: 8),
                                                  child: Chip(
                                                    label: Text(time.format(context)),
                                                    deleteIcon: const Icon(Icons.close, size: 18),
                                                    onDeleted: () async {
                                                      await NotiService().cancelNotification(notificationIds[index]);
                                                      setState(() {
                                                        scheduledTimes.removeAt(index);
                                                        notificationIds.removeAt(index);
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                        ],
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () async {
                                                  final actualHour = isPM
                                                      ? (selectedHour == 12 ? 12 : selectedHour + 12)
                                                      : (selectedHour == 12 ? 0 : selectedHour);
                                                  final newTime = TimeOfDay(hour: actualHour, minute: selectedMinute);
                                                  final notificationId = '$presId-${newTime.hour}-${newTime.minute}'.hashCode;
                                                  await NotiService().scheduleNotification(
                                                    id: notificationId,
                                                    title: 'Medication Reminder',
                                                    body: 'Time to take your $medicineName',
                                                    hour: newTime.hour,
                                                    minute: newTime.minute,
                                                  );
                                                  setState(() {
                                                    scheduledTimes.add(newTime);
                                                    notificationIds.add(notificationId);
                                                  });
                                                },
                                                child: const Text('Add Time'),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                  _fetchReminders();
                                                },
                                                style: ElevatedButton.styleFrom(backgroundColor: ThemeConstants.primaryColor),
                                                child: const Text('Done', style: TextStyle(color: Colors.white)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                    child: Text(
                      isExpired ? 'Remove Expired Medicine' : 'Set Reminder',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: ThemeConstants.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
