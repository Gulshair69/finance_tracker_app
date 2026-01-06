import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../providers/goal_provider.dart';
import '../models/goal_model.dart';
import '../widgets/goal_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoalsScreen extends StatefulWidget {
  static const String routeName = '/goals';

  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final goalProvider = Provider.of<GoalProvider>(context, listen: false);
      goalProvider.loadGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final goalProvider = Provider.of<GoalProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Goals"),
          backgroundColor: AppColors.primary,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Active"),
              Tab(text: "Completed"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Active Goals
            goalProvider.getActiveGoals().isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flag, size: 64, color: AppColors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          "No active goals",
                          style: TextStyle(fontSize: 18, color: AppColors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () =>
                              _showAddGoalDialog(context, goalProvider),
                          child: const Text("Create Goal"),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: goalProvider.getActiveGoals().length,
                    itemBuilder: (context, index) {
                      final goal = goalProvider.getActiveGoals()[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () =>
                            _showEditGoalDialog(context, goal, goalProvider),
                        onDelete: () {
                          goalProvider.deleteGoal(goal.id);
                        },
                      );
                    },
                  ),

            // Completed Goals
            goalProvider.getCompletedGoals().isEmpty
                ? const Center(
                    child: Text(
                      "No completed goals",
                      style: TextStyle(fontSize: 18, color: AppColors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: goalProvider.getCompletedGoals().length,
                    itemBuilder: (context, index) {
                      final goal = goalProvider.getCompletedGoals()[index];
                      return GoalCard(
                        goal: goal,
                        onTap: () =>
                            _showEditGoalDialog(context, goal, goalProvider),
                        onDelete: () {
                          goalProvider.deleteGoal(goal.id);
                        },
                      );
                    },
                  ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddGoalDialog(context, goalProvider),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, GoalProvider goalProvider) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final targetAmountController = TextEditingController();
    DateTime selectedDeadline = DateTime.now().add(const Duration(days: 30));
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Goal"),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Goal Title"),
                    validator: (value) => value!.isEmpty ? "Enter title" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: targetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Target Amount",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter amount";
                      if (double.tryParse(value) == null) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Deadline"),
                    subtitle: Text(
                      selectedDeadline.toLocal().toString().split(' ')[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDeadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final goal = GoalModel(
                  id: const Uuid().v4(),
                  title: titleController.text.trim(),
                  targetAmount: double.parse(targetAmountController.text),
                  deadline: selectedDeadline,
                  userId: user.uid,
                  createdAt: DateTime.now(),
                );

                final success = await goalProvider.addGoal(goal);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditGoalDialog(
    BuildContext context,
    GoalModel goal,
    GoalProvider goalProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController(text: goal.title);
    final targetAmountController = TextEditingController(
      text: goal.targetAmount.toString(),
    );
    final currentAmountController = TextEditingController(
      text: goal.currentAmount.toString(),
    );
    DateTime selectedDeadline = goal.deadline;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Goal"),
        content: StatefulBuilder(
          builder: (context, setState) => Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(labelText: "Goal Title"),
                    validator: (value) => value!.isEmpty ? "Enter title" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: targetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Target Amount",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter amount";
                      if (double.tryParse(value) == null) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: currentAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: "Current Amount",
                    ),
                    validator: (value) {
                      if (value!.isEmpty) return "Enter amount";
                      if (double.tryParse(value) == null) {
                        return "Enter valid amount";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Deadline"),
                    subtitle: Text(
                      selectedDeadline.toLocal().toString().split(' ')[0],
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDeadline,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDeadline = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final updatedGoal = goal.copyWith(
                  title: titleController.text.trim(),
                  targetAmount: double.parse(targetAmountController.text),
                  currentAmount: double.parse(currentAmountController.text),
                  deadline: selectedDeadline,
                );

                final success = await goalProvider.updateGoal(updatedGoal);
                if (success && context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }
}
