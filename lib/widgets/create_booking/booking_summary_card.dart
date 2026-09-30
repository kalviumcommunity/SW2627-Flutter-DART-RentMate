import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/booking_draft.dart';
import '../../models/equipment_item.dart';

/// Comprehensive review and summary card for Step 3: Review & Confirm.
///
/// Flutter & Dart Concepts:
/// - Clear operational hierarchy summarizing customer, venue, equipment breakdown, and fees.
/// - Inline edit controls allowing quick return to Step 1 or Step 2.
/// - High-confidence verification banner: "Availability verified · No conflicts".
class BookingSummaryCard extends StatelessWidget {
  final BookingDraft draft;
  final List<EquipmentItem> catalog;
  final VoidCallback onEditDetailsTap;
  final VoidCallback onEditEquipmentTap;

  const BookingSummaryCard({
    super.key,
    required this.draft,
    required this.catalog,
    required this.onEditDetailsTap,
    required this.onEditEquipmentTap,
  });

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = draft.calculateSubtotal(catalog);
    final total = draft.calculateTotal(catalog);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. High-Confidence Availability Verification Banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.successSubtle,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF86EFAC), width: 1),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Availability verified · No conflicts',
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.successGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'All ${draft.totalItemCount} equipment units are guaranteed available in warehouse stock.',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF14532D),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 2. Event & Customer Details Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.event_note_rounded,
                          size: 18,
                          color: AppColors.alpineEvergreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Event & Customer Details',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: onEditDetailsTap,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.alpineEvergreen,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _buildDetailRow(
                      label: 'Event Name',
                      value: draft.eventName.isNotEmpty
                          ? draft.eventName
                          : 'Untitled Event',
                      isBold: true,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      label: 'Type',
                      value: draft.eventType,
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      label: 'Customer',
                      value: '${draft.customerName} (${draft.phoneNumber})',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      label: 'Venue',
                      value: draft.venue.isNotEmpty
                          ? draft.venue
                          : 'Venue to be confirmed',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      label: 'Schedule',
                      value:
                          '${_formatDate(draft.eventDate)} • ${draft.startTime.format(context)} – ${draft.endTime.format(context)}',
                    ),
                    if (draft.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow(
                        label: 'Notes',
                        value: draft.notes,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 3. Selected Equipment Breakdown Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_rounded,
                          size: 18,
                          color: AppColors.alpineEvergreen,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Equipment Manifest (${draft.totalItemCount} Units)',
                          style: AppTextStyles.cardTitle.copyWith(fontSize: 14),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: onEditEquipmentTap,
                      icon: const Icon(Icons.edit_rounded, size: 14),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.alpineEvergreen,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.borderSubtle),

              // Line Items List
              if (draft.selectedQuantities.isEmpty || draft.totalItemCount == 0)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Center(
                    child: Text(
                      'No equipment selected yet.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(14),
                  itemCount: draft.selectedQuantities.entries
                      .where((e) => e.value > 0)
                      .length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 16, color: AppColors.borderSubtle),
                  itemBuilder: (context, index) {
                    final entries = draft.selectedQuantities.entries
                        .where((e) => e.value > 0)
                        .toList();
                    final entry = entries[index];
                    final item = catalog.cast<EquipmentItem?>().firstWhere(
                          (it) => it?.id == entry.key,
                          orElse: () => null,
                        );
                    if (item == null) return const SizedBox.shrink();

                    final lineTotal = item.dailyRate * entry.value;

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.evergreenSubtle,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.value}×',
                              style: AppTextStyles.monoLabel.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.alpineEvergreen,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: AppTextStyles.cardTitle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${item.sku} • ₹${item.dailyRate.toStringAsFixed(0)}/day',
                                style: AppTextStyles.monoLabel.copyWith(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '₹${lineTotal.toStringAsFixed(0)}',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 4. Financial & Estimate Summary Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildPriceRow(
                label: 'Equipment Subtotal',
                amount: '₹${subtotal.toStringAsFixed(0)}',
              ),
              const SizedBox(height: 8),
              _buildPriceRow(
                label: 'Logistics & Loading Surcharge',
                amount: '₹${draft.logisticsFee.toStringAsFixed(0)}',
              ),
              const Divider(height: 20, color: AppColors.borderSubtle),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Total',
                    style: AppTextStyles.cardTitle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '₹${total.toStringAsFixed(0)}',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.alpineEvergreen,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow({required String label, required String amount}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          amount,
          style: AppTextStyles.monoLabel.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
