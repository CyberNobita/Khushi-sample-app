import 'package:flutter/material.dart';

import '../../core/theme.dart';

enum TaskStatus { todo, inProgress, done }

extension TaskStatusX on TaskStatus {
  String get apiValue {
    switch (this) {
      case TaskStatus.todo:
        return 'todo';
      case TaskStatus.inProgress:
        return 'in_progress';
      case TaskStatus.done:
        return 'done';
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'To-Do';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.done:
        return 'Done';
    }
  }

  Color get color {
    switch (this) {
      case TaskStatus.todo:
        return AppColors.statusTodo;
      case TaskStatus.inProgress:
        return AppColors.statusInProgress;
      case TaskStatus.done:
        return AppColors.statusDone;
    }
  }

  static TaskStatus fromApi(String value) {
    switch (value) {
      case 'todo':
        return TaskStatus.todo;
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'done':
        return TaskStatus.done;
      default:
        return TaskStatus.todo;
    }
  }
}

class Task {
  const Task({
    required this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
    this.blockedByTitle,
    required this.isBlocked,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
  });

  final String id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;
  final String? blockedByTitle;
  final bool isBlocked;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sortOrder;

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
    String? blockedByTitle,
    bool? isBlocked,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sortOrder,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById ?? this.blockedById,
      blockedByTitle: blockedByTitle ?? this.blockedByTitle,
      isBlocked: isBlocked ?? this.isBlocked,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
