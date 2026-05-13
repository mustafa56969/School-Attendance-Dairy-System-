import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/playful_theme.dart';

class ClassPromotionScreen extends StatefulWidget {
  const ClassPromotionScreen({super.key});

  @override
  State<ClassPromotionScreen> createState() => _ClassPromotionScreenState();
}

class _ClassPromotionScreenState extends State<ClassPromotionScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isProcessing = false;
  Map<String, int> _classStudentCounts = {};
  bool _isLoadingCounts = true;

  @override
  void initState() {
    super.initState();
    _loadClassCounts();
  }

  Future<void> _loadClassCounts() async {
    setState(() => _isLoadingCounts = true);
    
    try {
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      final counts = <String, int>{};
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final classId = data['classId'] as String?;
        if (classId != null && classId.isNotEmpty) {
          counts[classId] = (counts[classId] ?? 0) + 1;
        }
      }

      if (mounted) {
        setState(() {
          _classStudentCounts = counts;
          _isLoadingCounts = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading class counts: $e');
      if (mounted) {
        setState(() => _isLoadingCounts = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Promotion'),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.1),
        elevation: 0,
      ),
      body: _isLoadingCounts
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          PlayfulTheme.primaryTeal.withOpacity(0.1),
                          PlayfulTheme.bgColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: PlayfulTheme.accentPurple.withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.school,
                                color: PlayfulTheme.accentPurple,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Annual Class Promotion',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'Promote all students to the next grade level',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                    ),
                  ),

                  // Warning Card
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Important Notice',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade900,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'This action will promote ALL students to the next class. This cannot be undone. Please backup your data before proceeding.',
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2, end: 0),
                  ),

                  // Current Class Distribution
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Student Distribution',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(delay: 300.ms),
                        const SizedBox(height: 16),
                        _buildClassDistribution(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Promotion Preview
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Promotion Preview',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ).animate(delay: 400.ms),
                        const SizedBox(height: 8),
                        Text(
                          'What will happen after promotion:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildPromotionPreview(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Promote Button
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : _showPromotionConfirmation,
                        icon: _isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.arrow_upward, size: 24),
                        label: Text(
                          _isProcessing ? 'Processing...' : 'Promote All Students',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PlayfulTheme.primaryTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                      ).animate(delay: 600.ms).fadeIn().scale(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildClassDistribution() {
    final classes = ['Nursery', 'KG', '1st', '2nd', '3rd', '4th', '5th', '6th', '7th', '8th', '9th', '10th'];
    
    return Column(
      children: classes.map((classId) {
        final count = _classStudentCounts[classId] ?? 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    classId == 'Nursery' ? 'N' : classId == 'KG' ? 'K' : classId.replaceAll('th', '').replaceAll('st', '').replaceAll('nd', '').replaceAll('rd', ''),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: PlayfulTheme.primaryTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class $classId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$count student${count != 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: PlayfulTheme.primaryTeal,
                    ),
                  ),
                ),
            ],
          ),
        ).animate(delay: (350 + classes.indexOf(classId) * 30).ms).fadeIn().slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  Widget _buildPromotionPreview() {
    final promotions = [
      {'from': 'Nursery', 'to': 'KG', 'color': Colors.purple},
      {'from': 'KG', 'to': '1st', 'color': Colors.blue},
      {'from': '1st', 'to': '2nd', 'color': Colors.teal},
      {'from': '2nd', 'to': '3rd', 'color': Colors.green},
      {'from': '3rd', 'to': '4th', 'color': Colors.lime},
      {'from': '4th', 'to': '5th', 'color': Colors.yellow},
      {'from': '5th', 'to': '6th', 'color': Colors.orange},
      {'from': '6th', 'to': '7th', 'color': Colors.deepOrange},
      {'from': '7th', 'to': '8th', 'color': Colors.red},
      {'from': '8th', 'to': '9th', 'color': Colors.pink},
      {'from': '9th', 'to': '10th', 'color': Colors.purple},
      {'from': '10th', 'to': 'Graduated', 'color': Colors.grey},
    ];

    return Column(
      children: promotions.map((promo) {
        final fromClass = promo['from'] as String;
        final toClass = promo['to'] as String;
        final color = promo['color'] as Color;
        final count = _classStudentCounts[fromClass] ?? 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              // From class
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    fromClass,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
              // Arrow
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.arrow_forward,
                  color: color,
                  size: 24,
                ),
              ),
              // To class
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: toClass == 'Graduated' 
                        ? Colors.grey.shade200
                        : Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: toClass == 'Graduated'
                          ? Colors.grey.shade400
                          : Colors.green.shade200,
                    ),
                  ),
                  child: Text(
                    toClass,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: toClass == 'Graduated' ? Colors.grey[700] : Colors.green[700],
                    ),
                  ),
                ),
              ),
              // Count
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        ).animate(delay: (450 + promotions.indexOf(promo) * 30).ms).fadeIn().slideX(begin: 0.2, end: 0);
      }).toList(),
    );
  }

  void _showPromotionConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            SizedBox(width: 12),
            Text('Confirm Promotion'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action will:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildConfirmationItem('Promote all students to next class', Icons.arrow_upward, Colors.blue),
            _buildConfirmationItem('Mark 10th graders as graduated', Icons.school, Colors.green),
            _buildConfirmationItem('Cannot be undone', Icons.lock, Colors.red),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: const Text(
                'Please ensure you have backed up your data before proceeding!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performPromotion();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PlayfulTheme.primaryTeal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Proceed with Promotion'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
          ),
        ],
      ),
    );
  }

  Future<void> _performPromotion() async {
    setState(() => _isProcessing = true);

    try {
      final batch = _firestore.batch();
      
      // Get all students
      final studentsSnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'student')
          .get();

      int promotedCount = 0;
      int graduatedCount = 0;

      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        final currentClass = data['classId'] as String?;

        if (currentClass == null || currentClass.isEmpty) continue;

        String? newClass;
        bool isGraduated = false;

        switch (currentClass) {
          case 'Nursery':
            newClass = 'KG';
            break;
          case 'KG':
            newClass = '1st';
            break;
          case '1st':
            newClass = '2nd';
            break;
          case '2nd':
            newClass = '3rd';
            break;
          case '3rd':
            newClass = '4th';
            break;
          case '4th':
            newClass = '5th';
            break;
          case '5th':
            newClass = '6th';
            break;
          case '6th':
            newClass = '7th';
            break;
          case '7th':
            newClass = '8th';
            break;
          case '8th':
            newClass = '9th';
            break;
          case '9th':
            newClass = '10th';
            break;
          case '10th':
            // Graduation - mark as graduated
            newClass = 'Graduated';
            isGraduated = true;
            graduatedCount++;
            break;
        }

        if (newClass != null) {
          batch.update(doc.reference, {
            'classId': newClass,
            'isGraduated': isGraduated,
            'promotionDate': FieldValue.serverTimestamp(),
          });
          if (!isGraduated) promotedCount++;
        }
      }

      await batch.commit();

      if (mounted) {
        setState(() => _isProcessing = false);
        
        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 32),
                SizedBox(width: 12),
                Text('Promotion Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '✅ $promotedCount students promoted',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  '🎓 $graduatedCount students graduated',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'All students have been successfully promoted to their next classes!',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to admin dashboard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: PlayfulTheme.primaryTeal,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Done'),
              ),
            ],
          ),
        );

        // Reload counts
        _loadClassCounts();
      }
    } catch (e) {
      debugPrint('Error performing promotion: $e');
      
      if (mounted) {
        setState(() => _isProcessing = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
