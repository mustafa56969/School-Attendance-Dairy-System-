import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../theme/playful_theme.dart';
import 'package:intl/intl.dart';

class AttendanceExcelTable extends StatelessWidget {
  final List<AttendanceModel> records;
  final DateTime monthDate;

  const AttendanceExcelTable({
    super.key,
    required this.records,
    required this.monthDate,
  });

  @override
  Widget build(BuildContext context) {
    // Get number of days in the month
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final daysInMonth = List.generate(lastDay, (index) => index + 1);

    // Create a map for quick lookup
    final Map<int, bool?> attendanceMap = {};
    for (var record in records) {
      if (record.date.month == monthDate.month && record.date.year == monthDate.year) {
        attendanceMap[record.date.day] = record.isPresent;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Container(
                color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                child: Row(
                  children: [
                    _buildCell('Date', isHeader: true, width: 80),
                    ...daysInMonth.map((day) => _buildCell(day.toString(), isHeader: true)),
                  ],
                ),
              ),
              // Status Row
              Row(
                children: [
                  _buildCell('Status', isHeader: true, width: 80),
                  ...daysInMonth.map((day) {
                    final status = attendanceMap[day];
                    return _buildStatusCell(status);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String text, {bool isHeader = false, double width = 45}) {
    return Container(
      width: width,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
          color: isHeader ? PlayfulTheme.primaryTeal : PlayfulTheme.textMain,
        ),
      ),
    );
  }

  Widget _buildStatusCell(bool? isPresent) {
    String text = '-';
    Color color = Colors.grey;
    Color bgColor = Colors.transparent;

    if (isPresent != null) {
      if (isPresent) {
        text = 'P';
        color = Colors.green;
        bgColor = Colors.green.withOpacity(0.1);
      } else {
        text = 'A';
        color = Colors.red;
        bgColor = Colors.red.withOpacity(0.1);
      }
    }

    return Container(
      width: 45,
      height: 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: color,
        ),
      ),
    );
  }
}
