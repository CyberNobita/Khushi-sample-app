import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task.dart';
import '../models/task_dto.dart';
import '../services/task_api_service.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(ref.watch(taskApiServiceProvider));
});

class TaskRepository {
  TaskRepository(this._apiService);

  final TaskApiService _apiService;

  Future<List<Task>> fetchTasks({String? search, TaskStatus? status}) {
    return _apiService.fetchTasks(search: search, status: status);
  }

  Future<Task> getTask(String taskId) {
    return _apiService.getTask(taskId);
  }

  Future<Task> createTask(TaskUpsertDto dto) {
    return _apiService.createTask(dto);
  }

  Future<Task> updateTask(String taskId, TaskUpsertDto dto) {
    return _apiService.updateTask(taskId, dto);
  }

  Future<void> deleteTask(String taskId) {
    return _apiService.deleteTask(taskId);
  }
}
