import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todo/extensions/context_extension.dart';
import 'package:todo/model/todo_model.dart';
import 'package:todo/providers/storage_provider.dart';
import 'package:todo/widgets/custom_text_field.dart';
import 'package:todo/widgets/todo_tile.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController taskController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    taskController.dispose();
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[200],
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            floating: true,
            centerTitle: true,
            title: Text(
              "TODO",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.deepPurple,
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.height * 0.02,
            ),
          ),
          _buildTaskList(ref),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAnimatedDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showAnimatedDialog(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (context, animation1, animation2) {
        return Container(); // UI is handled in the transitionBuilder
      },
      transitionBuilder: (context, animation1, animation2, child) {
        return Transform.scale(
          scale: animation1.value,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Opacity(
              opacity: animation1.value,
              child: AlertDialog(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                title: const Center(
                  child: Text(
                    'Create a new task',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                content: Form(
                  key: _formKey,
                  child: CustomTextField(
                    controller: taskController,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        String uid = const Uuid().v1();

                        ref.read(providerOfStorage.notifier).saveData(
                              Todo(
                                taskName: taskController.text,
                                isCompleted: false,
                                key: uid,
                              ),
                            );
                        Navigator.of(context).pop();

                        taskController.clear();

                        // Save the task
                      }
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Close',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionDuration:
          const Duration(milliseconds: 300), // Animation duration
    );
  }

  Widget _buildTaskList(WidgetRef ref) {
    final todosAsync = ref.watch(providerOfTodoList);
    return todosAsync.when(
      data: (allList) {
        return allList.isNotEmpty
            ? SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => TodoTile(index: index),
                  childCount: allList.length,
                ),
              )
            : SliverToBoxAdapter(
                child: Center(
                  child: AutoSizeText(
                    "No tasks available\n Create a new task",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 20,
                    ),
                  ),
                ),
              );
      },
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        );
      },
      error: (error, stack) {
        return SliverToBoxAdapter(
          child: Center(
            child: Text('Error: $error'),
          ),
        );
      },
    );
  }
}
