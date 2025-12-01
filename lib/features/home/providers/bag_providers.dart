import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/services/dio_client.dart';
import 'package:season_app/features/home/data/datasources/bag_remote_datasource.dart';
import 'package:season_app/features/home/data/models/bag_category_model.dart';
import 'package:season_app/features/home/data/models/bag_detail_model.dart';
import 'package:season_app/features/home/data/models/bag_item_model.dart';
import 'package:season_app/features/home/data/models/bag_type_model.dart';
import 'package:season_app/features/home/data/repositories/bag_repository.dart';
import 'package:season_app/shared/providers/app_providers.dart';

final bagRepositoryProvider = Provider<BagRepository>((ref) {
  final dio = ref.watch(dioProvider);
  final dataSource = BagRemoteDataSource(dio);
  return BagRepository(dataSource);
});

class BagState {
  final List<BagTypeModel> bagTypes;
  final BagTypeModel? selectedBagType;
  final List<BagCategoryModel> categories;
  final BagCategoryModel? selectedCategory;
  final List<BagItemModel> items;
  final List<BagDetailModel> bagDetails;
  final bool isLoading;
  final bool isLoadingItems;
  final bool isLoadingBagDetails;
  final String? error;

  const BagState({
    required this.bagTypes,
    required this.selectedBagType,
    required this.categories,
    required this.selectedCategory,
    required this.items,
    required this.bagDetails,
    required this.isLoading,
    required this.isLoadingItems,
    required this.isLoadingBagDetails,
    this.error,
  });

  factory BagState.initial() => const BagState(
        bagTypes: [],
        selectedBagType: null,
        categories: [],
        selectedCategory: null,
        items: [],
        bagDetails: [],
        isLoading: false,
        isLoadingItems: false,
        isLoadingBagDetails: false,
        error: null,
      );

  BagDetailModel? getSelectedBagDetail() {
    if (selectedBagType == null || bagDetails.isEmpty) return null;
    try {
      return bagDetails.firstWhere(
        (detail) => detail.bagTypeId == selectedBagType!.id,
      );
    } catch (e) {
      return null;
    }
  }

  BagState copyWith({
    List<BagTypeModel>? bagTypes,
    BagTypeModel? selectedBagType,
    List<BagCategoryModel>? categories,
    BagCategoryModel? selectedCategory,
    List<BagItemModel>? items,
    List<BagDetailModel>? bagDetails,
    bool? isLoading,
    bool? isLoadingItems,
    bool? isLoadingBagDetails,
    String? error,
  }) {
    return BagState(
      bagTypes: bagTypes ?? this.bagTypes,
      selectedBagType: selectedBagType ?? this.selectedBagType,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      items: items ?? this.items,
      bagDetails: bagDetails ?? this.bagDetails,
      isLoading: isLoading ?? this.isLoading,
      isLoadingItems: isLoadingItems ?? this.isLoadingItems,
      isLoadingBagDetails: isLoadingBagDetails ?? this.isLoadingBagDetails,
      error: error,
    );
  }
}

class BagNotifier extends Notifier<BagState> {
  late final BagRepository _repository;

  @override
  BagState build() {
    _repository = ref.read(bagRepositoryProvider);
    Future.microtask(_loadInitialData);
    return BagState.initial();
  }

  Future<void> _loadInitialData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bagTypes = await _repository.getBagTypes();
      final categories = await _repository.getCategories();
      final bagDetails = await _repository.getBagDetails();

      BagTypeModel? selectedBagType = state.selectedBagType;
      if (bagTypes.isNotEmpty) {
        selectedBagType ??= bagTypes.first;
      }

      BagCategoryModel? selectedCategory = state.selectedCategory;
      if (categories.isNotEmpty) {
        selectedCategory ??= categories.first;
      }

      List<BagItemModel> items = state.items;
      if (selectedCategory != null) {
        items = await _repository.getCategoryItems(selectedCategory.id);
      } else {
        items = [];
      }

      state = state.copyWith(
        bagTypes: bagTypes,
        categories: categories,
        selectedBagType: selectedBagType,
        selectedCategory: selectedCategory,
        items: items,
        bagDetails: bagDetails,
        isLoading: false,
        isLoadingItems: false,
        isLoadingBagDetails: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingItems: false,
        isLoadingBagDetails: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadBagDetails() async {
    state = state.copyWith(isLoadingBagDetails: true, error: null);
    try {
      final bagDetails = await _repository.getBagDetails();
      state = state.copyWith(
        bagDetails: bagDetails,
        isLoadingBagDetails: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingBagDetails: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> addItemToBag({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) async {
    try {
      await _repository.addItemToBag(
        itemId: itemId,
        bagTypeId: bagTypeId,
        quantity: quantity,
      );
      await loadBagDetails();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteItemFromBag({
    required int itemId,
    required int bagTypeId,
  }) async {
    try {
      await _repository.deleteItemFromBag(
        itemId: itemId,
        bagTypeId: bagTypeId,
      );
      await loadBagDetails();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateItemQuantity({
    required int itemId,
    required int bagTypeId,
    required int quantity,
  }) async {
    try {
      await _repository.updateItemQuantity(
        itemId: itemId,
        bagTypeId: bagTypeId,
        quantity: quantity,
      );
      await loadBagDetails();
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(error: e.message);
      rethrow;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> refreshCategories() async {
    try {
      final categories = await _repository.getCategories();
      BagCategoryModel? selectedCategory = categories.isNotEmpty ? categories.first : null;
      state = state.copyWith(categories: categories, selectedCategory: selectedCategory);
      if (selectedCategory != null) {
        await selectCategory(selectedCategory);
      } else {
        state = state.copyWith(items: [], isLoadingItems: false);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void selectBagType(BagTypeModel bagType) {
    if (state.selectedBagType?.id == bagType.id) return;
    state = state.copyWith(selectedBagType: bagType);
  }

  Future<void> selectCategory(BagCategoryModel category) async {
    if (state.selectedCategory?.id == category.id) return;
    state = state.copyWith(
      selectedCategory: category,
      isLoadingItems: true,
      error: null,
    );
    try {
      final items = await _repository.getCategoryItems(category.id);
      state = state.copyWith(
        items: items,
        isLoadingItems: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingItems: false,
        error: e.toString(),
      );
    }
  }

  Future<void> retryItems() async {
    final category = state.selectedCategory;
    if (category == null) return;
    await selectCategory(category);
  }

  Future<void> reload() async {
    await _loadInitialData();
  }
}

final bagControllerProvider =
    NotifierProvider<BagNotifier, BagState>(BagNotifier.new);

