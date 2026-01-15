import 'package:flutter/material.dart';
import '../models/assignment.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback onTap;
  final Function(bool?)? onCompletedChanged;

  const AssignmentCard({
    super.key,
    required this.assignment,
    required this.onTap,
    this.onCompletedChanged,
  });

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1: return Colors.green;
      case 2: return Colors.lightGreen;
      case 3: return Colors.orange;
      case 4: return Colors.red;
      case 5: return Colors.red[900]!;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Checkbox(
          value: assignment.isCompleted,
          onChanged: onCompletedChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(
          assignment.title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            decoration: assignment.isCompleted 
                ? TextDecoration.lineThrough 
                : TextDecoration.none,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              assignment.description.isNotEmpty 
                  ? assignment.description 
                  : 'No description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(assignment.priority),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    assignment.priorityLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Due: ${assignment.dueDate.toString().substring(0, 10)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              assignment.daysLeft,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: assignment.daysLeft == 'Overdue'
                    ? Colors.red
                    : assignment.daysLeft == 'Today'
                        ? Colors.orange
                        : Colors.blue,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}