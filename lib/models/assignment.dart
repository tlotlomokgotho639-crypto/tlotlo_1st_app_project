class Assignment {
  int? id;
  int courseId;
  String title;
  String description;
  DateTime dueDate;
  int priority; // 1-5 scale
  bool isCompleted;
  DateTime? completedAt;

  Assignment({
    this.id,
    required this.courseId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = 3,
    this.isCompleted = false,
    this.completedAt,
  });

  String get priorityLabel {
    switch (priority) {
      case 1: return 'Low';
      case 2: return 'Medium-Low';
      case 3: return 'Medium';
      case 4: return 'High';
      case 5: return 'Urgent';
      default: return 'Medium';
    }
  }

  String get daysLeft {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    final days = difference.inDays;
    
    if (days < 0) return 'Overdue';
    if (days == 0) return 'Today';
    if (days == 1) return 'Tomorrow';
    return '$days days';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'course_id': courseId,
      'title': title,
      'description': description,
      'due_date': dueDate.toIso8601String(),
      'priority': priority,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'],
      courseId: map['course_id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['due_date']),
      priority: map['priority'],
      isCompleted: map['is_completed'] == 1,
      completedAt: map['completed_at'] != null 
          ? DateTime.parse(map['completed_at']) 
          : null,
    );
  }
}