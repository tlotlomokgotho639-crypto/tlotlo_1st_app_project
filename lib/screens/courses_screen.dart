class Course {
  final int? id;
  final String name;
  final String code;
  final String professor;
  final String color;
  final double credits;

  Course({
    this.id,
    required this.name,
    required this.code,
    required this.professor,
    this.color = '#4285F4',
    this.credits = 3.0,
  });

  // Convert Course to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'professor': professor,
      'color': color,
      'credits': credits,
    };
  }

  // Convert Map to Course from database
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as int?,
      name: map['name'] as String,
      code: map['code'] as String,
      professor: map['professor'] as String,
      color: map['color'] as String? ?? '#4285F4',
      credits: map['credits'] as double? ?? 3.0,
    );
  }

  // Copy with new values
  Course copyWith({
    int? id,
    String? name,
    String? code,
    String? professor,
    String? color,
    double? credits,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      professor: professor ?? this.professor,
      color: color ?? this.color,
      credits: credits ?? this.credits,
    );
  }
}