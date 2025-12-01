import 'package:season_app/features/home/data/datasources/bag_remote_datasource.dart';
import 'package:season_app/features/home/data/models/bag_category_model.dart';
import 'package:season_app/features/home/data/models/bag_detail_model.dart';
import 'package:season_app/features/home/data/models/bag_item_model.dart';
import 'package:season_app/features/home/data/models/bag_type_model.dart';

class BagRepository {
  final BagRemoteDataSource remoteDataSource;

  BagRepository(this.remoteDataSource);

  Future<List<BagTypeModel>> getBagTypes() => remoteDataSource.getBagTypes();

  Future<List<BagCategoryModel>> getCategories() =>
      remoteDataSource.getCategories();

  Future<List<BagItemModel>> getCategoryItems(int categoryId) =>
      remoteDataSource.getCategoryItems(categoryId);

  Future<List<BagDetailModel>> getBagDetails() =>
      remoteDataSource.getBagDetails();

  Future<void> addItemToBag({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) =>
      remoteDataSource.addItemToBag(
        itemId: itemId,
        bagTypeId: bagTypeId,
        quantity: quantity,
      );

  Future<void> deleteItemFromBag({
    required int itemId,
    required int bagTypeId,
  }) =>
      remoteDataSource.deleteItemFromBag(
        itemId: itemId,
        bagTypeId: bagTypeId,
      );

  Future<void> updateItemQuantity({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) =>
      remoteDataSource.updateItemQuantity(
        itemId: itemId,
        bagTypeId: bagTypeId,
        quantity: quantity,
      );
}

