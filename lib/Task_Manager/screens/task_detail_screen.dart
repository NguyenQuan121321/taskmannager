```dart
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import 'task_form_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final TaskModel task;

  TaskDetailScreen({required this.task});

  @override
  Widget build(BuildContext context) {
    final taskService = TaskService();

    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TaskFormScreen(task: task)),
            ),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () async {
              await taskService.deleteTask(task.id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Description: ${task.description}', style: TextStyle(fontSize: 16)),
            Text('Status: ${task.status}', style: TextStyle(fontSize: 16)),
            Text('Priority: ${task.priority}', style: TextStyle(fontSize: 16)),
            Text('Due Date: ${task.dueDate?.toString() ?? 'None'}', style: TextStyle(fontSize: 16)),
            Text('Assigned To: ${task.assignedTo}', style: TextStyle(fontSize: 16)),
            Text('Created By: ${task.createdBy}', style: TextStyle(fontSize: 16)),
            Text('Category: ${task.category ?? 'None'}', style: TextStyle(fontSize: 16)),
            Text('Completed: ${task.completed ? 'Yes' : 'No'}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
```