import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/todo/controller/todo_filter.dart';
import 'package:todo_app/features/todo/domain/utills/helper/date_utils.dart';
import 'package:todo_app/features/todo/domain/utills/helper/group_helper.dart';
import 'package:todo_app/main.dart';
import '../../controller/provider/todo_provider.dart';
import '../widget/todo_tile.dart';
import '../widget/add_todo_dialog.dart';

class TodoScreen extends ConsumerStatefulWidget {
  const TodoScreen({super.key});

  @override
  ConsumerState<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends ConsumerState<TodoScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();

    // 👇 listen to app lifecycle
    WidgetsBinding.instance.addObserver(this);

    // initial load
    Future.microtask(() {
      ref.read(todoProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    MyApp.restartApp(context);
  }
}

  @override
  Widget build(BuildContext context) {
    final todoAsync = ref.watch(todoProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: const Color.fromARGB(255, 128, 97, 179),
        shadowColor: Colors.transparent,
        title: const Text(
          'Todo App',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<TodoFilter>(
            icon: const Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: Icon(
                Icons.filter_list_sharp,
                color: Colors.white,
                size: 32,
              ),
            ),
            onSelected: (value) {
              ref.read(todoProvider.notifier).setFilter(value);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: TodoFilter.all, child: Text('All')),
              PopupMenuItem(value: TodoFilter.pending, child: Text('Pending')),
              PopupMenuItem(
                value: TodoFilter.completed,
                child: Text('Completed'),
              ),
            ],
          ),
        ],
      ),

      body: todoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (todos) {
          final notifier = ref.read(todoProvider.notifier);
          final filteredTodos = notifier.getFilteredTodos(todos);

          if (filteredTodos.isEmpty) {
            return const Center(child: Text('No todos found'));
          }

          final grouped = groupTodos(filteredTodos);

          final dates = grouped.keys.toList()
            ..sort((a, b) => b.compareTo(a));

          return ListView(
            children: dates.map((date) {
              final todos = grouped[date]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      formatDateHeader(date),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...todos.map((t) => TodoTile(todo: t)),
                ],
              );
            }).toList(),
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => const AddTodoDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}