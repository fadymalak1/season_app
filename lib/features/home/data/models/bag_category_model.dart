class BagCategoryModel {
  final int id;
  final String name;
  final String? icon;

  BagCategoryModel({
    required this.id,
    required this.name,
    this.icon,
  });

  factory BagCategoryModel.fromJson(Map<String, dynamic> json) {
    return BagCategoryModel(
      id: json['category_id'] ?? json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

