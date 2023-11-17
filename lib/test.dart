import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  bool isDone;

  Task({required this.title, this.isDone = false});
}

class TaskList {
  List<Task> tasks = [];
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task List',
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late TaskList taskList;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    taskList = TaskList();
    loadTasks();
  }

  Future<void> loadTasks() async {
    prefs = await SharedPreferences.getInstance();
    List<String>? taskStrings = prefs.getStringList('tasks');

    if (taskStrings != null) {
      taskList.tasks = taskStrings.map((task) => Task(title: task)).toList();
    }

    setState(() {}); // Rebuild the UI
  }

  Future<void> saveTasks() async {
    List<String> taskStrings =
        taskList.tasks.map((task) => task.title).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
      ),
      body: ListView.builder(
        itemCount: taskList.tasks.length,
        itemBuilder: (context, index) {
          return TaskTile(
            task: taskList.tasks[index],
            onCheckboxChanged: (value) {
              setState(() {
                taskList.tasks[index].isDone = value!;
                saveTasks();
              });
            },
            onDeletePressed: () {
              setState(() {
                taskList.tasks.removeAt(index);
                saveTasks();
              });
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showAddTaskDialog() async {
    TextEditingController taskController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(
              hintText: 'Enter your task...',
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  taskList.tasks.add(Task(title: taskController.text));
                  saveTasks();
                  Navigator.pop(context); // Close the dialog
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class TaskTile extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onCheckboxChanged;
  final VoidCallback onDeletePressed;

  TaskTile({
    required this.task,
    required this.onCheckboxChanged,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(task.title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: task.isDone,
            onChanged: onCheckboxChanged,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: onDeletePressed,
          ),
        ],
      ),
    );
  }
}
