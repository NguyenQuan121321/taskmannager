```javascript
const express = require('express');
const db = require('./db');
const app = express();
const port = 3000;

app.use(express.json());

// API cho đăng ký người dùng
app.post('/api/users/register', (req, res) => {
  const { username, email, password } = req.body;
  const id = Date.now().toString();
  const isAdmin = false;
  db.run(
    'INSERT INTO users (id, username, email, password, isAdmin) VALUES (?, ?, ?, ?, ?)',
    [id, username, email, password, isAdmin],
    (err) => {
      if (err) {
        res.status(400).json({ error: err.message });
        return;
      }
      res.status(201).json({ id, username, email, isAdmin });
    }
  );
});

// API cho đăng nhập
app.post('/api/users/login', (req, res) => {
  const { email, password } = req.body;
  db.get(
    'SELECT * FROM users WHERE email = ? AND password = ?',
    [email, password],
    (err, row) => {
      if (err) {
        res.status(400).json({ error: err.message });
        return;
      }
      if (!row) {
        res.status(401).json({ error: 'Invalid email or password' });
        return;
      }
      res.status(200).json(row);
    }
  );
});

// API lấy danh sách nhiệm vụ
app.get('/api/tasks', (req, res) => {
  const { search, status, category } = req.query;
  let query = 'SELECT * FROM tasks';
  const params = [];
  let conditions = [];

  if (search) {
    conditions.push('(title LIKE ? OR description LIKE ?)');
    params.push(`%${search}%`, `%${search}%`);
  }
  if (status) {
    conditions.push('status = ?');
    params.push(status);
  }
  if (category) {
    conditions.push('category = ?');
    params.push(category);
  }

  if (conditions.length > 0) {
    query += ' WHERE ' + conditions.join(' AND ');
  }

  db.all(query, params, (err, rows) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.status(200).json(rows);
  });
});

// API lấy chi tiết nhiệm vụ
app.get('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  db.get('SELECT * FROM tasks WHERE id = ?', [id], (err, row) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    if (!row) {
      res.status(404).json({ error: 'Task not found' });
      return;
    }
    res.status(200).json(row);
  });
});

// API tạo nhiệm vụ
app.post('/api/tasks', (req, res) => {
  const { title, description, status, priority, dueDate, assignedTo, createdBy, category, completed } = req.body;
  const id = Date.now().toString();
  db.run(
    'INSERT INTO tasks (id, title, description, status, priority, dueDate, assignedTo, createdBy, category, completed) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
    [id, title, description, status, priority, dueDate, assignedTo, createdBy, category, completed],
    (err) => {
      if (err) {
        res.status(400).json({ error: err.message });
        return;
      }
      res.status(201).json({ id, title, description, status, priority, dueDate, assignedTo, createdBy, category, completed });
    }
  );
});

// API cập nhật nhiệm vụ
app.put('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  const { title, description, status, priority, dueDate, assignedTo, createdBy, category, completed } = req.body;
  db.run(
    'UPDATE tasks SET title = ?, description = ?, status = ?, priority = ?, dueDate = ?, assignedTo = ?, createdBy = ?, category = ?, completed = ? WHERE id = ?',
    [title, description, status, priority, dueDate, assignedTo, createdBy, category, completed, id],
    (err) => {
      if (err) {
        res.status(400).json({ error: err.message });
        return;
      }
      res.status(200).json({ id, title, description, status, priority, dueDate, assignedTo, createdBy, category, completed });
    }
  );
});

// API xóa nhiệm vụ
app.delete('/api/tasks/:id', (req, res) => {
  const { id } = req.params;
  db.run('DELETE FROM tasks WHERE id = ?', [id], (err) => {
    if (err) {
      res.status(400).json({ error: err.message });
      return;
    }
    res.status(200).json({ message: 'Task deleted' });
  });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});
```