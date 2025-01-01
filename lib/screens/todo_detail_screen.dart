import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo/extensions/context_extension.dart';
import 'package:todo/model/todo_model.dart';
import 'package:todo/providers/storage_provider.dart';

class TodoDetailScreen extends ConsumerStatefulWidget {
  final Todo todo;
  const TodoDetailScreen({super.key, required this.todo});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TodoDetailScreenState();
}

class _TodoDetailScreenState extends ConsumerState<TodoDetailScreen> {
  late TextEditingController taskController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    taskController = TextEditingController(
      text: widget.todo.taskName,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    taskController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[200],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            floating: true,
            actions: [
              taskController.text.isEmpty ||
                      taskController.text == widget.todo.taskName
                  ? const SizedBox()
                  : IconButton(
                      onPressed: () {
                        ref
                            .read(providerOfStorage.notifier)
                            .updateData(
                                widget.todo.key,
                                Todo(
                                  key: widget.todo.key,
                                  taskName: taskController.text,
                                  isCompleted: widget.todo.isCompleted,
                                ))
                            .then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Task Updated"),
                              backgroundColor: Color.fromARGB(255, 3, 168, 9),
                            ),
                          );
                          Navigator.pop(context);
                        });
                      },
                      icon: const Icon(
                        Icons.add_box_outlined,
                        color: Colors.white,
                      ),
                    ),
            ],
            backgroundColor: Colors.deepPurple,
            title: const Text(
              "Todo Detail",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.height * 0.02,
            ),
          ),
          SliverToBoxAdapter(
            child: TextFormField(
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
              controller: taskController,
              maxLines: 10,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: "Task Name",
                hintStyle: TextStyle(
                  color: Colors.grey.shade300,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.width * 0.05,
                  vertical: context.height * 0.02,
                ),
              ),
              onChanged: (string) {
                setState(() {});
              },
            ),
          )
        ],
      ),
    );
  }
}
