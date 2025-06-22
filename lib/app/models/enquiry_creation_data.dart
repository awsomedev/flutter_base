import 'package:madeira/app/models/category_model.dart';
import 'package:madeira/app/models/material_model.dart';
import 'package:madeira/app/models/process_model.dart';
import 'package:madeira/app/models/user_model.dart';

class EnquiryCreationData {
  final List<Category> categories;
  final List<MaterialModel> materials;
  final List<Process> processes;
  final List<User> managers;

  EnquiryCreationData({
    required this.categories,
    required this.materials,
    required this.processes,
    required this.managers,
  });

  factory EnquiryCreationData.fromJson(Map<String, dynamic> json) {
    return EnquiryCreationData(
      categories: [
        Category(
          id: 0,
          name: 'All',
          description: 'All',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ...(json['categories'] as List).map((e) => Category.fromJson(e))
      ],
      materials: (json['materials'] as List)
          .map((e) => MaterialModel.fromJson(e))
          .toList(),
      processes:
          (json['processes'] as List).map((e) => Process.fromJson(e)).toList(),
      managers:
          (json['managers'] as List).map((e) => User.fromJson(e)).toList(),
    );
  }
}
