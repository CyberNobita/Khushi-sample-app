import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../presentation/screens/task_form_screen.dart';
import '../presentation/screens/task_list_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const TaskListScreen(),
      ),
      GoRoute(
        path: '/tasks/new',
        builder: (context, state) => const TaskFormScreen(),
      ),
      GoRoute(
        path: '/tasks/:taskId/edit',
        builder: (context, state) {
          final taskId = state.pathParameters['taskId'];
          if (taskId == null || taskId.isEmpty) {
            return const TaskListScreen();
          }
          return TaskFormScreen(taskId: taskId);
        },
      ),
    ],
  );
});
