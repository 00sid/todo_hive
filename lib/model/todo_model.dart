import 'package:hive/hive.dart';
part 'todo_model.g.dart';

@HiveType(typeId: 0)
class Todo {
  @HiveField(0)
  String taskName;
  @HiveField(1)
  bool isCompleted;
  @HiveField(2)
  String key;
  Todo({
    required this.taskName,
    required this.isCompleted,
    required this.key,
  });
}
