import 'package:hive/hive.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo/constants/app_constants.dart';
import 'package:todo/model/todo_model.dart';
import 'package:todo/services/local_db.dart';

final providerOfTodoList = StreamProvider<List<Todo>>((ref) async* {
  // Open the Hive box
  final box = await Hive.openBox<Todo>(AppConstants.boxName);

  // Emit the initial state of the box
  yield box.values.toList();

  // Listen for changes and emit updated data
  yield* box.watch().map((_) {
    return box.values.toList();
  });
});

enum StorageStatus { initial, loading, completed, error }

//uploading, updating and deleting the data from the local storage
class StorageProvider extends StateNotifier<StorageStatus> {
  StorageProvider() : super(StorageStatus.initial);
  final dbService = LocalDbService();
  Future<void> saveData(Todo value) async {
    try {
      state = StorageStatus.loading;
      await dbService.saveData(value);
      state = StorageStatus.completed;
    } catch (e) {
      state = StorageStatus.error;
    }
  }

  Future<void> updateData(String key, Todo value) async {
    try {
      state = StorageStatus.loading;
      await dbService.updateData(key, value);
      state = StorageStatus.completed;
    } catch (e) {
      state = StorageStatus.error;
    }
  }

  Future<void> deleteData(String key) async {
    try {
      state = StorageStatus.loading;
      await dbService.deleteData(key);
      state = StorageStatus.completed;
    } catch (e) {
      state = StorageStatus.error;
    }
  }

  Future<void> toogleIsCompleted(String key, bool value) async {
    try {
      state = StorageStatus.loading;
      final box = await Hive.openBox<Todo>(AppConstants.boxName);
      final todo = box.get(key);
      await dbService.updateData(
          key,
          Todo(
            taskName: todo!.taskName,
            isCompleted: value,
            key: key,
          ));
      state = StorageStatus.completed;
    } catch (e) {
      state = StorageStatus.error;
    }
  }
}

final providerOfStorage =
    StateNotifierProvider<StorageProvider, StorageStatus>((ref) {
  return StorageProvider();
});
