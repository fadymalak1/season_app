import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/localization/generated/l10n.dart';
import 'package:season_app/core/services/dio_client.dart';
import 'package:season_app/features/home/data/models/bag_category_model.dart';
import 'package:season_app/features/home/data/models/bag_item_model.dart';
import 'package:season_app/features/home/data/models/bag_item_in_bag_model.dart';
import 'package:season_app/features/home/providers/bag_providers.dart';
import 'package:season_app/features/reminders/data/models/reminder_model.dart';
import 'package:season_app/features/reminders/presentation/widgets/add_reminder_modal.dart';
import 'package:season_app/features/reminders/presentation/widgets/reminder_list_item.dart';
import 'package:season_app/features/reminders/providers.dart';
import 'package:season_app/shared/widgets/custom_button.dart';
import 'package:season_app/shared/widgets/custom_toast.dart';

class BagPage extends ConsumerStatefulWidget {
  const BagPage({super.key});

  @override
  ConsumerState<BagPage> createState() => _BagPageState();
}

class _BagPageState extends ConsumerState<BagPage> {
  double _maxWeight = 23.0;


  void _showAddReminderModal({ReminderModel? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => AddReminderModal(reminder: reminder),
      ),
    );
  }

  Future<void> _deleteReminder(int reminderId) async {
    final loc = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(loc.bagDeleteReminderTitle),
        content: Text(loc.bagDeleteReminderMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(loc.bagDeleteCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(loc.bagDeleteConfirm),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      final success =
          await ref.read(remindersProvider.notifier).deleteReminder(reminderId);
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.bagDeleteSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      ref.read(remindersProvider.notifier).loadReminders(),
      ref.read(bagControllerProvider.notifier).reload(),
    ]);
  }

  void _showAddItemSheet(BagState bagState) {
    showModalBottomSheet<BagItemSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return _AddBagItemSheet(scrollController: scrollController);
          },
        );
      },
    ).then((selection) async {
      if (!mounted) return;
      if (selection != null) {
        final loc = AppLocalizations.of(context);
        final bagState = ref.read(bagControllerProvider);
        final bagTypeId = bagState.selectedBagType?.id;
        if (bagTypeId == null) {
        
          return;
        }

        try {
          final success = await ref.read(bagControllerProvider.notifier).addItemToBag(
                itemId: selection.item.id,
                bagTypeId: bagTypeId,
                quantity: selection.quantity,
              );

          if (!mounted) return;
          if (success) {
            CustomToast.success(context, loc.bagAddItemSuccess);
          } else {
            CustomToast.error(context, loc.bagAddItemError);
          }
        } on ApiException catch (e) {
          if (!mounted) return;
          CustomToast.error(context, e.message);
        } catch (e) {
          if (!mounted) return;
          CustomToast.error(context, loc.bagAddItemError);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final remindersState = ref.watch(remindersProvider);
    final bagState = ref.watch(bagControllerProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final selectedBagType = bagState.selectedBagType;
    final bagDetail = bagState.getSelectedBagDetail();
    final currentWeight = bagDetail?.currentWeight ?? 0.0;
    final bagMaxWeight = bagDetail?.maxWeight ?? selectedBagType?.defaultMaxWeight ?? _maxWeight;
    _maxWeight = bagMaxWeight;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(loc, bagState, currentWeight, bagMaxWeight),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                displacement: 48,
                onRefresh: _refreshAll,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildRemindersSection(remindersState, loc),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildBagStatusCard(loc, bagState),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildTipsCard(loc),
                    ),
                    const SizedBox(height: 90),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc, BagState bagState, double currentWeight, double maxWeightValue) {
    final bagType = bagState.selectedBagType;
    final bagTitle = bagType?.name ?? loc.bagTitle;
    final bagSubtitle = bagType?.description?.isNotEmpty == true
        ? bagType!.description!
        : loc.bagSubtitle;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        color: AppColors.primary,
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.luggage, color: Colors.white, size: 32),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bagTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bagSubtitle,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          loc.bagTotalWeightLabel,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                       
                      ],
                    ),
                    Text(
                      loc.bagWeight(
                        currentWeight.toStringAsFixed(1),
                        maxWeightValue.toStringAsFixed(0),
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!bagState.isLoading && bagState.bagTypes.isNotEmpty) ...[
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: bagState.bagTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final bagTypeOption = bagState.bagTypes[index];
                      final isSelected =
                          bagState.selectedBagType?.id == bagTypeOption.id;
                      return GestureDetector(
                        onTap: () => ref
                            .read(bagControllerProvider.notifier)
                            .selectBagType(bagTypeOption),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withOpacity(0.25)
                                : Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.work_outline,
                                size: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                bagTypeOption.name,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.95),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          
              ],
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildRemindersSection(
    RemindersState state,
    AppLocalizations loc,
  ) {
    final List<Widget> content = [];

    final errorBanner = _buildRemindersErrorBanner(state, loc);
    if (errorBanner != null) {
      content.add(errorBanner);
      content.add(const SizedBox(height: 12));
    }

    if (state.isLoading) {
      content.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else if (state.reminders.isEmpty) {
      content.add(
        Column(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
                  color: AppColors.primary.withOpacity(0.18),
            ),
            const SizedBox(height: 16),
            Text(
              loc.bagRemindersEmptyTitle,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              loc.bagRemindersEmptyDescription,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    } else {
      for (var i = 0; i < state.reminders.length; i++) {
        final reminder = state.reminders[i];
        content.add(
          Padding(
            padding: EdgeInsets.only(bottom: i == state.reminders.length - 1 ? 0 : 12),
            child: ReminderListItem(
              reminder: reminder,
              onTap: () => _showAddReminderModal(reminder: reminder),
              onDelete: () => _deleteReminder(reminder.reminderId),
            ),
          ),
        );
      }
    }

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.bagRemindersTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.bagRemindersActiveCount(state.activeCount),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _showAddReminderModal,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  loc.bagAddReminderButton,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...content,
        ],
      ),
    );
  }

  Widget? _buildRemindersErrorBanner(
    RemindersState state,
    AppLocalizations loc,
  ) {
    if (state.error == null) return null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              loc.reminderLoadError,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => ref.read(remindersProvider.notifier).loadReminders(),
            child: Text(loc.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildBagStatusCard(AppLocalizations loc, BagState bagState) {
    final bagDetail = bagState.getSelectedBagDetail();
    final items = bagDetail?.items ?? [];
    final isEmpty = bagDetail?.isEmpty ?? true;

    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.luggage_outlined,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    loc.bagTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (!isEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${items.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              TextButton(
                onPressed: () => _showAddItemSheet(bagState),
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  loc.bagAddItemButton,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEmpty)
            Column(
              children: [
                Icon(
                  Icons.luggage_outlined,
                  size: 64,
                  color: AppColors.primary.withOpacity(0.18),
                ),
                const SizedBox(height: 16),
                Text(
                  loc.bagEmptyTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.bagEmptyDescription,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            )
          else ...[
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
                child: _buildBagItemCard(item, bagState, loc),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBagItemCard(
    BagItemInBagModel item,
    BagState bagState,
    AppLocalizations loc,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Icon, Name, and Delete Button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: item.icon != null && item.icon!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.icon!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      )
                    : Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
              ),
              const SizedBox(width: 12),
              // Item Name and Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item.category,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Button
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _deleteBagItem(item.itemId, bagState, loc),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bottom Row: Weight and Quantity Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Weight Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.scale_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item.totalWeight.toStringAsFixed(1)} kg',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Quantity Controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (item.quantity > 1) {
                            try {
                              final success = await ref.read(bagControllerProvider.notifier).updateItemQuantity(
                                    itemId: item.itemId,
                                    bagTypeId: bagState.selectedBagType?.id ?? 0,
                                    quantity: item.quantity - 1,
                                  );
                              if (!mounted) return;
                              if (success) {
                                CustomToast.success(context, loc.bagUpdateQuantitySuccess);
                              } else {
                                CustomToast.error(context, loc.bagUpdateQuantityError);
                              }
                            } on ApiException catch (e) {
                              if (!mounted) return;
                              CustomToast.error(context, e.message);
                            } catch (e) {
                              if (!mounted) return;
                              CustomToast.error(context, loc.bagUpdateQuantityError);
                            }
                          }
                        },
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.remove,
                            size: 18,
                            color: item.quantity > 1
                                ? AppColors.primary
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 48,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        border: Border.symmetric(
                          vertical: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                        ),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          try {
                            final success = await ref.read(bagControllerProvider.notifier).updateItemQuantity(
                                  itemId: item.itemId,
                                  bagTypeId: bagState.selectedBagType?.id ?? 0,
                                  quantity: item.quantity + 1,
                                );
                            if (!mounted) return;
                            if (success) {
                              CustomToast.success(context, loc.bagUpdateQuantitySuccess);
                            } else {
                              CustomToast.error(context, loc.bagUpdateQuantityError);
                            }
                          } on ApiException catch (e) {
                            if (!mounted) return;
                            CustomToast.error(context, e.message);
                          } catch (e) {
                            if (!mounted) return;
                            CustomToast.error(context, loc.bagUpdateQuantityError);
                          }
                        },
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBagItem(int itemId, BagState bagState, AppLocalizations loc) async {
    final bagTypeId = bagState.selectedBagType?.id;
    if (bagTypeId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppColors.error,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                loc.bagDeleteItemTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
        content: Text(
          loc.bagDeleteItemMessage,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Cairo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: Text(
              loc.bagDeleteCancel,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              loc.bagDeleteConfirm,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (confirmed == true) {
      try {
        final success = await ref.read(bagControllerProvider.notifier).deleteItemFromBag(
              itemId: itemId,
              bagTypeId: bagTypeId,
            );
        if (!mounted) return;
        if (success) {
          CustomToast.success(context, loc.bagDeleteItemSuccess);
        } else {
          CustomToast.error(context, loc.bagDeleteItemError);
        }
      } on ApiException catch (e) {
        if (!mounted) return;
        CustomToast.error(context, e.message);
      } catch (e) {
        if (!mounted) return;
        CustomToast.error(context, loc.bagDeleteItemError);
      }
    }
  }

  Widget _buildTipsCard(AppLocalizations loc) {
    final tips = [
      loc.bagTip1,
      loc.bagTip2,
      loc.bagTip3,
      loc.bagTip4,
    ];

    return Container(
      decoration: _cardDecoration(backgroundColor: AppColors.bagTipsBackground),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.bagTipsText,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                loc.bagTipsTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bagTipsText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final tip in tips) _buildTipItem(tip),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({Color? backgroundColor}) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 14,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.bagTipsText,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.bagTipsText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BagItemSelection {
  final BagCategoryModel category;
  final BagItemModel item;
  final int quantity;
  final double approxWeight;

  BagItemSelection({
    required this.category,
    required this.item,
    required this.quantity,
    required this.approxWeight,
  });
}

class _AddBagItemSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _AddBagItemSheet({required this.scrollController});

  @override
  ConsumerState<_AddBagItemSheet> createState() => _AddBagItemSheetState();
}

class _AddBagItemSheetState extends ConsumerState<_AddBagItemSheet> {
  final _formKey = GlobalKey<FormState>();
  final _categoryFieldKey =
      GlobalKey<FormFieldState<BagCategoryModel>>();
  final _itemFieldKey = GlobalKey<FormFieldState<BagItemModel>>();

  List<BagCategoryModel> _categories = [];
  List<BagItemModel> _items = [];
  BagCategoryModel? _selectedCategory;
  BagItemModel? _selectedItem;
  bool _isLoadingItems = false;
  String? _itemsError;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    final bagState = ref.read(bagControllerProvider);
    _categories = _dedupeCategories(bagState.categories);

    final initialCategory = bagState.selectedCategory;
    if (initialCategory != null) {
      _selectedCategory =
          _findCategoryById(_categories, initialCategory.id) ??
              (_categories.isNotEmpty ? _categories.first : null);
    } else if (_categories.isNotEmpty) {
      _selectedCategory = _categories.first;
    }

    if (_selectedCategory != null) {
      final initialItems = bagState.selectedCategory?.id == _selectedCategory!.id
          ? bagState.items
          : <BagItemModel>[];
      if (initialItems.isNotEmpty) {
        _items = _dedupeItems(initialItems);
        _selectedItem = _items.isNotEmpty ? _items.first : null;
      } else {
        _loadItems(_selectedCategory!.id);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadItems(int categoryId) async {
    final previousItemId = _selectedItem?.id;
    setState(() {
      _isLoadingItems = true;
      _itemsError = null;
      _items = [];
      _selectedItem = null;
    });
    try {
      final repository = ref.read(bagRepositoryProvider);
      final result = _dedupeItems(await repository.getCategoryItems(categoryId));
      if (!mounted) return;
      setState(() {
        _items = result;
        _selectedItem = previousItemId != null
            ? _findItemById(result, previousItemId)
            : (result.isNotEmpty ? result.first : null);
        _isLoadingItems = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingItems = false;
        _itemsError = e.toString();
      });
    }
  }

  double get _approxWeight {
    final base = _selectedItem?.defaultWeight ?? 0;
    return base * _quantity;
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    final category = _selectedCategory;
    final item = _selectedItem;
    if (category == null || item == null || _quantity <= 0) return;
    Navigator.of(context).pop(
      BagItemSelection(
        category: category,
        item: item,
        quantity: _quantity,
        approxWeight: _approxWeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final canSubmit =
        _selectedCategory != null && _selectedItem != null && _quantity > 0;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          loc.bagAddItemTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      if (_categories.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            loc.bagNoCategories,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      else ...[
                        Text(
                          loc.bagSelectCategory,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<BagCategoryModel>(
                          key: _categoryFieldKey,
                          value: _selectedCategory,
                          decoration: _dropdownDecoration(),
                          items: _categories
                              .map(
                                (category) => DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _categoryIcon(category, false),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          category.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedCategory = value;
                            });
                            _loadItems(value.id);
                          },
                          validator: (value) => value == null
                              ? loc.bagSelectCategoryPlaceholder
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          loc.bagSelectItem,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_itemsError != null)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                loc.bagItemsError,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                onPressed: () {
                                  final category = _selectedCategory;
                                  if (category != null) {
                                    _loadItems(category.id);
                                  }
                                },
                                icon: const Icon(Icons.refresh, size: 18),
                                label: Text(loc.retry),
                              ),
                            ],
                          )
                        else if (_isLoadingItems)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(loc.bagLoadingItems),
                              ],
                            ),
                          )
                        else if (_items.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              loc.bagNoItems,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          DropdownButtonFormField<BagItemModel>(
                            key: _itemFieldKey,
                            value: _selectedItem,
                            decoration: _dropdownDecoration(),
                            items: _items
                                .map(
                                (item) => DropdownMenuItem(
                                  value: item,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _itemIcon(item, false),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          item.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedItem = value;
                              });
                            },
                            validator: (value) => value == null
                                ? loc.bagSelectItemPlaceholder
                                : null,
                          ),
                        const SizedBox(height: 16),
                        Text(
                          loc.bagQuantityLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1.5,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _decrementQuantity,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        bottomLeft: Radius.circular(12),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: _quantity > 1
                                          ? AppColors.primary
                                          : Colors.grey.shade400,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 48,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  border: Border.symmetric(
                                    vertical: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '$_quantity',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _incrementQuantity,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                                                            color: Colors.transparent,

                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          loc.bagApproxWeight(
                            _formatWeight(_approxWeight),
                          ),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            onPressed: canSubmit ? _onSubmit : null,
                            text:
                              loc.bagAddItemSubmit,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  List<BagCategoryModel> _dedupeCategories(List<BagCategoryModel> categories) {
    final seen = <int>{};
    final unique = <BagCategoryModel>[];
    for (final category in categories) {
      if (seen.add(category.id)) {
        unique.add(category);
      }
    }
    return unique;
  }

  BagCategoryModel? _findCategoryById(
    List<BagCategoryModel> categories,
    int id,
  ) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  List<BagItemModel> _dedupeItems(List<BagItemModel> items) {
    final seen = <int>{};
    final unique = <BagItemModel>[];
    for (final item in items) {
      if (seen.add(item.id)) {
        unique.add(item);
      }
    }
    return unique;
  }

  BagItemModel? _findItemById(List<BagItemModel> items, int id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  String _formatWeight(double value) {
    if (value.isNaN || value.isInfinite) return '0';
    if (value % 1 == 0) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(1);
  }

  Widget _categoryIcon(BagCategoryModel category, bool isSelected) {
    if (category.icon != null && category.icon!.isNotEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor:
            isSelected ? Colors.white.withOpacity(0.2) : Colors.grey[200],
        child: ClipOval(
          child: Image.network(
            category.icon!,
            width: 20,
            height: 20,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              Icons.category_outlined,
              size: 18,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return Icon(
      Icons.category_outlined,
      size: 18,
      color: AppColors.primary,
    );
  }

  Widget _itemIcon(BagItemModel item, bool isSelected) {
    if (item.icon != null && item.icon!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          item.icon!,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Icon(
      Icons.inventory_2_outlined,
      color: AppColors.primary,
    );
  }
}
