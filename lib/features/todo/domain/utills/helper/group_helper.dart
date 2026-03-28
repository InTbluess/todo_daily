import 'package:todo_app/features/todo/data/model/todo_model.dart';

Map<String, List<TodoModel>> groupTodos(List<TodoModel> todos) {
  final map = <String, List<TodoModel>>{};

  for (var todo in todos) {
    final key = DateTime(
      todo.createdAt.year,
      todo.createdAt.month,
      todo.createdAt.day,
    ).toString();

    map.putIfAbsent(key, () => []);
    map[key]!.add(todo);
  }

  return map;
}