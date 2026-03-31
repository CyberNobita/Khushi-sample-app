import 'package:flodo_app/domain/entities/task.dart';
import 'package:flodo_app/presentation/providers/form_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TaskFormState', () {
    test('is invalid when title or due date is missing', () {
      const empty = TaskFormState();
      expect(empty.isValid, isFalse);

      const withTitleOnly = TaskFormState(title: 'Ship app');
      expect(withTitleOnly.isValid, isFalse);

      final withAllRequired = TaskFormState(
        title: 'Ship app',
        dueDate: DateTime(2026, 4, 5),
      );
      expect(withAllRequired.isValid, isTrue);
    });

    test('draft serialization round-trip keeps values', () {
      final original = TaskFormState(
        title: 'Design dashboard',
        description: 'Include key metrics',
        dueDate: DateTime(2026, 4, 10),
        status: TaskStatus.inProgress,
        blockedById: 'abc-123',
        sortOrder: 7,
      );

      final draftJson = original.toDraftJson();
      final restored = TaskFormState.fromDraftJson(draftJson);

      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.dueDate, original.dueDate);
      expect(restored.status, original.status);
      expect(restored.blockedById, original.blockedById);
      expect(restored.sortOrder, original.sortOrder);
    });
  });
}
