import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DataStorageService {
  static const String _dataKey = 'medical_data';

  // Default data structure
  static const Map<String, dynamic> _defaultData = {
    'medicines': [],
    'prescriptions': [],
  };

  // Private helper method to get SharedPreferences instance
  static Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  // Private helper method to validate data structure
  static Map<String, dynamic> _validateData(Map<String, dynamic> data) {
    data['medicines'] ??= [];
    data['prescriptions'] ??= [];
    
    // Ensure both are lists
    if (data['medicines'] is! List) data['medicines'] = [];
    if (data['prescriptions'] is! List) data['prescriptions'] = [];
    
    return data;
  }

  /// Save the entire medical data (medicines and prescriptions)
  static Future<bool> saveData(Map<String, dynamic> data) async {
    try {
      final prefs = await _getPrefs();
      final validatedData = _validateData(data);
      final jsonString = jsonEncode(validatedData);
      await prefs.setString(_dataKey, jsonString);
      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }

  /// Get the entire medical data
  static Future<Map<String, dynamic>> getData() async {
    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(_dataKey);
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final data = jsonDecode(jsonString) as Map<String, dynamic>;
        return _validateData(data);
      }
    } catch (e) {
      print('Error getting data: $e');
    }
    return Map<String, dynamic>.from(_defaultData);
  }

  // ==================== MEDICINES OPERATIONS ====================

  /// Get only medicines list
  static Future<List<dynamic>> getMedicines() async {
    try {
      final data = await getData();
      return List<dynamic>.from(data['medicines']);
    } catch (e) {
      print('Error getting medicines: $e');
      return [];
    }
  }

  /// Save medicines array (replaces entire medicines array)
  static Future<bool> saveMedicines(List<dynamic> medicines) async {
    try {
      final data = await getData();
      data['medicines'] = List<dynamic>.from(medicines);
      return await saveData(data);
    } catch (e) {
      print('Error saving medicines: $e');
      return false;
    }
  }

  /// Add a single medicine
  static Future<bool> addMedicine(Map<String, dynamic> medicine) async {
    try {
      final data = await getData();
      final medicines = List<dynamic>.from(data['medicines']);
      medicines.add(medicine);
      data['medicines'] = medicines;
      return await saveData(data);
    } catch (e) {
      print('Error adding medicine: $e');
      return false;
    }
  }

  /// Add multiple medicines at once
  static Future<bool> addMedicines(List<Map<String, dynamic>> newMedicines) async {
    try {
      final data = await getData();
      final medicines = List<dynamic>.from(data['medicines']);
      medicines.addAll(newMedicines);
      data['medicines'] = medicines;
      return await saveData(data);
    } catch (e) {
      print('Error adding medicines: $e');
      return false;
    }
  }

  /// Update a medicine by index
  static Future<bool> updateMedicine(int index, Map<String, dynamic> medicine) async {
    try {
      final data = await getData();
      final medicines = List<dynamic>.from(data['medicines']);
      if (index >= 0 && index < medicines.length) {
        medicines[index] = medicine;
        data['medicines'] = medicines;
        return await saveData(data);
      }
      return false;
    } catch (e) {
      print('Error updating medicine: $e');
      return false;
    }
  }

  /// Remove a medicine by index
  static Future<bool> removeMedicine(int index) async {
    try {
      final data = await getData();
      final medicines = List<dynamic>.from(data['medicines']);
      if (index >= 0 && index < medicines.length) {
        medicines.removeAt(index);
        data['medicines'] = medicines;
        return await saveData(data);
      }
      return false;
    } catch (e) {
      print('Error removing medicine: $e');
      return false;
    }
  }

  /// Clear all medicines
  static Future<bool> clearMedicines() async {
    try {
      final data = await getData();
      data['medicines'] = [];
      return await saveData(data);
    } catch (e) {
      print('Error clearing medicines: $e');
      return false;
    }
  }

  /// Find medicine by name
  static Future<Map<String, dynamic>?> findMedicineByName(String name) async {
    try {
      final medicines = await getMedicines();
      for (final medicine in medicines) {
        if (medicine is Map<String, dynamic> && 
            medicine['name']?.toString().toLowerCase() == name.toLowerCase()) {
          return medicine;
        }
      }
    } catch (e) {
      print('Error finding medicine: $e');
    }
    return null;
  }

  /// Get medicines count
  static Future<int> getMedicinesCount() async {
    final medicines = await getMedicines();
    return medicines.length;
  }

  // ==================== PRESCRIPTIONS OPERATIONS ====================

  /// Get only prescriptions list
  static Future<List<dynamic>> getPrescriptions() async {
    try {
      final data = await getData();
      return List<dynamic>.from(data['prescriptions']);
    } catch (e) {
      print('Error getting prescriptions: $e');
      return [];
    }
  }
  static Future<Map<String, String>> getLastPres() async {
    try {
      final data = await getData();
      final prescriptions = List<dynamic>.from(data['prescriptions']);
      
      if (prescriptions.isEmpty) {
        return {"pres_id": "PRSA0001"};
      }
      
      final lastPrescription = prescriptions.last as Map<String, dynamic>;
      
      // Convert to Map<String, String> safely
      return {
        'pres_id': lastPrescription['pres_id']?.toString() ?? "PRESA0001",
      };
    } catch (e) {
      print('Error getting last prescription: $e');
      return {"pres_id": "PRESA0001"};
    }
  }

  /// Save prescriptions array (replaces entire prescriptions array)
  static Future<bool> savePrescriptions(List<dynamic> prescriptions) async {
    try {
      final data = await getData();
      data['prescriptions'] = List<dynamic>.from(prescriptions);
      return await saveData(data);
    } catch (e) {
      print('Error saving prescriptions: $e');
      return false;
    }
  }

  /// Add a single prescription
  static Future<bool> addPrescription(Map<String, dynamic> prescription) async {
    try {
      final data = await getData();
      final prescriptions = List<dynamic>.from(data['prescriptions']);
      prescriptions.add(prescription);
      data['prescriptions'] = prescriptions;
      return await saveData(data);
    } catch (e) {
      print('Error adding prescription: $e');
      return false;
    }
  }

  /// Add multiple prescriptions at once
  static Future<bool> addPrescriptions(List<Map<String, dynamic>> newPrescriptions) async {
    try {
      final data = await getData();
      final prescriptions = List<dynamic>.from(data['prescriptions']);
      prescriptions.addAll(newPrescriptions);
      data['prescriptions'] = prescriptions;
      return await saveData(data);
    } catch (e) {
      print('Error adding prescriptions: $e');
      return false;
    }
  }

  /// Update a prescription by index
  static Future<bool> updatePrescription(int index, Map<String, dynamic> prescription) async {
    try {
      final data = await getData();
      final prescriptions = List<dynamic>.from(data['prescriptions']);
      if (index >= 0 && index < prescriptions.length) {
        prescriptions[index] = prescription;
        data['prescriptions'] = prescriptions;
        return await saveData(data);
      }
      return false;
    } catch (e) {
      print('Error updating prescription: $e');
      return false;
    }
  }

  /// Remove a prescription by index
  static Future<bool> removePrescription(int index) async {
    try {
      final data = await getData();
      final prescriptions = List<dynamic>.from(data['prescriptions']);
      if (index >= 0 && index < prescriptions.length) {
        prescriptions.removeAt(index);
        data['prescriptions'] = prescriptions;
        return await saveData(data);
      }
      return false;
    } catch (e) {
      print('Error removing prescription: $e');
      return false;
    }
  }

  /// Clear all prescriptions
  static Future<bool> clearPrescriptions() async {
    try {
      final data = await getData();
      data['prescriptions'] = [];
      return await saveData(data);
    } catch (e) {
      print('Error clearing prescriptions: $e');
      return false;
    }
  }

  /// Find prescriptions by medicine name
  static Future<List<Map<String, dynamic>>> findPrescriptionsByMedicine(String medicineName) async {
    try {
      final prescriptions = await getPrescriptions();
      final results = <Map<String, dynamic>>[];
      
      for (final prescription in prescriptions) {
        if (prescription is Map<String, dynamic> && 
            prescription['med_name']?.toString().toLowerCase() == medicineName.toLowerCase()) {
          results.add(prescription);
        }
      }
      return results;
    } catch (e) {
      print('Error finding prescriptions: $e');
      return [];
    }
  }

  /// Get prescriptions count
  static Future<int> getPrescriptionsCount() async {
    final prescriptions = await getPrescriptions();
    return prescriptions.length;
  }

  // ==================== UTILITY OPERATIONS ====================

  /// Clear all stored data
  static Future<bool> clearAllData() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(_dataKey);
      return true;
    } catch (e) {
      print('Error clearing all data: $e');
      return false;
    }
  }

  /// Reset to default data structure
  static Future<bool> resetToDefault() async {
    return await saveData(Map<String, dynamic>.from(_defaultData));
  }

  /// Check if data exists
  static Future<bool> hasData() async {
    try {
      final prefs = await _getPrefs();
      return prefs.containsKey(_dataKey);
    } catch (e) {
      print('Error checking data existence: $e');
      return false;
    }
  }

  /// Export data as JSON string (for backup purposes)
  static Future<String> exportDataAsJson() async {
    try {
      final data = await getData();
      return jsonEncode(data);
    } catch (e) {
      print('Error exporting data: $e');
      return jsonEncode(_defaultData);
    }
  }

  /// Import data from JSON string (for restore purposes)
  static Future<bool> importDataFromJson(String jsonString) async {
    try {
      if (jsonString.isEmpty) return false;
      
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // Validate structure
      if (data.containsKey('medicines') && data.containsKey('prescriptions')) {
        return await saveData(data);
      }
      return false;
    } catch (e) {
      print('Error importing data: $e');
      return false;
    }
  }

  /// Get data size in bytes (approximate)
  static Future<int> getDataSize() async {
    try {
      final jsonString = await exportDataAsJson();
      return utf8.encode(jsonString).length;
    } catch (e) {
      print('Error calculating data size: $e');
      return 0;
    }
  }

  /// Get summary of stored data
  static Future<Map<String, int>> getDataSummary() async {
    try {
      final medicinesCount = await getMedicinesCount();
      final prescriptionsCount = await getPrescriptionsCount();
      
      return {
        'medicines': medicinesCount,
        'prescriptions': prescriptionsCount,
        'total': medicinesCount + prescriptionsCount,
      };
    } catch (e) {
      print('Error getting data summary: $e');
      return {'medicines': 0, 'prescriptions': 0, 'total': 0};
    }
  }

  // ==================== ANALYTICS DATA OPERATIONS ====================

  /// Generate and store fake analytics data for testing and demonstration
  static Future<bool> generateFakeAnalyticsData() async {
    try {
      final random = DateTime.now().millisecondsSinceEpoch;
      final baseDate = DateTime.now().subtract(const Duration(days: 30));
      
      // Sample medicine names for variety
      final medicineNames = [
        'Paracetamol', 'Aspirin', 'Vitamin D', 'Omega-3', 'Metformin',
        'Lisinopril', 'Atorvastatin', 'Omeprazole', 'Levothyroxine', 'Ibuprofen'
      ];

      // Generate fake prescriptions
      List<Map<String, dynamic>> fakePrescriptions = [];
      for (int i = 0; i < 8; i++) {
        final medicineIndex = (random + i) % medicineNames.length;
        final expiryDate = DateTime.now().add(Duration(days: 30 + (i * 15)));
        
        fakePrescriptions.add({
          'pres_id': 'FAKE${(1000 + i).toString()}',
          'medicine_id': 'MED${(2000 + i).toString()}',
          'medicine_name': medicineNames[medicineIndex],
          'recommended_dosage': '${1 + (i % 3)} tablet${(1 + (i % 3)) > 1 ? 's' : ''}',
          'side_effects': i % 3 == 0 ? 'Nausea, Dizziness' : i % 3 == 1 ? 'Drowsiness' : 'Headache, Stomach upset',
          'frequency': 1 + (i % 3), // 1-3 times per day
          'expiry_date': '${expiryDate.day.toString().padLeft(2, '0')}-${expiryDate.month.toString().padLeft(2, '0')}-${expiryDate.year}',
          'created_at': baseDate.add(Duration(days: i)).toIso8601String(),
        });
      }

      // Add fake prescriptions to existing ones
      await addPrescriptions(fakePrescriptions);

      // Generate fake medicine intake logs for analytics
      List<Map<String, dynamic>> fakeMedicines = [];
      for (int day = 0; day < 30; day++) {
        final logDate = baseDate.add(Duration(days: day));
        
        // Generate 2-4 medication logs per day
        final logsPerDay = 2 + (day % 3);
        for (int logIndex = 0; logIndex < logsPerDay; logIndex++) {
          final medicineIndex = (day + logIndex) % medicineNames.length;
          final logTime = logDate.add(Duration(
            hours: 8 + (logIndex * 4), // Spread throughout the day
            minutes: (logIndex * 30) % 60,
          ));
          
          // 85% chance of "taken", 15% chance of "forgot"
          final action = (day + logIndex) % 7 == 0 ? 'forgot' : 'taken';
          
          fakeMedicines.add({
            'medicine_id': 'MED${(2000 + medicineIndex).toString()}',
            'medicine_name': medicineNames[medicineIndex],
            'dosage': '${1 + (logIndex % 3)} tablet${(1 + (logIndex % 3)) > 1 ? 's' : ''}',
            'action': action, // 'taken' or 'forgot'
            'actionTime': logTime.toIso8601String(),
            'notes': action == 'taken' 
              ? 'Medication taken as prescribed' 
              : 'Missed due to ${logIndex % 2 == 0 ? 'forgetfulness' : 'being busy'}',
            'timestamp': logTime.millisecondsSinceEpoch,
            'day_of_week': logTime.weekday, // 1 = Monday, 7 = Sunday
            'hour_of_day': logTime.hour,
          });
        }
      }

      // Add fake medicines to existing ones
      await addMedicines(fakeMedicines);

      return true;
    } catch (e) {
      print('Error generating fake analytics data: $e');
      return false;
    }
  }

  /// Get analytics data for charts and reports
  static Future<Map<String, dynamic>> getAnalyticsData() async {
    try {
      final medicines = await getMedicines();
      final prescriptions = await getPrescriptions();
      final now = DateTime.now();
      
      // Calculate adherence statistics
      final takenMedicines = medicines.where((med) => med['action'] == 'taken').toList();
      final forgotMedicines = medicines.where((med) => med['action'] == 'forgot').toList();
      final totalMedicines = medicines.length;
      
      // Weekly adherence data (last 7 days)
      Map<int, Map<String, int>> weeklyData = {};
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dayKey = date.day;
        weeklyData[dayKey] = {'taken': 0, 'forgot': 0};
      }
      
      // Monthly adherence data (last 4 weeks)
      Map<int, Map<String, int>> monthlyData = {};
      for (int i = 3; i >= 0; i--) {
        monthlyData[3 - i] = {'taken': 0, 'forgot': 0};
      }
      
      // Process medication logs
      for (var medicine in medicines) {
        if (medicine['actionTime'] != null) {
          try {
            final actionDate = DateTime.parse(medicine['actionTime']);
            final daysDiff = now.difference(actionDate).inDays;
            
            // Weekly data
            if (daysDiff >= 0 && daysDiff < 7) {
              final dayKey = actionDate.day;
              if (weeklyData.containsKey(dayKey)) {
                weeklyData[dayKey]![medicine['action']] = 
                  (weeklyData[dayKey]![medicine['action']] ?? 0) + 1;
              }
            }
            
            // Monthly data
            final weeksDiff = (daysDiff / 7).floor();
            if (weeksDiff >= 0 && weeksDiff < 4) {
              final weekIndex = 3 - weeksDiff;
              monthlyData[weekIndex]![medicine['action']] = 
                (monthlyData[weekIndex]![medicine['action']] ?? 0) + 1;
            }
          } catch (e) {
            print('Error parsing date: ${medicine['actionTime']}');
          }
        }
      }
      
      // Medicine frequency analysis
      Map<String, int> medicineFrequency = {};
      for (var medicine in medicines) {
        final name = medicine['medicine_name'] ?? 'Unknown';
        medicineFrequency[name] = (medicineFrequency[name] ?? 0) + 1;
      }
      
      // Time-of-day analysis
      Map<String, int> timeOfDayData = {
        'Morning (6-12)': 0,
        'Afternoon (12-18)': 0,
        'Evening (18-24)': 0,
        'Night (0-6)': 0,
      };
      
      for (var medicine in medicines) {
        if (medicine['hour_of_day'] != null) {
          final hour = medicine['hour_of_day'] as int;
          if (hour >= 6 && hour < 12) {
            timeOfDayData['Morning (6-12)'] = (timeOfDayData['Morning (6-12)'] ?? 0) + 1;
          } else if (hour >= 12 && hour < 18) {
            timeOfDayData['Afternoon (12-18)'] = (timeOfDayData['Afternoon (12-18)'] ?? 0) + 1;
          } else if (hour >= 18 && hour < 24) {
            timeOfDayData['Evening (18-24)'] = (timeOfDayData['Evening (18-24)'] ?? 0) + 1;
          } else {
            timeOfDayData['Night (0-6)'] = (timeOfDayData['Night (0-6)'] ?? 0) + 1;
          }
        }
      }
      
      return {
        'summary': {
          'total_medications': totalMedicines,
          'taken_medications': takenMedicines.length,
          'missed_medications': forgotMedicines.length,
          'adherence_rate': totalMedicines > 0 ? ((takenMedicines.length / totalMedicines) * 100).round() : 0,
          'total_prescriptions': prescriptions.length,
        },
        'weekly_data': weeklyData,
        'monthly_data': monthlyData,
        'medicine_frequency': medicineFrequency,
        'time_of_day_analysis': timeOfDayData,
        'recent_medicines': medicines.take(10).toList(),
        'active_prescriptions': prescriptions.where((p) {
          try {
            final parts = p['expiry_date']?.split('-');
            if (parts?.length == 3) {
              final expiryDate = DateTime(
                int.parse(parts[2]), // year
                int.parse(parts[1]), // month  
                int.parse(parts[0]), // day
              );
              return expiryDate.isAfter(now);
            }
          } catch (e) {
            print('Error parsing expiry date: ${p['expiry_date']}');
          }
          return false;
        }).toList(),
        'generated_at': now.toIso8601String(),
      };
    } catch (e) {
      print('Error getting analytics data: $e');
      return {
        'summary': {
          'total_medications': 0,
          'taken_medications': 0,
          'missed_medications': 0,
          'adherence_rate': 0,
          'total_prescriptions': 0,
        },
        'weekly_data': {},
        'monthly_data': {},
        'medicine_frequency': {},
        'time_of_day_analysis': {},
        'recent_medicines': [],
        'active_prescriptions': [],
        'generated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Clear only fake/demo data (keeps real user data)
  static Future<bool> clearFakeData() async {
    try {
      // Remove fake prescriptions (those with FAKE prefix)
      final prescriptions = await getPrescriptions();
      final realPrescriptions = prescriptions.where((p) => 
        !(p['pres_id']?.toString().startsWith('FAKE') ?? false)
      ).toList();
      await savePrescriptions(realPrescriptions);
      
      // Remove fake medicines (those with FAKE or MED2000+ IDs)
      final medicines = await getMedicines();
      final realMedicines = medicines.where((m) => 
        !(m['medicine_id']?.toString().startsWith('MED2') ?? false)
      ).toList();
      await saveMedicines(realMedicines);
      
      return true;
    } catch (e) {
      print('Error clearing fake data: $e');
      return false;
    }
  }

  /// Generate fake adherence data specifically for medical analysis charts
  static Future<bool> generateFakeAdherenceData() async {
    try {
      final random = DateTime.now().millisecondsSinceEpoch;
      final baseDate = DateTime.now().subtract(const Duration(days: 90)); // 3 months of data
      
      // Sample medicine names for adherence tracking
      final medicineNames = [
        'Metformin', 'Lisinopril', 'Atorvastatin', 'Levothyroxine', 
        'Amlodipine', 'Omeprazole', 'Simvastatin', 'Losartan'
      ];

      // Generate comprehensive adherence data
      List<Map<String, dynamic>> adherenceData = [];
      
      // Generate data for the last 90 days
      for (int day = 0; day < 90; day++) {
        final logDate = baseDate.add(Duration(days: day));
        
        // Generate 3-5 medication entries per day (morning, afternoon, evening)
        final entriesPerDay = 3 + (day % 3);
        
        for (int entry = 0; entry < entriesPerDay; entry++) {
          final medicineIndex = (day + entry) % medicineNames.length;
          final medicine = medicineNames[medicineIndex];
          
          // Calculate time of day: morning (8am), afternoon (2pm), evening (8pm)
          final baseHour = entry == 0 ? 8 : entry == 1 ? 14 : 20;
          final logTime = logDate.add(Duration(
            hours: baseHour + (entry % 2), // Add some variation
            minutes: (entry * 15) % 60,
          ));
          
          // Calculate adherence probability based on patterns:
          // - Higher adherence in recent days
          // - Lower adherence on weekends
          // - Declining adherence over time (realistic pattern)
          double adherenceRate = 0.9; // Base 90% adherence
          
          // Recent days have better adherence
          if (day > 60) adherenceRate = 0.95;
          if (day > 80) adherenceRate = 0.98;
          
          // Weekend effect (slightly lower adherence)
          if (logDate.weekday == DateTime.saturday || logDate.weekday == DateTime.sunday) {
            adherenceRate -= 0.1;
          }
          
          // Early morning medications have lower adherence
          if (baseHour == 8) adherenceRate -= 0.05;
          
          // Evening medications have higher adherence
          if (baseHour == 20) adherenceRate += 0.05;
          
          // Add some randomness
          final randomFactor = ((random + day + entry) % 100) / 100.0;
          final action = randomFactor < adherenceRate ? 'taken' : 'forgot';
          
          // Calculate delay for taken medications (realistic scenario)
          int delayMinutes = 0;
          if (action == 'taken') {
            // 70% on time, 20% slightly late, 10% very late
            final delayRandom = ((random + day * entry) % 100) / 100.0;
            if (delayRandom > 0.7 && delayRandom <= 0.9) {
              delayMinutes = 15 + ((random + entry) % 30); // 15-45 min late
            } else if (delayRandom > 0.9) {
              delayMinutes = 60 + ((random + day) % 120); // 1-3 hours late
            }
          }
          
          final actualTime = logTime.add(Duration(minutes: delayMinutes));
          
          adherenceData.add({
            'medicine_id': 'ADHERENCE_${medicine.toUpperCase()}_${day}_$entry',
            'medicine_name': medicine,
            'dosage': entry == 0 ? '1 tablet' : entry == 1 ? '2 tablets' : '1 tablet',
            'action': action,
            'actionTime': actualTime.toIso8601String(),
            'reminderTime': logTime.toIso8601String(),
            'delay_minutes': delayMinutes,
            'notes': action == 'taken' 
              ? delayMinutes == 0 
                ? 'Taken on time' 
                : 'Taken $delayMinutes minutes late'
              : 'Missed - ${_getRandomMissReason(random + day + entry)}',
            'timestamp': actualTime.millisecondsSinceEpoch,
            'day_of_week': logDate.weekday,
            'hour_of_day': actualTime.hour,
            'dose_time': entry == 0 ? 'morning' : entry == 1 ? 'afternoon' : 'evening',
            'adherence_score': action == 'taken' 
              ? delayMinutes == 0 ? 100 : (100 - (delayMinutes / 2)).round()
              : 0,
          });
        }
      }

      // Add fake adherence medicines to existing ones
      await addMedicines(adherenceData);

      return true;
    } catch (e) {
      print('Error generating fake adherence data: $e');
      return false;
    }
  }

  /// Helper method to generate random miss reasons
  static String _getRandomMissReason(int seed) {
    final reasons = [
      'Forgot to take medication',
      'Was not at home',
      'Medicine ran out',
      'Busy with work',
      'Felt better, skipped dose',
      'Side effects concern',
      'Traveling',
      'Overslept',
      'Emergency situation',
      'Meeting conflict'
    ];
    return reasons[seed % reasons.length];
  }

  /// Get detailed adherence analytics for medical analysis
  static Future<Map<String, dynamic>> getAdherenceAnalytics() async {
    try {
      final medicines = await getMedicines();
      final now = DateTime.now();
      
      // Filter adherence data (last 90 days)
      final adherenceData = medicines.where((med) {
        if (med['actionTime'] == null) return false;
        try {
          final actionDate = DateTime.parse(med['actionTime']);
          final daysDiff = now.difference(actionDate).inDays;
          return daysDiff >= 0 && daysDiff <= 90;
        } catch (e) {
          return false;
        }
      }).toList();
      
      if (adherenceData.isEmpty) {
        return _getEmptyAdherenceAnalytics();
      }
      
      // Calculate overall statistics
      final totalDoses = adherenceData.length;
      final takenDoses = adherenceData.where((med) => med['action'] == 'taken').length;
      final missedDoses = adherenceData.where((med) => med['action'] == 'forgot').length;
      final adherenceRate = ((takenDoses / totalDoses) * 100).round();
      
      // Weekly adherence trend (last 12 weeks)
      Map<int, Map<String, int>> weeklyTrend = {};
      for (int week = 11; week >= 0; week--) {
        weeklyTrend[11 - week] = {'taken': 0, 'forgot': 0, 'total': 0};
      }
      
      // Monthly adherence (last 3 months)
      Map<String, Map<String, int>> monthlyData = {};
      final months = ['Month 1', 'Month 2', 'Month 3'];
      for (String month in months) {
        monthlyData[month] = {'taken': 0, 'forgot': 0, 'total': 0};
      }
      
      // Time-of-day adherence
      Map<String, Map<String, int>> timeData = {
        'Morning': {'taken': 0, 'forgot': 0},
        'Afternoon': {'taken': 0, 'forgot': 0},
        'Evening': {'taken': 0, 'forgot': 0},
      };
      
      // Medicine-specific adherence
      Map<String, Map<String, int>> medicineData = {};
      
      // Day-of-week adherence
      Map<String, Map<String, int>> dayOfWeekData = {
        'Monday': {'taken': 0, 'forgot': 0},
        'Tuesday': {'taken': 0, 'forgot': 0},
        'Wednesday': {'taken': 0, 'forgot': 0},
        'Thursday': {'taken': 0, 'forgot': 0},
        'Friday': {'taken': 0, 'forgot': 0},
        'Saturday': {'taken': 0, 'forgot': 0},
        'Sunday': {'taken': 0, 'forgot': 0},
      };
      
      // Process each medication entry
      for (var med in adherenceData) {
        final actionDate = DateTime.parse(med['actionTime']);
        final action = med['action'];
        final medicineName = med['medicine_name'] ?? 'Unknown';
        final doseTime = med['dose_time'] ?? 'morning';
        
        // Weekly trend
        final weeksDiff = now.difference(actionDate).inDays ~/ 7;
        if (weeksDiff >= 0 && weeksDiff < 12) {
          final weekIndex = 11 - weeksDiff;
          weeklyTrend[weekIndex]![action] = (weeklyTrend[weekIndex]![action] ?? 0) + 1;
          weeklyTrend[weekIndex]!['total'] = (weeklyTrend[weekIndex]!['total'] ?? 0) + 1;
        }
        
        // Monthly data
        final monthsDiff = now.difference(actionDate).inDays ~/ 30;
        if (monthsDiff >= 0 && monthsDiff < 3) {
          final monthKey = months[2 - monthsDiff];
          monthlyData[monthKey]![action] = (monthlyData[monthKey]![action] ?? 0) + 1;
          monthlyData[monthKey]!['total'] = (monthlyData[monthKey]!['total'] ?? 0) + 1;
        }
        
        // Time of day
        final timeKey = doseTime == 'morning' ? 'Morning' : 
                       doseTime == 'afternoon' ? 'Afternoon' : 'Evening';
        timeData[timeKey]![action] = (timeData[timeKey]![action] ?? 0) + 1;
        
        // Medicine-specific
        medicineData[medicineName] ??= {'taken': 0, 'forgot': 0};
        medicineData[medicineName]![action] = (medicineData[medicineName]![action] ?? 0) + 1;
        
        // Day of week
        final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
        final dayKey = dayNames[actionDate.weekday - 1];
        dayOfWeekData[dayKey]![action] = (dayOfWeekData[dayKey]![action] ?? 0) + 1;
      }
      
      // Calculate adherence scores by medicine
      Map<String, double> medicineAdherence = {};
      medicineData.forEach((medicine, data) {
        final total = data['taken']! + data['forgot']!;
        medicineAdherence[medicine] = total > 0 ? (data['taken']! / total * 100) : 0;
      });
      
      return {
        'summary': {
          'total_doses': totalDoses,
          'taken_doses': takenDoses,
          'missed_doses': missedDoses,
          'adherence_rate': adherenceRate,
          'data_period_days': 90,
        },
        'weekly_trend': weeklyTrend,
        'monthly_data': monthlyData,
        'time_of_day_data': timeData,
        'medicine_adherence': medicineAdherence,
        'day_of_week_data': dayOfWeekData,
        'recent_entries': adherenceData.take(20).toList(),
        'generated_at': now.toIso8601String(),
      };
    } catch (e) {
      print('Error getting adherence analytics: $e');
      return _getEmptyAdherenceAnalytics();
    }
  }

  /// Return empty analytics structure when no data is available
  static Map<String, dynamic> _getEmptyAdherenceAnalytics() {
    return {
      'summary': {
        'total_doses': 0,
        'taken_doses': 0,
        'missed_doses': 0,
        'adherence_rate': 0,
        'data_period_days': 90,
      },
      'weekly_trend': {},
      'monthly_data': {},
      'time_of_day_data': {},
      'medicine_adherence': {},
      'day_of_week_data': {},
      'recent_entries': [],
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Clear only fake adherence data (keeps real user data)
  static Future<bool> clearFakeAdherenceData() async {
    try {
      // Remove fake adherence medicines (those with ADHERENCE_ prefix)
      final medicines = await getMedicines();
      final realMedicines = medicines.where((m) => 
        !(m['medicine_id']?.toString().startsWith('ADHERENCE_') ?? false)
      ).toList();
      await saveMedicines(realMedicines);
      
      return true;
    } catch (e) {
      print('Error clearing fake adherence data: $e');
      return false;
    }
  }

  /// Generate fake medication logs specifically for MedicationLogService
  static Future<bool> generateFakeMedicationLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final random = DateTime.now().millisecondsSinceEpoch;
      final baseDate = DateTime.now().subtract(const Duration(days: 30));
      
      // Sample medicine names for medication logs
      final medicineNames = [
        'Paracetamol', 'Ibuprofen', 'Aspirin', 'Metformin', 
        'Lisinopril', 'Atorvastatin', 'Omeprazole', 'Vitamin D'
      ];

      List<Map<String, dynamic>> medicationLogs = [];
      
      // Generate logs for the last 30 days
      for (int day = 0; day < 30; day++) {
        final logDate = baseDate.add(Duration(days: day));
        
        // Generate 2-4 medication logs per day
        final logsPerDay = 2 + (day % 3);
        
        for (int logIndex = 0; logIndex < logsPerDay; logIndex++) {
          final medicineIndex = (day + logIndex) % medicineNames.length;
          final medicine = medicineNames[medicineIndex];
          
          // Calculate reminder time and action time
          final reminderTime = logDate.add(Duration(
            hours: 8 + (logIndex * 6), // 8am, 2pm, 8pm
            minutes: 0,
          ));
          
          // Calculate adherence: 85% taken, 15% forgot
          final adherenceRoll = (random + day + logIndex) % 100;
          final action = adherenceRoll < 85 ? 'taken' : 'forgot';
          
          // Calculate action time (some delay for taken medications)
          DateTime actionTime = reminderTime;
          if (action == 'taken') {
            // Add 0-60 minutes delay
            final delayMinutes = (random + day * logIndex) % 61;
            actionTime = reminderTime.add(Duration(minutes: delayMinutes));
          }
          
          medicationLogs.add({
            'id': '${DateTime.now().millisecondsSinceEpoch + day + logIndex}',
            'action': action,
            'medicineName': medicine, // Note: medicineName (not medicine_name)
            'reminderTime': reminderTime.toIso8601String(),
            'actionTime': actionTime.toIso8601String(),
          });
        }
      }
      
      // Store in MedicationLogService format
      const logKey = 'medication_logs';
      await prefs.setString(logKey, jsonEncode(medicationLogs));
      
      print('✅ Generated ${medicationLogs.length} fake medication logs');
      return true;
    } catch (e) {
      print('Error generating fake medication logs: $e');
      return false;
    }
  }

  /// Clear fake medication logs from MedicationLogService storage
  static Future<bool> clearFakeMedicationLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('medication_logs');
      print('✅ Cleared fake medication logs');
      return true;
    } catch (e) {
      print('Error clearing fake medication logs: $e');
      return false;
    }
  }
}
