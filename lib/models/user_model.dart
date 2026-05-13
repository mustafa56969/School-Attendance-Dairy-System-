class UserModel {
  final String uid;
  final String email;
  final String role; // 'student', 'teacher', 'admin'
  final String? name;

  // Student specific fields
  final String? classId;
  final String? rollNo;
  final String? fatherName;
  final String? phone;

  // Teacher specific fields
  final List<String>? assignedSubjects;
  final List<String>? assignedClasses; // Classes assigned for attendance marking

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.classId,
    this.rollNo,
    this.fatherName,
    this.phone,
    this.assignedSubjects,
    this.assignedClasses,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    List<String>? assignedSubjectsList;
    List<String>? assignedClassesList;

    // Handle the assignedSubjects field properly
    if (data['assignedSubjects'] != null) {
      try {
        if (data['assignedSubjects'] is List) {
          assignedSubjectsList = (data['assignedSubjects'] as List)
              .map((item) => item.toString())
              .toList();
        } else if (data['assignedSubjects'] is String) {
          // If it's a string, split by comma or treat as single item
          assignedSubjectsList = [data['assignedSubjects'].toString()];
        }
      } catch (e) {
        assignedSubjectsList = [];
      }
    }

    // Handle the assignedClasses field properly
    if (data['assignedClasses'] != null) {
      try {
        if (data['assignedClasses'] is List) {
          assignedClassesList = (data['assignedClasses'] as List)
              .map((item) => item.toString())
              .toList();
        } else if (data['assignedClasses'] is String) {
          assignedClassesList = [data['assignedClasses'].toString()];
        }
      } catch (e) {
        assignedClassesList = [];
      }
    }

    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      role: data['role'] ?? 'student',
      name: data['name'],
      classId: data['classId'],
      rollNo: data['rollNo'],
      fatherName: data['fatherName'],
      phone: data['phone'],
      assignedSubjects: assignedSubjectsList,
      assignedClasses: assignedClassesList,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'classId': classId,
      'rollNo': rollNo,
      'fatherName': fatherName,
      'phone': phone,
      'assignedSubjects': assignedSubjects,
      'assignedClasses': assignedClasses,
    };
  }
}
