import 'package:season_app/features/home/data/models/bag_item_in_bag_model.dart';

class BagDetailModel {
  final int bagId;
  final String bagName;
  final int bagType;
  final int bagTypeId;
  final double currentWeight;
  final double maxWeight;
  final String weightUnit;
  final double weightPercentage;
  final List<BagItemInBagModel> items;
  final bool isEmpty;

  BagDetailModel({
    required this.bagId,
    required this.bagName,
    required this.bagType,
    required this.bagTypeId,
    required this.currentWeight,
    required this.maxWeight,
    required this.weightUnit,
    required this.weightPercentage,
    required this.items,
    required this.isEmpty,
  });

  factory BagDetailModel.fromJson(Map<String, dynamic> json) {
    return BagDetailModel(
      bagId: json['bag_id'] ?? 0,
      bagName: json['bag_name'] ?? '',
      bagType: json['bag_type'] ?? 0,
      bagTypeId: json['bag_type_id'] ?? 0,
      currentWeight: _parseDouble(json['current_weight']),
      maxWeight: _parseDouble(json['max_weight']),
      weightUnit: json['weight_unit'] ?? 'kg',
      weightPercentage: _parseDouble(json['weight_percentage']),
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => BagItemInBagModel.fromJson(item))
              .toList() ??
          [],
      isEmpty: json['is_empty'] ?? true,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

