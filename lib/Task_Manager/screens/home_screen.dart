```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/task_service.dart';
import '../models/task_model.dart';
import 'task_form_screen.dart';
import 'task_detail_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  String? _statusFilter;
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final taskService = TaskService();
    final user = authService.user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
            },
          ),
        ],
      ),
      body: FutureBuilder<List<TaskModel>>(
        future: taskService.getTasks(user.id, user.isAdmin),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          var tasks = snapshot.data ?? [];
          if (_searchQuery.isNotEmpty || _statusFilter != null || _categoryFilter != null) {
            tasks = taskService.searchTasks(user.id, user.isAdmin, _searchQuery, _statusFilter, _categoryFilter);
          }
          return Column(
            children: [
              Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  decoration: InputDecoration(labelText: 'Search Tasks', prefixIcon: Icon(Icons.search)),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Status'),
                      value: _statusFilter,
                      items: ['To do', 'In progress', 'Done', 'Cancelled']
                          .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                          .toList(),
                      onChanged: (value) => setState(() => _statusFilter = value),
                    ),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      hint: Text('Category'),
                      value: _categoryFilter,
                      items: ['Work', 'Personal', 'Other']
                          .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                          .toList(),
                      onChanged: (value) => setState(() => _categoryFilter = value),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return ListTile(
                      title: Text(task.title),
                      subtitle: Text('Status: ${task.status} | Priority: ${task.priority}'),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await taskService.deleteTask(task.id);
                          setState(() {});
                        },
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskFormScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}
```