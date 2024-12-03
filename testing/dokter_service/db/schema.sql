CREATE TABLE dokters (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  password_digest TEXT NOT NULL,
  specialization TEXT NOT NULL
);
