import '../database/todo_db.dart';
import '../model/todo_model.dart';

class TodoRepository {
  final _db = TodoDb.instance;

  Future<List<TodoModel>> fetchTodos() {
    return _db.getTodos();
  }

  Future<int> addTodo(TodoModel todo) {
    return _db.insert(todo);
  }

  Future<int> updateTodo(TodoModel todo) {
    return _db.update(todo);
  }

  Future<int> deleteTodo(int id) {
    return _db.delete(id);
  } 
}
