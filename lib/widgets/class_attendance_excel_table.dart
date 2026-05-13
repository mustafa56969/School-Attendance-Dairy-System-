import 'package:flutter/material.dart';
import '../models/attendance_model.dart';
import '../theme/playful_theme.dart';

class ClassAttendanceExcelTable extends StatelessWidget {
  final List<Map<String, dynamic>> students; // [{id, name, rollNo}]
  final Map<String, List<AttendanceModel>> studentRecords; // {studentId: [records]}
  final DateTime monthDate;

  const ClassAttendanceExcelTable({
    super.key,
    required this.students,
    required this.studentRecords,
    required this.monthDate,
  });

  @override
  Widget build(BuildContext context) {
    final lastDay = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final daysInMonth = List.generate(lastDay, (index) => index + 1);

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
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 10,
              horizontalMargin: 12,
              headingRowHeight: 45,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 45,
              headingRowColor: WidgetStateProperty.all(PlayfulTheme.primaryTeal.withOpacity(0.1)),
              border: TableBorder.all(color: Colors.grey.withOpacity(0.1)),
              columns: [
                const DataColumn(label: SizedBox(width: 40, child: Text('Roll', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                const DataColumn(label: SizedBox(width: 100, child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                const DataColumn(label: SizedBox(width: 45, child: Text('%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)))),
                ...daysInMonth.map((day) => DataColumn(
                  label: SizedBox(
                    width: 30, 
                    child: Text(day.toString(), textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10))
                  )
                )),
              ],
              rows: students.map((student) {
                final id = student['uid'] ?? student['id'];
                final records = studentRecords[id] ?? [];
                
                // Calculate percentage for the month
                int presentCount = records.where((r) => r.isPresent && r.date.month == monthDate.month).length;
                int totalMarked = records.where((r) => r.date.month == monthDate.month).length;
                double percentage = totalMarked > 0 ? (presentCount / totalMarked) * 100 : 0;

                final attendanceMap = <int, bool?>{};
                for (var r in records) {
                  if (r.date.month == monthDate.month) {
                    attendanceMap[r.date.day] = r.isPresent;
                  }
                }

                return DataRow(cells: [
                  DataCell(Text(student['rollNo']?.toString() ?? '-', style: const TextStyle(fontSize: 11))),
                  DataCell(SizedBox(width: 100, child: Text(student['name'] ?? 'Unknown', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)))),
                  DataCell(Text('${percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _getPercentageColor(percentage)))),
                  ...daysInMonth.map((day) {
                    final status = attendanceMap[day];
                    return DataCell(
                      Container(
                        width: 30,
                        alignment: Alignment.center,
                        child: Text(
                          status == null ? '-' : (status ? 'P' : 'A'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: status == null ? Colors.grey : (status ? Colors.green : Colors.red),
                          ),
                        ),
                      )
                    );
                  }),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(double pct) {
    if (pct >= 80) return Colors.green;
    if (pct >= 60) return Colors.orange;
    return Colors.red;
  }
}
