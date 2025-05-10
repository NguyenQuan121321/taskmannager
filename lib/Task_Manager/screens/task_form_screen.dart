```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';

class TaskFormScreen extends StatefulWidget {
  final TaskModel? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  String _status = 'To do';
  int _priority = 1;
  DateTime? _dueDate;
  String _assignedTo = '';
  String _category = 'Work';
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _title = widget.task!.title;
      _description = widget.task!.description;
      _status = widget.task!.status;
      _priority = widget.task!.priority;
      _dueDate = widget.task!.dueDate;
      _assignedTo = widget.task!.assignedTo;
      _category = widget.task!.category ?? 'Work';
      _completed = widget.task!.completed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final taskService = TaskService();
    final user = authService.user!;
    _assignedTo = user.id; // Gán người dùng hiện tại làm người được giao nhiệm vụ

    return Scaffold(
      appBar: AppBar(title: Text(widget.task == null ? 'Create Task' : 'Edit Task')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Title'),
                initialValue: _title,
                validator: (value) => value!.isEmpty ? 'Enter title' : null,
                onChanged: (value) => _title = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                initialValue: _description,
                validator: (value) => value!.isEmpty ? 'Enter description' : null,
                onChanged: (value) => _description = value,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Status'),
                value: _status,
                items: ['To do', 'In progress', 'Done', 'Cancelled']
                    .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _status = value!),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Priority'),
                value: _priority,
                items: [
                  DropdownMenuItem(value: 1, child: Text('Low')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('High')),
                ],
                onChanged: (value) => setState(() => _priority = value!),
              ),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _dueDate = picked);
                },
                child: Text(_dueDate == null ? 'Pick Due Date' : _dueDate!.toString()),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                value: _category,
                items: ['Work', 'Personal', 'Other']
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              SwitchListTile(
                title: Text('Completed'),
                value: _completed,
                onChanged: (value) => setState(() => _completed = value),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      final task = TaskModel(
                        id: widget.task?.id ?? Uuid().v4(),
                        title: _title,
                        description: _description,
                        status: _status,
                        priority: _priority,
                        dueDate: _dueDate,
                        assignedTo: _assignedTo,
                        createdBy: user.id,
                        category: _category,
                        completed: _completed,
                      );
                      if (widget.task == null) {
                        await taskService.createTask(task);
                      } else {
                        await taskService.updateTask(task);
                      }
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                    }
                  }
                },
                child: Text(widget.task == null ? 'Create' : 'Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```