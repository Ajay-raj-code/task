import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo/utility/CustomList.dart';

part 'HiveHelper.g.dart';

@HiveType(typeId: 0)
class ToDo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime datetime;

  @HiveField(3)
  String status;

  ToDo({
    required this.title,
    required this.description,
    required this.datetime,
    required this.status,
  });
}

class HiveHelper {
  static final hiveBox = Hive.box<ToDo>("Todobox");

  static bool isInitialized = false;

  static Future<void> init() async {
    if (!isInitialized) {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(ToDoAdapter());
      }
      await Hive.openBox<ToDo>('Todobox');
      isInitialized = true;
    }
  }

  static createTodo(ToDo todo) async {
   return await hiveBox.add(todo);
  }

  static dynamic getAllTodo() {
    final todos = hiveBox.values;
    var value =
        todos
            .map(
              (e) => {
                "key": e.key,
                "title": e.title,
                "description": e.description,
                "datetime": e.datetime,
                "status": e.status,
              },
            )
            .toList()
            .reversed;
    return value;
  }

  static deleteTodo(int key) async {
    return await hiveBox.delete(key);
  }

  static updateTodoStatus(int key, Status newStatus) async {
    var todo = hiveBox.get(key);
    if (todo != null) {
      todo.status = newStatus.toString();
      await todo.save();
    }
  }
}
