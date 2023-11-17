import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasks_app/test.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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
  }

  Future<void> saveTasks() async {
    List<String> taskStrings =
        taskList.tasks.map((task) => task.title).toList();
    await prefs.setStringList('tasks', taskStrings);
  }

  TextEditingController taskCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Task app',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.blue,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Text(
                    'Add your tasks',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black54,
                    ),
                  ),
                  ElevatedButton.icon(
                    style: const ButtonStyle(
                      foregroundColor: MaterialStatePropertyAll(Colors.blue),
                    ),
                    onPressed: () {
                      _showAddTaskDialog();
                    },
                    icon: const Icon(
                      Icons.add,
                      size: 20,
                    ),
                    label: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
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
            ),
          ],
        ),
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
              style: const ButtonStyle(
                foregroundColor: MaterialStatePropertyAll(Colors.blue),
              ),
              onPressed: () {
                setState(() {
                  taskList.tasks.add(Task(title: taskController.text));
                  saveTasks();
                  Navigator.pop(context);
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

  const TaskTile({
    super.key,
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
