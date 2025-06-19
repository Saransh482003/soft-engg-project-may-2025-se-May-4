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
}
