class BagItemInBagModel {
  final int itemId;
  final String name;
  final String category;
  final int quantity;
  final double weightPerItem;
  final double totalWeight;
  final String? icon;

  BagItemInBagModel({
    required this.itemId,
    required this.name,
    required this.category,
    required this.quantity,
    required this.weightPerItem,
    required this.totalWeight,
    this.icon,
  });

  factory BagItemInBagModel.fromJson(Map<String, dynamic> json) {
    return BagItemInBagModel(
      itemId: json['item_id'] ?? 0,
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      quantity: json['quantity'] ?? 1,
      weightPerItem: _parseDouble(json['weight_per_item']),
      totalWeight: _parseDouble(json['total_weight']),
      icon: json['icon'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

