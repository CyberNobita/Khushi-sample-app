import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config.dart';
import '../../core/exceptions.dart';
import '../../domain/entities/task.dart';
import '../models/task_dto.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: const {'Content-Type': 'application/json'},
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        final detail =
            data is Map<String, dynamic> ? data['detail']?.toString() : null;

        if (statusCode == 422) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: ValidationException(detail ?? 'Invalid form data.'),
            ),
          );
          return;
        }

        if (statusCode == 404) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: NotFoundException(detail ?? 'Task not found.'),
            ),
          );
          return;
        }

        if (error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              response: error.response,
              error: const NetworkException('Could not connect to server.'),
            ),
          );
          return;
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});

final taskApiServiceProvider = Provider<TaskApiService>((ref) {
  return TaskApiService(ref.watch(dioProvider));
});

class TaskApiService {
  TaskApiService(this._dio);

  final Dio _dio;

  Future<List<Task>> fetchTasks({String? search, TaskStatus? status}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/tasks',
        queryParameters: {
          if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
          if (status != null) 'status': status.apiValue,
        },
      );

      final payload = response.data ?? const <String, dynamic>{};
      final list = payload['data'] as List<dynamic>? ?? <dynamic>[];
      return list
          .map((item) => TaskDtoMapper.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<Task> getTask(String taskId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/tasks/$taskId');
      final payload = response.data ?? const <String, dynamic>{};
      return TaskDtoMapper.fromJson(payload);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<Task> createTask(TaskUpsertDto dto) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/tasks',
        data: dto.toJson(),
      );
      final payload = response.data ?? const <String, dynamic>{};
      return TaskDtoMapper.fromJson(payload);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<Task> updateTask(String taskId, TaskUpsertDto dto) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/tasks/$taskId',
        data: dto.toJson(),
      );
      final payload = response.data ?? const <String, dynamic>{};
      return TaskDtoMapper.fromJson(payload);
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dio.delete<void>('/tasks/$taskId');
    } on DioException catch (error) {
      throw _mapError(error);
    }
  }

  Exception _mapError(DioException error) {
    final custom = error.error;
    if (custom is Exception) {
      return custom;
    }

    final responseMessage = error.response?.data;
    if (responseMessage is Map<String, dynamic> &&
        responseMessage['detail'] != null) {
      return ApiException(responseMessage['detail'].toString());
    }

    return const ApiException('Unexpected API error');
  }
}
