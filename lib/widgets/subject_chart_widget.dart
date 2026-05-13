import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/playful_theme.dart';

class SubjectChartWidget extends StatelessWidget {
  final List<Map<String, dynamic>> subjectData;

  const SubjectChartWidget({super.key, required this.subjectData});

  @override
  Widget build(BuildContext context) {
    if (subjectData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          children: [
            Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No subject data available',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.bar_chart,
                  color: PlayfulTheme.primaryTeal,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Subject Activity',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PlayfulTheme.textMain,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Based on diary entries',
            style: TextStyle(fontSize: 14, color: PlayfulTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                barGroups: _generateBarGroups(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() < subjectData.length) {
                          final subject = subjectData[value.toInt()];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              subject['name'].toString().split(' ').first,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: PlayfulTheme.textSecondary,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 35,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: PlayfulTheme.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                ),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${subjectData[groupIndex]['name']}\n',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: '${rod.toY.toInt()} entries',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                    tooltipRoundedRadius: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegend(),
        ],
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return List.generate(subjectData.length, (index) {
      final subject = subjectData[index];
      final color = subject['color'] as Color? ?? PlayfulTheme.primaryTeal;
      final count = subject['count'] as int? ?? 0;

      // Add some visual enhancement for zero values
      final barHeight = count > 0 ? count.toDouble() : 0.1;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: barHeight,
            color: color,
            width: 24,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            rodStackItems: [],
          ),
        ],
      );
    });
  }

  Widget _buildLegend() {
    // Filter out subjects with zero entries for a cleaner legend
    final nonZeroSubjects = subjectData
        .where((subject) => subject['count'] > 0)
        .toList();

    if (nonZeroSubjects.isEmpty) {
      return const Center(
        child: Text(
          'No activity yet',
          style: TextStyle(fontSize: 14, color: PlayfulTheme.textSecondary),
        ),
      );
    }

    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: List.generate(nonZeroSubjects.length, (index) {
        final subject = nonZeroSubjects[index];
        final color = subject['color'] as Color? ?? PlayfulTheme.primaryTeal;
        final count = subject['count'] as int? ?? 0;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                '${subject['name']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: PlayfulTheme.textMain,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  fontSize: 12,
                  color: PlayfulTheme.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
