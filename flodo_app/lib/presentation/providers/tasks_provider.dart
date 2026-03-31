import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_dto.dart';
import '../../data/repositories/task_repository.dart';
import '../../domain/entities/task.dart';
import 'filter_provider.dart';

final tasksProvider =
    AsyncNotifierProvider<TasksNotifier, List<Task>>(TasksNotifier.new);

class TasksNotifier extends AsyncNotifier<List<Task>> {
  TaskRepository get _repository => ref.watch(taskRepositoryProvider);

  @override
  Future<List<Task>> build() async {
    final filter = ref.watch(filterProvider);
    return _repository.fetchTasks(
      search: filter.searchQuery,
      status: filter.status,
    );
  }

  Future<List<Task>> ensureLoaded() async {
    return future;
  }

  Future<Task?> getTaskById(String taskId) async {
    final current = state.valueOrNull;
    if (current != null) {
      for (final task in current) {
        if (task.id == taskId) {
          return task;
        }
      }
    }

    return _repository.getTask(taskId);
  }

  Future<void> createTask(TaskUpsertDto dto) async {
    await _repository.createTask(dto);
    ref.invalidateSelf();
    await future;
  }

  Future<void> updateTask(String taskId, TaskUpsertDto dto) async {
    await _repository.updateTask(taskId, dto);
    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteTask(String taskId) async {
    await _repository.deleteTask(taskId);
    ref.invalidateSelf();
    await future;
  }
}
