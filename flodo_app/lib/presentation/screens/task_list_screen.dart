import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';
import '../../domain/entities/task.dart';
import '../providers/filter_provider.dart';
import '../providers/tasks_provider.dart';
import '../widgets/task_card.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(filterProvider);
    _searchController = TextEditingController(text: filter.searchQuery);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      final current = ref.read(filterProvider);
      ref.read(filterProvider.notifier).state = current.copyWith(searchQuery: value);
    });
  }

  void _onFilterChanged(TaskStatus? status) {
    final current = ref.read(filterProvider);
    ref.read(filterProvider.notifier).state =
        current.copyWith(status: status, clearStatus: status == null);
  }

  int _gridColumns(double width, bool isMobile) {
    if (isMobile) {
      return width < 380 ? 1 : 2;
    }
    if (width >= 1180) {
      return 3;
    }
    return 2;
  }

  double _gridRatio(double width, bool isMobile) {
    if (isMobile) {
      return width < 380 ? 1.45 : 0.52;
    }
    if (width >= 1180) {
      return 0.98;
    }
    return 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(filterProvider);
    final tasksState = ref.watch(tasksProvider);

    final width = MediaQuery.sizeOf(context).width;
    final isMobile = width < 760;

    return Scaffold(
      backgroundColor: isMobile ? const Color(0xFFF1F3F8) : const Color(0xFF06090F),
      floatingActionButtonLocation:
          isMobile ? FloatingActionButtonLocation.centerFloat : null,
      floatingActionButton: isMobile
          ? Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: FloatingActionButton(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                elevation: 8,
                onPressed: () => context.push('/tasks/new'),
                child: const Icon(Icons.add, size: 34),
              ),
            )
          : null,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isMobile ? width : 1520),
            child: Padding(
              padding: EdgeInsets.fromLTRB(isMobile ? 0 : 18, isMobile ? 0 : 26, isMobile ? 0 : 18, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isMobile ? 0 : 18),
                child: Container(
                  color: const Color(0xFFF1F3F8),
                  child: Column(
                    children: [
                      _TopBar(
                        mobile: isMobile,
                        maxWidth: width,
                        onCreateTap: () => context.push('/tasks/new'),
                      ),
                      _FiltersBar(
                        mobile: isMobile,
                        maxWidth: width,
                        searchController: _searchController,
                        currentFilter: filter.status,
                        onSearchChanged: _onSearchChanged,
                        onFilterChanged: _onFilterChanged,
                      ),
                      Expanded(
                        child: tasksState.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (error, _) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline, color: AppColors.accent, size: 34),
                                    const SizedBox(height: 10),
                                    Text(
                                      error.toString(),
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    const SizedBox(height: 14),
                                    ElevatedButton(
                                      onPressed: () => ref.invalidate(tasksProvider),
                                      child: const Text('Try Again'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          data: (tasks) {
                            if (tasks.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 66,
                                        color: AppColors.primary.withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(height: 16),
                                      Text('No tasks yet', style: Theme.of(context).textTheme.titleLarge),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap + to create your first task.',
                                        style: Theme.of(context).textTheme.bodyLarge,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(
                                    isMobile ? 14 : 22,
                                    16,
                                    isMobile ? 14 : 22,
                                    4,
                                  ),
                                  child: _SectionLabel(total: tasks.length, mobile: isMobile),
                                ),
                                Expanded(
                                  child: RefreshIndicator(
                                    onRefresh: () async {
                                      ref.invalidate(tasksProvider);
                                      await ref.read(tasksProvider.future);
                                    },
                                    child: GridView.builder(
                                      padding: EdgeInsets.fromLTRB(
                                        isMobile ? 14 : 22,
                                        6,
                                        isMobile ? 14 : 22,
                                        isMobile ? 130 : 26,
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: _gridColumns(width, isMobile),
                                        crossAxisSpacing: isMobile ? 10 : 14,
                                        mainAxisSpacing: isMobile ? 12 : 14,
                                        childAspectRatio: _gridRatio(width, isMobile),
                                      ),
                                      itemCount: tasks.length,
                                      itemBuilder: (context, index) {
                                        final task = tasks[index];
                                        return TaskCard(task: task, searchQuery: filter.searchQuery);
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.mobile,
    required this.maxWidth,
    required this.onCreateTap,
  });

  final bool mobile;
  final double maxWidth;
  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    final showCreateButton = !mobile && maxWidth > 920;

    return Container(
      height: mobile ? 84 : 102,
      padding: EdgeInsets.symmetric(horizontal: mobile ? 16 : 26),
      color: const Color(0xFF0B2354),
      child: Row(
        children: [
          _FlodoWordmark(compact: mobile),
          const Spacer(),
          if (showCreateButton)
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                backgroundColor: const Color(0xFF102A61),
                foregroundColor: const Color(0xFF06142D),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onCreateTap,
              icon: const Icon(Icons.add, color: Color(0xFF06142D)),
              label: Text(
                'New Task',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF06142D),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          if (showCreateButton) const SizedBox(width: 14),
          Container(
            width: mobile ? 40 : 52,
            height: mobile ? 40 : 52,
            decoration: const BoxDecoration(
              color: Color(0xFF2A4A82),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              'AK',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersBar extends StatelessWidget {
  const _FiltersBar({
    required this.mobile,
    required this.maxWidth,
    required this.searchController,
    required this.currentFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final bool mobile;
  final double maxWidth;
  final TextEditingController searchController;
  final TaskStatus? currentFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TaskStatus?> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        color: Colors.white,
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: DropdownButtonFormField<TaskStatus?>(
                key: ValueKey('status-${currentFilter?.apiValue ?? 'all'}'),
                initialValue: currentFilter,
                decoration: const InputDecoration(isDense: true),
                items: [
                  const DropdownMenuItem<TaskStatus?>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...TaskStatus.values.map(
                    (status) => DropdownMenuItem<TaskStatus?>(
                      value: status,
                      child: Text(status.label),
                    ),
                  ),
                ],
                onChanged: onFilterChanged,
              ),
            ),
          ],
        ),
      );
    }

    final showStatusChip = maxWidth > 1080;

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Search tasks...',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 160,
            child: DropdownButtonFormField<TaskStatus?>(
              key: ValueKey('status-${currentFilter?.apiValue ?? 'all'}'),
              initialValue: currentFilter,
              decoration: const InputDecoration(isDense: true),
              items: [
                const DropdownMenuItem<TaskStatus?>(
                  value: null,
                  child: Text('All'),
                ),
                ...TaskStatus.values.map(
                  (status) => DropdownMenuItem<TaskStatus?>(
                    value: status,
                    child: Text(status.label),
                  ),
                ),
              ],
              onChanged: onFilterChanged,
            ),
          ),
          if (showStatusChip) ...[
            const SizedBox(width: 12),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF86BDE1), width: 1.4),
                color: const Color(0xFFDDEFFC),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2E8FD1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentFilter?.label ?? 'In Progress',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: const Color(0xFF2D7FB8),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({
    required this.total,
    required this.mobile,
  });

  final int total;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        mobile ? '$total TASKS' : 'ALL TASKS - $total',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              letterSpacing: 1.2,
              color: const Color(0xFF75818F),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _FlodoWordmark extends StatelessWidget {
  const _FlodoWordmark({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'flo',
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 24 : 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'do',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: compact ? 24 : 42,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
