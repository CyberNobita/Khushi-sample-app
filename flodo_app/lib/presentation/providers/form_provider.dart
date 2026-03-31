import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/task_dto.dart';
import '../../data/repositories/draft_repository.dart';
import '../../domain/entities/task.dart';

final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepository();
});

class TaskFormState {
  const TaskFormState({
    this.title = '',
    this.description = '',
    this.dueDate,
    this.status = TaskStatus.todo,
    this.blockedById,
    this.sortOrder = 0,
  });

  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskStatus status;
  final String? blockedById;
  final int sortOrder;

  bool get isValid => title.trim().isNotEmpty && dueDate != null;

  TaskFormState copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    bool clearDueDate = false,
    TaskStatus? status,
    String? blockedById,
    bool clearBlockedById = false,
    int? sortOrder,
  }) {
    return TaskFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: clearDueDate ? null : dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: clearBlockedById ? null : blockedById ?? this.blockedById,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  Map<String, dynamic> toDraftJson() {
    return {
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'status': status.apiValue,
      'blocked_by_id': blockedById,
      'sort_order': sortOrder,
    };
  }

  factory TaskFormState.fromDraftJson(Map<String, dynamic> json) {
    return TaskFormState(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dueDate: json['due_date'] == null
          ? null
          : DateTime.tryParse(json['due_date'] as String),
      status: TaskStatusX.fromApi(json['status'] as String? ?? 'todo'),
      blockedById: json['blocked_by_id'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  TaskUpsertDto toUpsertDto() {
    final date = dueDate;
    if (date == null) {
      throw ArgumentError('Due date is required');
    }

    return TaskUpsertDto(
      title: title.trim(),
      description: description,
      dueDate: date,
      status: status,
      blockedById: blockedById,
      sortOrder: sortOrder,
    );
  }
}

class TaskFormNotifier extends Notifier<TaskFormState> {
  @override
  TaskFormState build() {
    return const TaskFormState();
  }

  void setTitle(String value) {
    state = state.copyWith(title: value);
  }

  void setDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setDueDate(DateTime date) {
    state = state.copyWith(dueDate: date);
  }

  void setStatus(TaskStatus status) {
    state = state.copyWith(status: status);
  }

  void setBlockedById(String? blockedById) {
    state = state.copyWith(
      blockedById: blockedById,
      clearBlockedById: blockedById == null,
    );
  }

  void hydrateFromTask(Task task) {
    state = TaskFormState(
      title: task.title,
      description: task.description ?? '',
      dueDate: task.dueDate,
      status: task.status,
      blockedById: task.blockedById,
      sortOrder: task.sortOrder,
    );
  }

  void hydrateFromDraft(TaskFormState draft) {
    state = draft;
  }

  void reset() {
    state = const TaskFormState();
  }
}

final taskFormProvider =
    NotifierProvider<TaskFormNotifier, TaskFormState>(TaskFormNotifier.new);

final draftProvider = FutureProvider.autoDispose<TaskFormState?>((ref) async {
  final repo = ref.watch(draftRepositoryProvider);
  final draftJson = await repo.readDraft();
  if (draftJson == null) {
    return null;
  }
  return TaskFormState.fromDraftJson(draftJson);
});
