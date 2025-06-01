import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo/Database/HiveHelper.dart';
import 'package:todo/provider/TodoFilterNotifier.dart';
import 'package:todo/utility/Constant.dart';
import 'package:todo/utility/CustomList.dart';
import 'package:todo/utility/Notification.dart';

class AddToDoScreen extends StatefulWidget {
  const AddToDoScreen({super.key});

  @override
  State<AddToDoScreen> createState() => _AddToDoScreenState();
}

class _AddToDoScreenState extends State<AddToDoScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final _formkey = GlobalKey<FormState>();
  CustomScheduleNotification notificationHelper = CustomScheduleNotification();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notificationHelper.initializeNotification();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Add Todo",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          GestureDetector(
            onTap: () async {
              if (_formkey.currentState!.validate()) {
                DateTime datetime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  _selectedTime.hour,
                  _selectedTime.minute,
                );
                String title = _titleController.text.trim();
                String description = _descriptionController.text.trim();
                final todo = ToDo(
                  title: title,
                  description: description,
                  datetime: datetime,
                  status: Status.pending.toString(),
                );
                int? key = await HiveHelper.createTodo(todo);

                print(key);
                Duration duration = datetime.difference(DateTime.now());
                print(duration);
                if(!duration.isNegative){
                  await notificationHelper.showNotification(key: key!, title: title, description: description, duration: duration, key_todo: key.toString());

                }
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.grey.shade700.withAlpha(160),
                    behavior:
                    SnackBarBehavior
                        .floating,
                    margin:
                    EdgeInsets.all(
                      16,
                    ),
                    duration: Duration(
                      seconds: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    content:Text(
                      'Task is created',
                    ),
                  ),
                );
                context.read<TodoFilterNotifier>().setFilterCategory(
                  FilterCategory.all,
                );
              }
              Navigator.of(context).pop();
            },
            child: const Text(
              "SAVE",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () async {
                    final DateTime? selected = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(Duration(days: 365)),
                      initialEntryMode: DatePickerEntryMode.input,
                    );
                    if (selected != null) {
                      setState(() {
                        _selectedDate = selected;
                      });
                    }
                  },
                  child: Text(
                    DateFormat('dd MMM yyyy').format(_selectedDate).toString(),
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Text(
                  "|",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                GestureDetector(
                  onTap: () async {
                    TimeOfDay? selected = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (selected != null) {
                      setState(() {
                        _selectedTime = selected;
                      });
                    }
                  },
                  child: Text(
                    "${_selectedTime.hour} : ${_selectedTime.minute}",
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: Form(
              key: _formkey,
              child: Column(
                spacing: 12,
                children: [
                  TextFormField(
                    controller: _titleController,
                    autocorrect: true,
                    maxLines: 1,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "It's cannot be null";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Title of TODO",
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      enabledBorder: CustomConstant.border,
                      focusedBorder: CustomConstant.border,
                      errorBorder: CustomConstant.border,
                      border: CustomConstant.border,
                      focusedErrorBorder: CustomConstant.border,
                    ),
                  ),
                  TextFormField(
                    controller: _descriptionController,
                    autocorrect: true,
                    maxLines: 6,
                    minLines: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "It's cannot be null";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: "Description of TODO",
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.secondaryContainer,
                      enabledBorder: CustomConstant.border,
                      focusedBorder: CustomConstant.border,
                      errorBorder: CustomConstant.border,
                      border: CustomConstant.border,
                      focusedErrorBorder: CustomConstant.border,
                    ),
                  ),

                ],
              ),
            ),
          ),


        ],
      ),
    );
  }
}
