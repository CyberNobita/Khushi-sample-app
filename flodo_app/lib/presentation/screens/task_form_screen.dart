import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/entities/task.dart';
import '../providers/form_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/loading_button.dart';
import '../widgets/status_chip.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key, this.taskId});

  final String? taskId;

  bool get isEditing => taskId != null;

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen>
    with WidgetsBindingObserver {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  bool _isSaving = false;
  bool _isDeleting = false;
  bool _isLoadingScreen = true;
  bool _showDraftBanner = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrap());
    });
  }

  @override
  void dispose() {
    unawaited(_persistDraft());
    WidgetsBinding.instance.removeObserver(this);
    _titleController
      ..removeListener(_onTitleChanged)
      ..dispose();
    _descriptionController
      ..removeListener(_onDescriptionChanged)
      ..dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      unawaited(_persistDraft());
    }
  }

  void _onTitleChanged() {
    ref.read(taskFormProvider.notifier).setTitle(_titleController.text);
    unawaited(_persistDraft());
  }

  void _onDescriptionChanged() {
    ref.read(taskFormProvider.notifier).setDescription(_descriptionController.text);
    unawaited(_persistDraft());
  }

  Future<void> _bootstrap() async {
    setState(() {
      _isLoadingScreen = true;
      _loadError = null;
      _showDraftBanner = false;
    });

    try {
      ref.read(taskFormProvider.notifier).reset();

      if (widget.isEditing) {
        final task = await ref.read(tasksProvider.notifier).getTaskById(widget.taskId!);
        if (task == null) {
          throw Exception('Task not found');
        }

        ref.read(taskFormProvider.notifier).hydrateFromTask(task);
        _titleController.text = task.title;
        _descriptionController.text = task.description ?? '';
      } else {
        ref.invalidate(draftProvider);
        final draft = await ref.read(draftProvider.future);
        if (draft != null) {
          ref.read(taskFormProvider.notifier).hydrateFromDraft(draft);
          _titleController.text = draft.title;
          _descriptionController.text = draft.description;
          _showDraftBanner = true;
        }
      }
    } catch (error) {
      _loadError = error.toString();
    }

    if (mounted) {
      setState(() {
        _isLoadingScreen = false;
      });
    }
  }

  Future<void> _persistDraft() async {
    if (widget.isEditing) {
      return;
    }
    final formState = ref.read(taskFormProvider);
    await ref.read(draftRepositoryProvider).saveDraft(formState.toDraftJson());
  }

  Future<void> _clearDraft() async {
    await ref.read(draftRepositoryProvider).clearDraft();
    ref.read(taskFormProvider.notifier).reset();
    _titleController.clear();
    _descriptionController.clear();
    if (!mounted) {
      return;
    }
    setState(() {
      _showDraftBanner = false;
    });
  }

  Future<void> _pickDueDate() async {
    final form = ref.read(taskFormProvider);
    final now = DateTime.now();
    final initialDate = form.dueDate ?? now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 10),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context)
                .colorScheme
                .copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      ref.read(taskFormProvider.notifier).setDueDate(selectedDate);
      unawaited(_persistDraft());
    }
  }

  Future<void> _handleSave() async {
    final formState = ref.read(taskFormProvider);
    if (!formState.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title aur due date required hai.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dto = formState.toUpsertDto();
      final notifier = ref.read(tasksProvider.notifier);

      if (widget.isEditing) {
        await notifier.updateTask(widget.taskId!, dto);
      } else {
        await notifier.createTask(dto);
      }

      if (!widget.isEditing) {
        await ref.read(draftRepositoryProvider).clearDraft();
      }
      ref.read(taskFormProvider.notifier).reset();

      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _handleDelete() async {
    if (!widget.isEditing || widget.taskId == null) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Task?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    try {
      await ref.read(tasksProvider.notifier).deleteTask(widget.taskId!);
      if (mounted) {
        context.pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(taskFormProvider);
    final tasks = ref.watch(tasksProvider).valueOrNull ?? const <Task>[];
    final blockerOptions = tasks
        .where((task) => task.id != widget.taskId)
        .toList(growable: false);

    final selectedBlockedId = blockerOptions.any(
      (task) => task.id == formState.blockedById,
    )
        ? formState.blockedById
        : null;

    return PopScope<void>(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          return;
        }
        unawaited(_persistDraft());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.isEditing ? 'Edit Task' : 'New Task'),
          actions: [
            if (widget.isEditing)
              IconButton(
                onPressed: _isDeleting ? null : _handleDelete,
                icon: _isDeleting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.delete_outline),
              ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: LoadingButton(
            label: widget.isEditing ? 'Update Task' : 'Save Task',
            loading: _isSaving,
            onPressed: _handleSave,
          ),
        ),
        body: _isLoadingScreen
            ? const Center(child: CircularProgressIndicator())
            : _loadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _loadError!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _bootstrap,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    children: [
                      if (!widget.isEditing && _showDraftBanner)
                        Container(
                          margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF2CC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Unsaved draft restored successfully.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              TextButton(
                                onPressed: _clearDraft,
                                child: const Text('Clear'),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _showDraftBanner = false;
                                  });
                                },
                                icon: const Icon(Icons.close, size: 18),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            TextField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                labelText: 'Task Title *',
                              ),
                              maxLines: 1,
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                              minLines: 4,
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _pickDueDate,
                              borderRadius: BorderRadius.circular(12),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Due Date *',
                                ),
                                child: Text(
                                  formState.dueDate == null
                                      ? 'Select due date *'
                                      : DateFormat('MMM dd, yyyy').format(formState.dueDate!),
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<TaskStatus>(
                              key: ValueKey('status-${formState.status.apiValue}'),
                              initialValue: formState.status,
                              decoration: const InputDecoration(labelText: 'Status'),
                              items: TaskStatus.values
                                  .map(
                                    (status) => DropdownMenuItem<TaskStatus>(
                                      value: status,
                                      child: Row(
                                        children: [
                                          StatusChip(status: status),
                                          const SizedBox(width: 8),
                                          Text(status.label),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                              onChanged: (status) {
                                if (status == null) {
                                  return;
                                }
                                ref.read(taskFormProvider.notifier).setStatus(status);
                                unawaited(_persistDraft());
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String?>(
                              key: ValueKey('blocked-${selectedBlockedId ?? 'none'}'),
                              initialValue: selectedBlockedId,
                              decoration: InputDecoration(
                                labelText: 'Blocked By',
                                helperText: blockerOptions.isEmpty
                                    ? 'No other tasks exist to block against.'
                                    : null,
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('None'),
                                ),
                                ...blockerOptions.map(
                                  (task) => DropdownMenuItem<String?>(
                                    value: task.id,
                                    child: Text(task.title),
                                  ),
                                ),
                              ],
                              onChanged: blockerOptions.isEmpty
                                  ? null
                                  : (value) {
                                      ref
                                          .read(taskFormProvider.notifier)
                                          .setBlockedById(value);
                                      unawaited(_persistDraft());
                                    },
                            ),
                            const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
