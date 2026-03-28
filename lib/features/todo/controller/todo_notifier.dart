import '../data/model/todo_model.dart';
import '../data/repository/todo_repository.dart';
import 'todo_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TodoNotifier extends AsyncNotifier<List<TodoModel>> {
  final _repo = TodoRepository();

  @override
  Future<List<TodoModel>> build() async {
    return _repo.fetchTodos();
  }

  // @override
  // Future<List<TodoModel>> build() async {
  //   return [
  //     TodoModel(id: 1, title: "Learn Flutter", description: "Understand widgets & layout", isCompleted: false),
  //     TodoModel(id: 2, title: "Workout", description: "Chest + triceps 💪", isCompleted: true),
  //     TodoModel(id: 3, title: "Buy groceries", description: "Milk, eggs, bread", isCompleted: false),
  //     TodoModel(id: 4, title: "Read book", description: "Atomic Habits - 20 pages", isCompleted: false),
  //     TodoModel(id: 5, title: "Fix bug", description: "Resolve swipe glitch issue", isCompleted: true),
  //     TodoModel(id: 6, title: "Call friend", description: "Catch up after long time", isCompleted: false),
  //     TodoModel(id: 7, title: "Plan project", description: "Outline features for app", isCompleted: true),
  //     TodoModel(id: 8, title: "Study DSA", description: "Stacks & queues revision", isCompleted: false),
  //     TodoModel(id: 9, title: "Clean room", description: "Organize desk setup", isCompleted: true),
  //     TodoModel(id: 10, title: "Watch tutorial", description: "Riverpod advanced concepts", isCompleted: false),
  //     TodoModel(id: 11, title: "Write notes", description: "Summarize Flutter basics", isCompleted: false),
  //     TodoModel(id: 12, title: "Drink water", description: "At least 3L today 💧", isCompleted: true),
  //     TodoModel(id: 13, title: "Meditate", description: "10 minutes mindfulness", isCompleted: false),
  //     TodoModel(id: 14, title: "Debug app", description: "Fix UI overflow issue", isCompleted: true),
  //     TodoModel(id: 15, title: "Design UI", description: "Improve todo tile look", isCompleted: false),
  //     TodoModel(id: 16, title: "Push code", description: "Commit changes to GitHub", isCompleted: true),
  //     TodoModel(id: 17, title: "Learn Git", description: "Rebase vs merge", isCompleted: false),
  //     TodoModel(id: 18, title: "Check emails", description: "Reply to pending mails", isCompleted: true),
  //     TodoModel(id: 19, title: "Build feature", description: "Add swipe animations", isCompleted: false),
  //     TodoModel(id: 20, title: "Sleep early", description: "Before 12 AM 😴", isCompleted: false),
  //   ];
  // }

  //add a todo
  Future<void> addTodo(String title, String description) async {
    final newTodo = TodoModel(title: title, description: description);
    final id = await _repo.addTodo(newTodo);
    final current = state.value ?? [];
    final updated = newTodo.copyWith(id: id);
    state = AsyncValue.data(
      [updated, ...current]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
    );
  }

  //toggle completion status
  Future<void> toggleCompletion(TodoModel todo) async {
    final updatedTodo = todo.copyWith(isCompleted: !todo.isCompleted);

    await _repo.updateTodo(updatedTodo);

    final current = state.value ?? [];

    state = AsyncValue.data(
      current.map((t) => t.id == updatedTodo.id ? updatedTodo : t).toList(),
    );
  }

  //delete a todo
  Future<void> deleteTodo(int id) async {
    await _repo.deleteTodo(id);

    final current = state.value ?? [];

    state = AsyncValue.data(current.where((t) => t.id != id).toList());
  }

  //refresh todos
  Future<void> refresh() async {
    final todos = await _repo.fetchTodos();
    state = AsyncValue.data(todos);
  }

  TodoFilter filter = TodoFilter.all;

  List<TodoModel> getFilteredTodos(List<TodoModel> todos) {
    switch (filter) {
      case TodoFilter.pending:
        return todos.where((t) => !t.isCompleted).toList();

      case TodoFilter.completed:
        return todos.where((t) => t.isCompleted).toList();

      case TodoFilter.all:
      default:
        return todos;
    }
  }

  void setFilter(TodoFilter newFilter) {
    filter = newFilter;

    // trigger UI refresh
    state = AsyncValue.data([...state.value ?? []]);
  }
}
