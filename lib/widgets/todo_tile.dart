import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo/extensions/context_extension.dart';
import 'package:todo/model/todo_model.dart';
import 'package:todo/providers/storage_provider.dart';
import 'package:todo/screens/todo_detail_screen.dart';

class TodoTile extends ConsumerWidget {
  final int index;
  const TodoTile({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allListAsync = ref.watch(providerOfTodoList);
    final allList = allListAsync.value;
    final Todo todo = allList![index];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.width * 0.03),
      child: Container(
        margin: EdgeInsets.only(bottom: context.height * 0.02),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  ref.read(providerOfStorage.notifier).deleteData(todo.key);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text("Task deleted"),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.red[800],
                    ),
                  );
                },
                icon: Icons.delete,
                backgroundColor: const Color.fromARGB(255, 95, 8, 2),
                borderRadius: BorderRadius.circular(12),
              )
            ],
          ),
          child: Container(
            height: context.height * 0.1,
            width: context.width,
            decoration: BoxDecoration(
              color: Colors.deepPurple[500],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TodoDetailScreen(todo: todo),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Checkbox(
                      value: todo.isCompleted,
                      onChanged: (val) {
                        ref
                            .read(providerOfStorage.notifier)
                            .toogleIsCompleted(todo.key, val!);
                      },
                      activeColor: Colors.white,
                      checkColor: Colors.deepPurple,
                      fillColor: WidgetStateProperty.all(Colors.white),
                    ),
                    Expanded(
                      child: AutoSizeText(
                        todo.taskName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          decorationStyle: TextDecorationStyle.solid,
                          decorationThickness: 2,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
