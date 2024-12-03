import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Modern To-Do App',
      theme: ThemeData(
        useMaterial3: true, // Включаем Material 3
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
  final List<Map<String, dynamic>> _tasks = [];
  final TextEditingController _taskController = TextEditingController();

  void _addTask(String taskTitle) {
    if (taskTitle.isNotEmpty) {
      setState(() {
        _tasks.add({'title': taskTitle, 'isDone': false});
      });
    }
  }

  void _toggleTask(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add a new task'),
          content: TextField(
            controller: _taskController,
            decoration: InputDecoration(
              labelText: 'Task title',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Закрыть диалог
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addTask(_taskController.text);
                _taskController.clear();
                Navigator.pop(context); // Закрыть диалог
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modern To-Do App'),
      ),
      body: _tasks.isEmpty
          ? Center(
        child: Text(
          'No tasks yet! Add one using the + button.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              leading: Checkbox(
                value: _tasks[index]['isDone'],
                onChanged: (value) => _toggleTask(index),
              ),
              title: Text(
                _tasks[index]['title'],
                style: TextStyle(
                  decoration: _tasks[index]['isDone']
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}

