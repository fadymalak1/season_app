import 'package:dio/dio.dart';
import 'package:season_app/core/constants/api_endpoints.dart';
import 'package:season_app/features/home/data/models/bag_category_model.dart';
import 'package:season_app/features/home/data/models/bag_detail_model.dart';
import 'package:season_app/features/home/data/models/bag_item_model.dart';
import 'package:season_app/features/home/data/models/bag_type_model.dart';

class BagRemoteDataSource {
  final Dio dio;

  BagRemoteDataSource(this.dio);

  Future<List<BagTypeModel>> getBagTypes() async {
    final response = await dio.get(ApiEndpoints.bagTypes);
    final data = _extractList(response.data);
    return data.map((json) => BagTypeModel.fromJson(json)).toList();
  }

  Future<List<BagCategoryModel>> getCategories() async {
    final response = await dio.get(ApiEndpoints.bagCategories);
    final data = _extractList(response.data);
    return data.map((json) => BagCategoryModel.fromJson(json)).toList();
  }

  Future<List<BagItemModel>> getCategoryItems(int categoryId) async {
    final response = await dio.get(
      ApiEndpoints.bagCategoryItems,
      queryParameters: {'category_id': categoryId},
    );
    final data = _extractList(response.data);
    return data.map((json) => BagItemModel.fromJson(json)).toList();
  }

  Future<List<BagDetailModel>> getBagDetails() async {
    final response = await dio.get(ApiEndpoints.bagDetails);
    final data = _extractList(response.data);
    return data.map((json) => BagDetailModel.fromJson(json)).toList();
  }

  Future<void> addItemToBag({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) async {
    await dio.post(
      ApiEndpoints.bagAddItem,
      data: {
        'item_id': itemId,
        'bag_type_id': bagTypeId,
        'quantity': quantity,
      },
    );
  }

  Future<void> deleteItemFromBag({
    required int itemId,
    required int bagTypeId,
  }) async {
    final endpoint = ApiEndpoints.bagDeleteItem.replaceAll('{item_id}', itemId.toString());
    await dio.delete(
      endpoint,
      queryParameters: {'bag_type_id': bagTypeId},
    );
  }

  Future<void> updateItemQuantity({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) async {
    final endpoint = ApiEndpoints.bagUpdateItemQuantity.replaceAll('{item_id}', itemId.toString());
    await dio.put(
      endpoint,
      data: {
        'bag_type_id': bagTypeId,
        'quantity': quantity,
      },
    );
  }

  List<Map<String, dynamic>> _extractList(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final data = raw['data'];
      if (data is List) {
        return data.cast<Map<String, dynamic>>();
      }
    } else if (raw is List) {
      return raw.cast<Map<String, dynamic>>();
    }
    return [];
  }
}

