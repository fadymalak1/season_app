import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/localization/generated/l10n.dart';
import 'package:season_app/features/reminders/data/models/reminder_model.dart';
import 'package:season_app/features/reminders/presentation/widgets/add_reminder_modal.dart';
import 'package:season_app/features/reminders/presentation/widgets/reminder_list_item.dart';
import 'package:season_app/features/reminders/providers.dart';

class BagPage extends ConsumerStatefulWidget {
  const BagPage({super.key});

  @override
  ConsumerState<BagPage> createState() => _BagPageState();
}

class _BagPageState extends ConsumerState<BagPage> {
  double _currentWeight = 0.0;
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

    if (confirmed == true) {
      final success =
          await ref.read(remindersProvider.notifier).deleteReminder(reminderId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.bagDeleteSuccess),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final remindersState = ref.watch(remindersProvider);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(loc),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  displacement: 48,
                  onRefresh: () =>
                      ref.read(remindersProvider.notifier).loadReminders(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildActionButtons(loc),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildRemindersSection(remindersState, loc),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildBagStatusCard(loc),
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
      ),
    );
  }

  Widget _buildHeader(AppLocalizations loc) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.luggage, color: Colors.white, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loc.bagTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      loc.bagSubtitle,
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
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.edit,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
                Text(
                  loc.bagWeight(
                    _currentWeight.toStringAsFixed(1),
                    _maxWeight.toStringAsFixed(0),
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
        ],
      ),
    );
  }

  Widget _buildActionButtons(AppLocalizations loc) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.white),
            label: Text(
              loc.bagAddItemButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bagPrimaryButton,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(
              Icons.auto_awesome,
              color: AppColors.bagSecondaryButtonText,
            ),
            label: Text(
              loc.bagAISuggestionsButton,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.bagSecondaryButtonBackground,
              foregroundColor: AppColors.bagSecondaryButtonText,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
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
              color: AppColors.textSecondary.withOpacity(0.35),
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

  Widget _buildBagStatusCard(AppLocalizations loc) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(16),
      child: Column(
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
      ),
    );
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
