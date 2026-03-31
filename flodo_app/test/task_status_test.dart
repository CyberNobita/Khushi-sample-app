import 'package:flodo_app/domain/entities/task.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('TaskStatus api mapping is stable', () {
    expect(TaskStatusX.fromApi('todo'), TaskStatus.todo);
    expect(TaskStatusX.fromApi('in_progress'), TaskStatus.inProgress);
    expect(TaskStatusX.fromApi('done'), TaskStatus.done);
    expect(TaskStatus.inProgress.apiValue, 'in_progress');
    expect(TaskStatus.done.label, 'Done');
  });
}
