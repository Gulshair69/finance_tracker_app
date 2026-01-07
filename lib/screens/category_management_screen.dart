import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../models/transaction_model.dart';

class CategoryManagementScreen extends StatefulWidget {
  static const String routeName = '/categoryManagement';

  const CategoryManagementScreen({super.key});

  @override
  State<CategoryManagementScreen> createState() =>
      _CategoryManagementScreenState();
}

class _CategoryManagementScreenState extends State<CategoryManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(
        context,
        listen: false,
      );
      categoryProvider.initializeCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Categories"),
          backgroundColor: AppColors.primary,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.7),
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: "Expense"),
              Tab(text: "Income"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildCategoryList(
              categoryProvider.getCategoriesByType(TransactionType.expense),
              TransactionType.expense,
              categoryProvider,
            ),
            _buildCategoryList(
              categoryProvider.getCategoriesByType(TransactionType.income),
              TransactionType.income,
              categoryProvider,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => _showAddCategoryDialog(context, categoryProvider),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildCategoryList(
    List<String> categories,
    TransactionType type,
    CategoryProvider categoryProvider,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 64, color: AppColors.grey),
            const SizedBox(height: 16),
            const Text(
              "No categories yet",
              style: TextStyle(fontSize: 18, color: AppColors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: Icon(Icons.category, color: AppColors.primary),
          ),
          title: Text(category),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () {
              categoryProvider.deleteCategory(category, type);
            },
          ),
        );
      },
    );
  }

  void _showAddCategoryDialog(
    BuildContext context,
    CategoryProvider categoryProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    TransactionType selectedType = TransactionType.expense;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Add Category"),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                    ),
                    validator: (value) => value!.isEmpty ? "Enter name" : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TransactionType>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: "Type"),
                    items: TransactionType.values.map((type) {
                      return DropdownMenuItem<TransactionType>(
                        value: type,
                        child: Text(type.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => selectedType = value!);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: categoryProvider.isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        final success = await categoryProvider.addCategory(
                          nameController.text.trim(),
                          selectedType,
                        );
                        if (context.mounted) {
                          if (success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Category added successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  categoryProvider.error ?? 'Failed to add category',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
              child: categoryProvider.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }
}
