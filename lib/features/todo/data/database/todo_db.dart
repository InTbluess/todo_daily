import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../model/todo_model.dart';

class TodoDb {
  static final TodoDb instance = TodoDb._init();

  static Database? _database;

  TodoDb._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    _database = await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );

    return _database!;
  }

  //create the database
  Future _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE todos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  //insert a todo
  Future<int> insert(TodoModel todo) async {
    final db = await database;
    return await db.insert('todos', todo.toMap());
  }

  //get all todos
  Future<List<TodoModel>> getTodos() async {
    final db = await database;

    final result = await db.query(
      'todos',
      orderBy: 'createdAt DESC',
    );

    return result.map((e) => TodoModel.fromMap(e)).toList();
  }

  //update a todo
  Future<int> update(TodoModel todo) async {
    final db = await database;
    return await db.update(
      'todos',
      todo.toMap(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  //delete a todo
  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'todos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}