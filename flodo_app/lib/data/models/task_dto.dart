import 'package:intl/intl.dart';

import '../../domain/entities/task.dart';

class TaskUpsertDto {
  const TaskUpsertDto({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    required this.blockedById,
    this.sortOrder = 0,
  });

  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;
  final int sortOrder;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description.trim().isEmpty ? null : description.trim(),
      'due_date': DateFormat('yyyy-MM-dd').format(dueDate),
      'status': status.apiValue,
      'blocked_by_id': blockedById,
      'sort_order': sortOrder,
    };
  }
}

class TaskDtoMapper {
  const TaskDtoMapper._();

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: (json['title'] as String? ?? '').trim(),
      description: json['description'] as String?,
      dueDate: DateTime.parse(json['due_date'] as String),
      status: TaskStatusX.fromApi(json['status'] as String? ?? 'todo'),
      blockedById: json['blocked_by_id'] as String?,
      blockedByTitle: json['blocked_by_title'] as String?,
      isBlocked: json['is_blocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}
