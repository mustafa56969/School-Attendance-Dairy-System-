import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../theme/playful_theme.dart';
import '../../widgets/vibrant_loading_widget.dart';
import '../../widgets/vibrant_error_widget.dart';

class ViewAllDiariesScreen extends StatefulWidget {
  const ViewAllDiariesScreen({super.key});

  @override
  State<ViewAllDiariesScreen> createState() => _ViewAllDiariesScreenState();
}

class _ViewAllDiariesScreenState extends State<ViewAllDiariesScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedClass;
  List<String> _availableClasses = [];
  bool _isLoadingClasses = true;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _predefinedClasses = [
    'KG',
    'Nursery',
    '1st',
    '2nd',
    '3rd',
    '4th',
    '5th',
    '6th',
    '7th',
    '8th',
    '9th',
    '10th',
  ];

  @override
  void initState() {
    super.initState();
    _loadAvailableClasses();
    _setInitialDateRange();
  }

  void _setInitialDateRange() {
    final now = DateTime.now();
    _endDate = now;
    _startDate = DateTime(now.year, now.month, 1); // First day of current month
  }

  Future<void> _loadAvailableClasses() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      // Get unique classes from diaries
      final diarySnapshot = await FirebaseFirestore.instance
          .collection('diaries')
          .limit(1000) // Limit to avoid performance issues
          .get();

      final classes = <String>{};
      for (var doc in diarySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('classId') && data['classId'] != null) {
          classes.add(data['classId'].toString());
        }
      }

      setState(() {
        _availableClasses = classes.toList()..sort();
        _isLoadingClasses = false;
      });
    } catch (e) {
      debugPrint('Error loading classes: $e');
      setState(() {
        _availableClasses = _predefinedClasses;
        _isLoadingClasses = false;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PlayfulTheme.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PlayfulTheme.textMain,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: PlayfulTheme.primaryTeal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // If end date is before start date, reset end date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: PlayfulTheme.primaryTeal,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: PlayfulTheme.textMain,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: PlayfulTheme.primaryTeal,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
      _selectedClass = null;
      _searchController.clear();
      _searchQuery = '';
      _setInitialDateRange();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Diaries',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: PlayfulTheme.primaryTeal.withOpacity(0.15),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filters Section
          _buildFiltersSection(),

          // Diaries List
          Expanded(child: _buildDiariesList()),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Diaries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Date Range Selector
          Row(
            children: [
              Expanded(
                child: _buildDateButton(
                  label: 'Start Date',
                  date: _startDate,
                  onTap: _selectStartDate,
                ),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.arrow_right_alt,
                color: PlayfulTheme.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateButton(
                  label: 'End Date',
                  date: _endDate,
                  onTap: _selectEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Class Selector and Search
          Row(
            children: [
              // Class Dropdown
              Expanded(flex: 2, child: _buildClassDropdown()),
              const SizedBox(width: 12),
              // Search Field
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search diaries...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: PlayfulTheme.bgColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(color: PlayfulTheme.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateButton({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: PlayfulTheme.bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: PlayfulTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date != null
                  ? DateFormat('MMM dd, yyyy').format(date)
                  : 'Select date',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: PlayfulTheme.bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedClass,
          hint: const Text('All Classes', style: TextStyle(fontSize: 14)),
          items: [
            const DropdownMenuItem(value: null, child: Text('All Classes')),
            ...(_isLoadingClasses ? _predefinedClasses : _availableClasses).map(
              (String className) {
                return DropdownMenuItem(
                  value: className,
                  child: Text(className),
                );
              },
            ).toList(),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedClass = newValue;
            });
          },
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, size: 24),
        ),
      ),
    );
  }

  Widget _buildDiariesList() {
    Query query = FirebaseFirestore.instance.collection('diaries');

    // Apply ONLY ONE filter at a time to avoid composite index requirements
    if (_selectedClass != null) {
      // If class is selected, filter by class only
      query = query.where('classId', isEqualTo: _selectedClass);
    } else if (_startDate != null && _endDate != null) {
      // If both dates are selected, filter by date range only
      query = query
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(_setEndOfDay(_endDate!)));
    } else if (_startDate != null) {
      // If only start date, filter from start date onwards
      query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(_startDate!));
    } else if (_endDate != null) {
      // If only end date, filter up to end date
      query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(_setEndOfDay(_endDate!)));
    }

    // Always order by date descending
    query = query.orderBy('date', descending: true).limit(100);

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        // Handle index errors specifically
        if (snapshot.hasError) {
          if (snapshot.error.toString().contains('failed-precondition') ||
              snapshot.error.toString().contains('index')) {
            return _buildIndexErrorWidget();
          }

          return VibrantErrorWidget(
            message: 'Failed to load diaries: ${snapshot.error}',
            onRetry: () {},
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: VibrantLoadingWidget(message: 'Loading diaries...'),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        // Apply additional filtering client-side for combinations that aren't supported by Firestore
        List<QueryDocumentSnapshot> filteredDocs = docs;

        // If we have a class filter AND date filters, we need to filter client-side
        if (_selectedClass != null && (_startDate != null || _endDate != null)) {
          filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['date'] is! Timestamp) return false;

            final diaryDate = (data['date'] as Timestamp).toDate();
            
            bool dateMatch = true;
            if (_startDate != null) {
              dateMatch = dateMatch && !diaryDate.isBefore(_startDate!);
            }
            if (_endDate != null) {
              dateMatch = dateMatch && !diaryDate.isAfter(_setEndOfDay(_endDate!));
            }
            
            return dateMatch;
          }).toList();
        }

        // Apply search filter locally
        if (_searchQuery.isNotEmpty) {
          filteredDocs = filteredDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final content = (data['content'] ?? '').toString().toLowerCase();
            final subject = (data['subject'] ?? '').toString().toLowerCase();
            final classId = (data['classId'] ?? '').toString().toLowerCase();

            return content.contains(_searchQuery) ||
                subject.contains(_searchQuery) ||
                classId.contains(_searchQuery);
          }).toList();
        }

        if (filteredDocs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: PlayfulTheme.primaryTeal,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No diaries found',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _searchQuery.isNotEmpty
                      ? 'No diaries match your search'
                      : 'Try adjusting your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: PlayfulTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;
            final date =
                (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
            final classId = data['classId'] ?? 'Unknown';
            final subject = data['subject'] ?? 'Unknown Subject';
            final content = data['content'] ?? '';
            final teacherId = data['teacherId'] ?? 'Unknown';

            return _buildDiaryCard(
              date: date,
              classId: classId.toString(),
              subject: subject.toString(),
              content: content.toString(),
              teacherId: teacherId.toString(),
            );
          },
        );
      },
    );
  }

  // Helper method to set time to end of day
  DateTime _setEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  Widget _buildIndexErrorWidget() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Index Required',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This query requires a Firebase index to work properly.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: PlayfulTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Try with simplified query
                setState(() {
                  _selectedClass = null;
                  _startDate = null;
                  _endDate = null;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PlayfulTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Reset Filters'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryCard({
    required DateTime date,
    required String classId,
    required String subject,
    required String content,
    required String teacherId,
  }) {
    // Truncate content to prevent overflow
    String truncatedContent = content;
    if (content.length > 200) {
      truncatedContent = '${content.substring(0, 200)}...';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and class
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: PlayfulTheme.primaryTeal.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryTeal,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM dd, yyyy').format(date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$classId • $subject',
                        style: TextStyle(
                          fontSize: 14,
                          color: PlayfulTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.primaryPink.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    classId,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: PlayfulTheme.primaryPink,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                // Use Text widget with maxLines and overflow to prevent overflow
                Text(
                  truncatedContent,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: PlayfulTheme.bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: PlayfulTheme.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Teacher ID: $teacherId',
                          style: TextStyle(
                            fontSize: 12,
                            color: PlayfulTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
