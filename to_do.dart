import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do App',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      home: TodoScreen(),
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Map<String, dynamic>> _tasks = [];
  String _filter = 'All'; // Фильтр (барлығы, орындалған, орындалмаған)

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // SharedPreferences арқылы деректерді сақтау
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(_tasks));
  }

  // SharedPreferences арқылы деректерді жүктеу
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      setState(() {
        _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasksString));
      });
    }
  }

  // Тапсырма қосу
  void _addTask(String title, String description, DateTime? dueDate) {
    setState(() {
      _tasks.add({
        'title': title,
        'description': description,
        'dueDate': dueDate?.toIso8601String(),
        'isDone': false,
      });
      _saveTasks();
    });
  }

  // Тапсырманы өңдеу
  void _editTask(int index, String title, String description, DateTime? dueDate) {
    setState(() {
      _tasks[index]['title'] = title;
      _tasks[index]['description'] = description;
      _tasks[index]['dueDate'] = dueDate?.toIso8601String();
      _saveTasks();
    });
  }

  // Тапсырма күйін ауыстыру
  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
      _saveTasks();
    });
  }

  // Тапсырманы жою
  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      _saveTasks();
    });
  }

  // Тапсырма қосу/өңдеу диалогы
  void _showTaskDialog({int? index}) {
    final isEditing = index != null;
    final TextEditingController titleController = TextEditingController(
      text: isEditing ? _tasks[index]['title'] : '',
    );
    final TextEditingController descriptionController = TextEditingController(
      text: isEditing ? _tasks[index]['description'] : '',
    );
    DateTime? dueDate = isEditing && _tasks[index]['dueDate'] != null
        ? DateTime.parse(_tasks[index]['dueDate'])
        : null;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Task' : 'Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Task Title'),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Task Description'),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(dueDate == null
                      ? 'No due date'
                      : 'Due: ${dueDate?.toLocal().toString().split(' ')[0]}'),
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      dueDate = await showDatePicker(
                        context: context,
                        initialDate: dueDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      setState(() {});
                    },
                    child: Text('Set Due Date'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (isEditing) {
                  _editTask(index!, titleController.text,
                      descriptionController.text, dueDate);
                } else {
                  _addTask(
                      titleController.text, descriptionController.text, dueDate);
                }
                Navigator.pop(context);
              },
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Фильтр қолдану
    final filteredTasks = _filter == 'All'
        ? _tasks
        : _tasks.where((task) {
      return _filter == 'Completed'
          ? task['isDone']
          : !task['isDone'];
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All Tasks')),
              PopupMenuItem(value: 'Completed', child: Text('Completed')),
              PopupMenuItem(value: 'Pending', child: Text('Pending')),
            ],
          ),
        ],
      ),
      body: filteredTasks.isEmpty
          ? Center(child: Text('No tasks found'))
          : ListView.builder(
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return Dismissible(
            key: UniqueKey(),
            onDismissed: (_) {
              _deleteTask(index);
            },
            child: Card(
              margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              child: ListTile(
                onLongPress: () => _showTaskDialog(index: index),
                leading: Checkbox(
                  value: task['isDone'],
                  onChanged: (value) {
                    _toggleTask(index);
                  },
                ),
                title: Text(
                  task['title'],
                  style: TextStyle(
                    decoration: task['isDone']
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (task['description'] != null &&
                        task['description'].isNotEmpty)
                      Text(task['description']),
                    if (task['dueDate'] != null)
                      Text('Due: ${DateTime.parse(task['dueDate']).toLocal().toString().split(' ')[0]}'),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTaskDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}
