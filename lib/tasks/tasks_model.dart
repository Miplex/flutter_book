import 'package:flutter_book/base_model.dart';

class Task {
  int id = 0;
  String? description;
  String? dueDate;
  String completed = 'false';

  @override
  String toString() {
    return 'Tasks{id: $id, description: $description, dueData: $dueDate, completed: $completed}';
  }
}

class TasksModel extends BaseModel{}

TasksModel tasksModel = TasksModel();