import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:season_app/core/constants/app_colors.dart';
import 'package:season_app/core/localization/generated/l10n.dart';
import 'package:season_app/features/reminders/data/models/reminder_model.dart';

class ReminderListItem extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const ReminderListItem({
    super.key,
    required this.reminder,
    required this.onTap,
    required this.onDelete,
  });

  String _formatDate(BuildContext context) {
    try {
      final date = DateTime.parse(reminder.date);
      return intl.DateFormat.yMMMMd(intl.Intl.getCurrentLocale()).format(date);
    } catch (_) {
      return reminder.date;
    }
  }

  String _formatTime(BuildContext context) {
    try {
      final parts = reminder.time.split(':');
      final dateTime = DateTime(
        0,
        1,
        1,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      return intl.DateFormat.jm(intl.Intl.getCurrentLocale()).format(dateTime);
    } catch (_) {
      return reminder.time;
    }
  }

  String _recurrenceLabel(BuildContext context) {
    final recurrence = reminder.recurrence.toLowerCase();
    final loc = AppLocalizations.of(context);
    if (recurrence.contains('once') || recurrence.contains('مرة')) {
      return loc.reminderRecurrenceOnce;
    } else if (recurrence.contains('daily') || recurrence.contains('يومي')) {
      return loc.reminderRecurrenceDaily;
    } else if (recurrence.contains('week') || recurrence.contains('أسبوع')) {
      return loc.reminderRecurrenceWeekly;
    } else if (recurrence.contains('custom') || recurrence.contains('مخصص')) {
      return loc.reminderRecurrenceCustom;
    }
    return reminder.recurrence;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final isActive = reminder.status == 'active';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.12)
              : AppColors.border,
          width: isActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Status Indicator
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? AppColors.success
                        : AppColors.textSecondary.withOpacity(0.5),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (reminder.notes != null && reminder.notes!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          reminder.notes!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          _metaItem(
                            icon: Icons.calendar_today,
                            text: _formatDate(context),
                          ),
                          _metaItem(
                            icon: Icons.access_time,
                            text: _formatTime(context),
                          ),
                          _metaChip(_recurrenceLabel(context)),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Actions
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.error),
                  onPressed: onDelete,
                  tooltip: loc.bagDeleteConfirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _metaItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _metaChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

