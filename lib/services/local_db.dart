import 'package:hive/hive.dart';
import 'package:todo/constants/app_constants.dart';
import 'package:todo/model/todo_model.dart';

class LocalDbService {
  Future<void> saveData(Todo value) async {
    final box = Hive.box<Todo>(AppConstants.boxName);

    try {
      // final uid = const Uuid().v1();
      await box.put(value.key, value);
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateData(String key, Todo value) async {
    final box = Hive.box<Todo>(AppConstants.boxName);

    try {
      await box.put(key, value);
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteData(String key) async {
    final box = Hive.box<Todo>(AppConstants.boxName);

    try {
      await box.delete(key);
    } catch (e) {
      print(e);
    }
  }
}
