import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo/provider/StatusNotifier.dart';
import 'package:todo/provider/ThemeChangeNotifier.dart';
import 'package:todo/provider/TodoFilterNotifier.dart';
import 'package:todo/utility/CustomList.dart';

import 'Database/HiveHelper.dart';
import 'Pages/AddToDo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ToDoAdapter());
  await Hive.openBox<ToDo>("Todobox");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeChangeNotifier()),
        ChangeNotifierProvider(create: (context) => TodoFilterNotifier()),
        ChangeNotifierProvider(create: (context) => StatusNotifier()),
      ],
      child: Builder(
        builder: (context) {
          final themeChanger = Provider.of<ThemeChangeNotifier>(context);
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'ToDo',
            themeMode: themeChanger.themeMode,
            theme: ThemeData(
              useMaterial3: true,

              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ).copyWith(
                surface: Colors.white,
                onSurface: Colors.black,
                secondaryContainer: Colors.grey.shade200,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
              ).copyWith(
                surface: Colors.black,
                onSurface: Colors.white,
                secondaryContainer: Colors.grey.shade700,
              ),
            ),
            home: HomePage(),
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> todos = [];
  @override
  void initState() {
    super.initState();
    todos.addAll(HiveHelper.getAllTodo());
  }

  @override
  Widget build(BuildContext context) {
    final themeChanger = Provider.of<ThemeChangeNotifier>(context);
    final filterChanger = Provider.of<TodoFilterNotifier>(context);
    final _dark = themeChanger.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text("TODO"),
        actions: [
          GestureDetector(
            onTap: () {
              _dark
                  ? themeChanger.setTheme(ThemeMode.light)
                  : themeChanger.setTheme(ThemeMode.dark);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              width: 80,
              height: 40,
              alignment: _dark ? Alignment.centerRight : Alignment.centerLeft,
              decoration: BoxDecoration(
                color: _dark ? Color(0xff092c3f) : Color(0xfff2e3ac),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                _dark ? Icons.dark_mode_sharp : Icons.light_mode_sharp,
                color: _dark ? Color(0xff32aeec) : Color(0xffeeb83a),
                size: 28,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Radio(
                  value: FilterCategory.all,
                  groupValue: filterChanger.currentFilterCategory,
                  onChanged: (value) => filterChanger.setFilterCategory(value!),
                ),
                const Text("All", style: TextStyle(fontSize: 17)),
                Radio(
                  value: FilterCategory.completed,
                  groupValue: filterChanger.currentFilterCategory,
                  onChanged: (value) => filterChanger.setFilterCategory(value!),
                ),
                const Text("Completed", style: TextStyle(fontSize: 17)),
                Radio(
                  value: FilterCategory.pending,
                  groupValue: filterChanger.currentFilterCategory,
                  onChanged: (value) => filterChanger.setFilterCategory(value!),
                ),
                const Text("Pending", style: TextStyle(fontSize: 17)),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<TodoFilterNotifier>(
                builder: (context, todoFilterNotifier, child) {
                  return Consumer<StatusNotifier>(
                    builder: (context, statusNotifier, child) {
                      var todo = todos;
                      if (todoFilterNotifier.currentFilterCategory ==
                          FilterCategory.completed) {
                        todo =
                            todos
                                .where(
                                  (element) =>
                                      element["status"] ==
                                      Status.completed.toString(),
                                )
                                .toList();
                      } else if (todoFilterNotifier.currentFilterCategory ==
                          FilterCategory.pending) {
                        todo =
                            todos
                                .where(
                                  (element) =>
                                      element["status"] ==
                                      Status.pending.toString(),
                                )
                                .toList();
                      }

                      return ListView.builder(
                        itemCount: todo.length,
                        itemBuilder: (context, index) {
                          return Card(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey.shade200
                                    : Theme.of(
                                      context,
                                    ).colorScheme.secondaryContainer,
                            elevation: 5,
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,

                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            todo[index]["title"],
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            todo[index]["description"],
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          Text(
                                            DateFormat('dd MMM yyyy, h:mm a')
                                                .format(todo[index]["datetime"])
                                                .toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        width: 80,
                                        alignment: Alignment.center,
                                        child:
                                            todo[index]["status"] ==
                                                    Status.completed.toString()
                                                ? const Text(
                                                  "Completed",
                                                  style: TextStyle(
                                                    color: Colors.green,
                                                  ),
                                                )
                                                : Column(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () async {
                                                        await HiveHelper.updateTodoStatus(
                                                          todo[index]["key"],
                                                          Status.completed,
                                                        );
                                                        statusNotifier
                                                            .setStatus(
                                                              Status.completed,
                                                            );
                                                        todos.clear();
                                                        todos.addAll(
                                                          HiveHelper.getAllTodo(),
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.check,
                                                        color: Colors.green,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        var result =
                                                            await HiveHelper.deleteTodo(
                                                              todo[index]["key"],
                                                            );
                                                        statusNotifier
                                                            .setStatus(
                                                              Status.deleted,
                                                            );
                                                        todos.clear();
                                                        todos.addAll(
                                                          HiveHelper.getAllTodo(),
                                                        );
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: SizedBox(
        height: 45,
        width: 105,
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => AddToDoScreen()));
            setState(() {
              todos.clear();
              todos.addAll(HiveHelper.getAllTodo());
            });
          },
          child: Container(
            width: 85,
            alignment: Alignment.center,
            child: const Row(children: [Icon(Icons.add), Text("new todo")]),
          ),
        ),
      ),
    );
  }
}
