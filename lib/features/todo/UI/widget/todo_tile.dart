import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/todo/domain/utills/helper/date_utils.dart';
import 'package:todo_app/features/todo/domain/utills/helper/day_helper.dart';
import '../../controller/provider/todo_provider.dart';
import '../../data/model/todo_model.dart';

class TodoTile extends ConsumerStatefulWidget {
  final TodoModel todo;

  const TodoTile({super.key, required this.todo});

  @override
  ConsumerState<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends ConsumerState<TodoTile> {
  double offsetX = 0;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(todoProvider.notifier);

    final isPast = isPastDay(widget.todo.createdAt);

    Color? borderColor;

    if (isPast) {
      borderColor = widget.todo.isCompleted
          ? Colors.green.withOpacity(0.6)
          : const Color.fromARGB(255, 206, 50, 39).withOpacity(0.6);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSwipe = constraints.maxWidth * 0.4;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                // BACKGROUND (Swipe actions)
                Positioned.fill(
                  child: Container(
                    alignment: offsetX > 0
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: offsetX > 0
                          ? (isPast
                                ? Colors.grey
                                : (widget.todo.isCompleted
                                      ? Colors.orange
                                      : Colors.green))
                          : Colors.red,
                    ),
                    child: Row(
                      mainAxisAlignment: offsetX > 0
                          ? MainAxisAlignment.start
                          : MainAxisAlignment.end,
                      children: [
                        Icon(
                          offsetX > 0
                              ? (isPast
                                    ? Icons.lock
                                    : (widget.todo.isCompleted
                                          ? Icons.undo
                                          : Icons.check))
                              : Icons.delete,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          offsetX > 0
                              ? (isPast
                                    ? "Locked"
                                    : (widget.todo.isCompleted
                                          ? "Mark Pending"
                                          : "Mark Done"))
                              : "Delete",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // FOREGROUND (Tile)
                GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      offsetX += details.delta.dx;

                      if (isPast && offsetX > 0) {
                        offsetX = 0;
                      }

                      if (offsetX > maxSwipe) offsetX = maxSwipe;
                      if (offsetX < -maxSwipe) offsetX = -maxSwipe;
                    });
                  },

                  onHorizontalDragEnd: (_) {
                    if (offsetX.abs() > maxSwipe * 0.5) {
                      HapticFeedback.mediumImpact();
                    }

                    if (offsetX > maxSwipe * 0.5) {
                      if (!isPast) {
                        notifier.toggleCompletion(widget.todo);
                      }
                    } else if (offsetX < -maxSwipe * 0.5) {
                      notifier.deleteTodo(widget.todo.id!);
                    }

                    setState(() {
                      offsetX = 0;
                    });
                  },

                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    transform: Matrix4.translationValues(offsetX, 0, 0),

                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15),
                        border: borderColor != null
                            ? Border(
                                left: BorderSide(color: borderColor, width: 4),
                                top: BorderSide(color: borderColor, width: 2),
                              )
                            : null,
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: widget.todo.isCompleted,
                          onChanged: isPast
                              ? null
                              : (_) => notifier.toggleCompletion(widget.todo),
                        ),
                        title: Text(
                          widget.todo.title,
                          style: TextStyle(
                            decoration: widget.todo.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.todo.description),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final use24h = MediaQuery.of(
                                  context,
                                ).alwaysUse24HourFormat;
                                final dt = widget.todo.createdAt;

                                final hour = use24h
                                    ? dt.hour
                                    : (dt.hour % 12 == 0 ? 12 : dt.hour % 12);

                                final minute = dt.minute.toString().padLeft(
                                  2,
                                  '0',
                                );
                                final period = dt.hour >= 12 ? "PM" : "AM";

                                final formattedTime = use24h
                                    ? "${dt.hour.toString().padLeft(2, '0')}:$minute"
                                    : "$hour:$minute $period";

                                return Text(
                                  formattedTime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => notifier.deleteTodo(widget.todo.id!),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
