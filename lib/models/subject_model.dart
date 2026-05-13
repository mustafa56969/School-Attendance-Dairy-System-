class SubjectModel {
  final String id;
  final String name;
  final String classId;
 final String teacherId;

  SubjectModel({
    required this.id,
    required this.name,
    required this.classId,
    required this.teacherId,
  });

  factory SubjectModel.fromMap(Map<String, dynamic> data, String id) {
    return SubjectModel(
      id: id,
      name: data['name'] ?? '',
      classId: data['classId'] ?? '',
      teacherId: data['teacherId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classId': classId,
      'teacherId': teacherId,
    };
  }
}
