import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_model.dart';

class CategoryModel {
  final String id;
  final String name;
  final String icon;
  final int color;
  final TransactionType type;
  final bool isDefault;
  final String userId;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    this.isDefault = false,
    required this.userId,
  });

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'color': color,
      'type': type.name,
      'isDefault': isDefault,
      'userId': userId,
    };
  }

  // Create from Firestore document
  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? 'category',
      color: map['color'] ?? 0xFF6C5CE7,
      type: TransactionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => TransactionType.expense,
      ),
      isDefault: map['isDefault'] ?? false,
      userId: map['userId'] ?? '',
    );
  }

  // Create from Firestore document snapshot
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel.fromMap(data);
  }

  // Copy with method
  CategoryModel copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    TransactionType? type,
    bool? isDefault,
    String? userId,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      userId: userId ?? this.userId,
    );
  }
}

