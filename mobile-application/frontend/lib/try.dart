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
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.2),
                color.withOpacity(0.1),
              ],
            ),
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
                style: TextStyle(
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
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
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
                        final response = await http.get(
                          Uri.parse('$baseUrl/get-med-info?med_name=$medicineName'),
                          headers: {'Content-Type': 'application/json'},
                        );
                        if (response.statusCode == 200) {
                          setState(() {
                            _medicineInfo[presId] = jsonDecode(response.body)['info'] ?? 'No information available';
                          });
                        } else {
                          setState(() {
                            _medicineInfo[presId] = 'Failed to load information';
                          });
                        }
                      } catch (e) {
                        setState(() {
                          _medicineInfo[presId] = 'Error loading information';
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
    ),
  );
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
                              : Colors.green[100],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      daysRemaining,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isExpired
                            ? ThemeConstants.secondaryColor
                            : (daysRemaining.contains('days remaining') && int.tryParse(daysRemaining.split(' ')[0]) != null && int.parse(daysRemaining.split(' ')[0]) < 30
                                ? Colors.orange[700]
                                : Colors.green[700],
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
