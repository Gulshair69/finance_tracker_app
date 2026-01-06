import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../providers/category_provider.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      categoryProvider.loadCategories();
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
          bottom: const TabBar(
            tabs: [
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
    List<CategoryModel> categories,
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
            backgroundColor: Color(category.color).withOpacity(0.2),
            child: Icon(
              _getIconData(category.icon),
              color: Color(category.color),
            ),
          ),
          title: Text(category.name),
          subtitle: category.isDefault
              ? const Text("Default Category", style: TextStyle(fontSize: 12))
              : null,
          trailing: category.isDefault
              ? null
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCategoryDialog(
                        context,
                        category,
                        categoryProvider,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        categoryProvider.deleteCategory(category.id);
                      },
                    ),
                  ],
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
    final iconController = TextEditingController(text: 'category');
    TransactionType selectedType = TransactionType.expense;
    int selectedColor = AppColors.primary.value;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final colors = [
      AppColors.primary.value,
      AppColors.secondary.value,
      0xFFFF6B6B,
      0xFF4ECDC4,
      0xFFFFE66D,
      0xFF95E1D3,
      0xFFAA96DA,
      0xFFFF6B9D,
    ];

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
                    initialValue: selectedType,
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
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(
                      labelText: "Icon Name",
                      hintText: "e.g., restaurant, shopping_bag",
                    ),
                    validator: (value) =>
                        value!.isEmpty ? "Enter icon name" : null,
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Color:"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedColor = color);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final category = CategoryModel(
                    id: const Uuid().v4(),
                    name: nameController.text.trim(),
                    icon: iconController.text.trim(),
                    color: selectedColor,
                    type: selectedType,
                    isDefault: false,
                    userId: user.uid,
                  );

                  final success = await categoryProvider.addCategory(category);
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Add"),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditCategoryDialog(
    BuildContext context,
    CategoryModel category,
    CategoryProvider categoryProvider,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: category.name);
    final iconController = TextEditingController(text: category.icon);
    int selectedColor = category.color;

    final colors = [
      AppColors.primary.value,
      AppColors.secondary.value,
      0xFFFF6B6B,
      0xFF4ECDC4,
      0xFFFFE66D,
      0xFF95E1D3,
      0xFFAA96DA,
      0xFFFF6B9D,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Edit Category"),
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
                  TextFormField(
                    controller: iconController,
                    decoration: const InputDecoration(labelText: "Icon Name"),
                    validator: (value) =>
                        value!.isEmpty ? "Enter icon name" : null,
                  ),
                  const SizedBox(height: 16),
                  const Text("Select Color:"),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: colors.map((color) {
                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedColor = color);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Color(color),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == color
                                  ? Colors.black
                                  : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedCategory = category.copyWith(
                    name: nameController.text.trim(),
                    icon: iconController.text.trim(),
                    color: selectedColor,
                  );

                  final success = await categoryProvider.updateCategory(
                    updatedCategory,
                  );
                  if (success && context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'receipt': Icons.receipt,
      'movie': Icons.movie,
      'favorite': Icons.favorite,
      'school': Icons.school,
      'category': Icons.category,
      'work': Icons.work,
      'laptop': Icons.laptop,
      'trending_up': Icons.trending_up,
      'card_giftcard': Icons.card_giftcard,
      'attach_money': Icons.attach_money,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}
