import 'package:flutter/material.dart';

import '../../domain/entities/task.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
  });

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
