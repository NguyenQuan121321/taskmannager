```javascript
const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('task_manager.db', (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database');
    db.run(`CREATE TABLE IF NOT EXISTS users (
      id TEXT PRIMARY KEY,
      username TEXT NOT NULL,
      email TEXT NOT NULL,
      password TEXT NOT NULL,
      isAdmin INTEGER NOT NULL
    )`);
    db.run(`CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      description TEXT NOT NULL,
      status TEXT NOT NULL,
      priority INTEGER NOT NULL,
      dueDate TEXT,
      assignedTo TEXT NOT NULL,
      createdBy TEXT NOT NULL,
      category TEXT,
      completed INTEGER NOT NULL
    )`);
  }
});

module.exports = db;
```