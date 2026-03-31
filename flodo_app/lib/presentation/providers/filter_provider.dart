import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';

class TaskFilter {
  const TaskFilter({
    this.searchQuery = '',
    this.status,
  });

  final String searchQuery;
  final TaskStatus? status;

  TaskFilter copyWith({
    String? searchQuery,
    TaskStatus? status,
    bool clearStatus = false,
  }) {
    return TaskFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      status: clearStatus ? null : status ?? this.status,
    );
  }
}

final filterProvider = StateProvider<TaskFilter>((ref) {
  return const TaskFilter();
});
