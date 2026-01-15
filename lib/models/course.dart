class Course {
  int? id;
  String name;
  String code;
  String professor;
  String color;
  String days;
  String time;
  String location;
  double credits;
  DateTime createdAt;

  Course({
    this.id,
    required this.name,
    required this.code,
    required this.professor,
    this.color = '#4285F4',
    this.days = 'Mon, Wed',
    this.time = '10:00 AM',
    this.location = 'Room 101',
    this.credits = 3.0,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'professor': professor,
      'color': color,
      'days': days,
      'time': time,
      'location': location,
      'credits': credits,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      professor: map['professor'],
      color: map['color'],
      days: map['days'],
      time: map['time'],
      location: map['location'],
      credits: map['credits'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}