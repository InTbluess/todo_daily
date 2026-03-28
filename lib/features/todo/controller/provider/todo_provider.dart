import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../todo_notifier.dart';
import '../../data/model/todo_model.dart';

final todoProvider = 
  AsyncNotifierProvider<TodoNotifier, List<TodoModel>>(
    TodoNotifier.new,
  );
