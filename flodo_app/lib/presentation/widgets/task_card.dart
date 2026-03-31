import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme.dart';
import '../../domain/entities/task.dart';
import 'highlighted_text.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.searchQuery,
  });

  final Task task;
  final String searchQuery;

  Color get _accentColor {
    if (task.isBlocked) {
      return const Color(0xFFD16A64);
    }

    switch (task.status) {
      case TaskStatus.todo:
        return const Color(0xFFAEBAC7);
      case TaskStatus.inProgress:
        return const Color(0xFF2F8FD1);
      case TaskStatus.done:
        return const Color(0xFF1FAF67);
    }
  }

  double get _progressValue {
    if (task.isBlocked) {
      return 0.0;
    }

    switch (task.status) {
      case TaskStatus.todo:
        return 0.35;
      case TaskStatus.inProgress:
        return 0.58;
      case TaskStatus.done:
        return 1.0;
    }
  }

  String get _statusLabel {
    if (task.isBlocked) {
      return 'BLOCKED';
    }
    return task.status.label.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push('/tasks/${task.id}/edit'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFD3D9E3), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: task.isBlocked ? 0.64 : 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: HighlightedText(
                              text: task.title,
                              query: searchQuery,
                              style: textTheme.titleLarge?.copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF182A4C),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.more_horiz,
                            size: 20,
                            color: Color(0xFF93A1B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        task.description?.trim().isEmpty ?? true
                            ? 'No description provided yet.'
                            : task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          height: 1.3,
                          color: const Color(0xFF607085),
                        ),
                      ),
                      const Spacer(),
                      _StatusPill(
                        label: _statusLabel,
                        accent: _accentColor,
                        blocked: task.isBlocked,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 15,
                            color: task.isBlocked
                                ? AppColors.accent
                                : const Color(0xFFA0ABB9),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(task.dueDate),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 13,
                              color: task.isBlocked
                                  ? AppColors.accent
                                  : const Color(0xFF8A95A5),
                              fontWeight:
                                  task.isBlocked ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          if (task.isBlocked) ...[
                            const SizedBox(width: 4),
                            Text(
                              '!',
                              style: textTheme.bodySmall?.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          height: 5,
                          child: Stack(
                            children: [
                              Container(color: const Color(0xFFE7ECF3)),
                              FractionallySizedBox(
                                widthFactor: _progressValue,
                                child: Container(color: _accentColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (task.isBlocked && task.blockedByTitle != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDECEC),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.lock,
                                size: 14,
                                color: Color(0xFFD16A64),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Blocked by: ${task.blockedByTitle}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFFD16A64),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.accent,
    required this.blocked,
  });

  final String label;
  final Color accent;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: blocked ? const Color(0xFFFDECEC) : accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12,
              letterSpacing: 0.2,
              color: blocked ? const Color(0xFFD16A64) : accent,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
