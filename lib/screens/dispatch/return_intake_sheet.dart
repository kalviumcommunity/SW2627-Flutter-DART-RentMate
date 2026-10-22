import 'package:flutter/material.dart';
import '../../core/services/booking_repository.dart';
import '../../core/services/inventory_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';

/// Modal bottom sheet for warehouse returns and stock reconciliation (Phase 6).
///
/// Enables mobile warehouse staff to categorize returned event equipment as:
/// 1. Returned in Good Condition (increments rentable stock)
/// 2. Damaged / Sent to Service (marks item status as Maintenance)
/// 3. Missing / Lost
class ReturnIntakeSheet extends StatefulWidget {
  final String bookingId;
  final String eventTitle;
  final String clientName;
  final List<Map<String, dynamic>> manifestItems;
  final VoidCallback? onReconciled;

  const ReturnIntakeSheet({
    super.key,
    required this.bookingId,
    required this.eventTitle,
    required this.clientName,
    required this.manifestItems,
    this.onReconciled,
  });

  static Future<void> show(
    BuildContext context, {
    required String bookingId,
    required String eventTitle,
    required String clientName,
    required List<Map<String, dynamic>> manifestItems,
    VoidCallback? onReconciled,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReturnIntakeSheet(
        bookingId: bookingId,
        eventTitle: eventTitle,
        clientName: clientName,
        manifestItems: manifestItems,
        onReconciled: onReconciled,
      ),
    );
  }

  @override
  State<ReturnIntakeSheet> createState() => _ReturnIntakeSheetState();
}

class _ReturnIntakeSheetState extends State<ReturnIntakeSheet> {
  // Map of sku -> { 'good': int, 'damaged': int, 'missing': int, 'note': String }
  final Map<String, Map<String, dynamic>> _reconciledState = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.manifestItems) {
      final sku = item['sku'] as String;
      final qty = (item['qty'] as num).toInt();
      _reconciledState[sku] = {
        'good': qty,
        'damaged': 0,
        'missing': 0,
        'note': '',
      };
    }
  }

  void _markAllGood() {
    setState(() {
      for (final item in widget.manifestItems) {
        final sku = item['sku'] as String;
        final qty = (item['qty'] as num).toInt();
        _reconciledState[sku] = {
          'good': qty,
          'damaged': 0,
          'missing': 0,
          'note': '',
        };
      }
    });
  }

  int get _totalGood =>
      _reconciledState.values.fold(0, (sum, val) => sum + (val['good'] as int));

  int get _totalDamaged =>
      _reconciledState.values.fold(0, (sum, val) => sum + (val['damaged'] as int));

  int get _totalMissing =>
      _reconciledState.values.fold(0, (sum, val) => sum + (val['missing'] as int));

  bool get _isValid {
    for (final item in widget.manifestItems) {
      final sku = item['sku'] as String;
      final qty = (item['qty'] as num).toInt();
      final state = _reconciledState[sku] ?? {'good': 0, 'damaged': 0, 'missing': 0};
      final sum = (state['good'] as int) + (state['damaged'] as int) + (state['missing'] as int);
      if (sum != qty) return false;
    }
    return true;
  }

  void _submitReconciliation() {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.warning,
          content: Text('Please ensure categorized items match total deployed counts exactly.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final inventoryRepo = InventoryRepository();
    final bookingRepo = BookingRepository();

    // Reconcile each item into inventory
    for (final entry in _reconciledState.entries) {
      final sku = entry.key;
      final val = entry.value;
      inventoryRepo.reconcileReturn(
        sku: sku,
        goodQty: val['good'] as int,
        damagedQty: val['damaged'] as int,
        missingQty: val['missing'] as int,
      );
    }

    // Advance booking status to COMPLETED
    bookingRepo.updateBookingStatus(widget.bookingId, 'COMPLETED');

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Navigator.of(context).pop();
        widget.onReconciled?.call();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.inkBlack,
            content: Text(
              'Return Reconciled for #${widget.bookingId}: $_totalGood returned to stock, $_totalDamaged to service, $_totalMissing missing.',
              style: const TextStyle(color: AppColors.bone),
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bone,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.softStone,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.burntCopper.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'RETURN INTAKE & RECONCILIATION',
                              style: AppTextStyles.monoLabel.copyWith(
                                fontSize: 9,
                                color: AppColors.burntCopper,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.bookingId,
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 11,
                              color: AppColors.slate,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.eventTitle,
                        style: AppTextStyles.screenTitle.copyWith(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.inkBlack),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.softStone, height: 1),

          // Quick Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: AppColors.paper,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'INCOMING GEAR VERIFICATION',
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 10,
                    color: AppColors.slate,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton.icon(
                  onPressed: _markAllGood,
                  icon: const Icon(Icons.done_all_rounded, size: 16, color: AppColors.success),
                  label: Text(
                    'All Good (Rapid Intake)',
                    style: AppTextStyles.monoLabel.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w800,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Scrollable Manifest Items
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              itemCount: widget.manifestItems.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final item = widget.manifestItems[index];
                return _buildReconciliationCard(item);
              },
            ),
          ),

          // Bottom Summary & Submit Action
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.paper,
              border: const Border(top: BorderSide(color: AppColors.softStone)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quick Totals Pill Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPillSummary('Good / Restock', '+$_totalGood', AppColors.success),
                    _buildPillSummary('Maintenance', '$_totalDamaged', AppColors.warning),
                    _buildPillSummary('Missing / Lost', '$_totalMissing', Colors.red),
                  ],
                ),
                const SizedBox(height: 14),
                RentFlowButton(
                  label: _isSubmitting
                      ? 'Reconciling Inventory...'
                      : 'Submit Return & Reconcile Stock',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: _isSubmitting,
                  onPressed: _isValid ? _submitReconciliation : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillSummary(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: AppTextStyles.monoMetric.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.monoLabel.copyWith(
            fontSize: 9,
            color: AppColors.slate,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildReconciliationCard(Map<String, dynamic> item) {
    final sku = item['sku'] as String;
    final name = item['name'] as String;
    final totalQty = (item['qty'] as num).toInt();
    final state = _reconciledState[sku] ?? {'good': 0, 'damaged': 0, 'missing': 0, 'note': ''};

    final good = state['good'] as int;
    final damaged = state['damaged'] as int;
    final missing = state['missing'] as int;
    final sum = good + damaged + missing;
    final isMatched = sum == totalQty;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bone,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMatched ? AppColors.softStone : AppColors.warning,
          width: isMatched ? 1 : 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item Details Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.copperSubtle,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${totalQty}x',
                  style: AppTextStyles.monoLabel.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.burntCopper,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.cardTitle.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      sku,
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 10,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isMatched ? AppColors.successSubtle : AppColors.warningSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isMatched ? '$sum / $totalQty RECONCILED' : '$sum / $totalQty DISCREPANCY',
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 9,
                    color: isMatched ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Stepper Counters for Good, Damaged, Missing
          Row(
            children: [
              Expanded(
                child: _buildCounterCategory(
                  label: 'Good (Rentable)',
                  count: good,
                  color: AppColors.success,
                  onChanged: (newVal) {
                    if (newVal >= 0 && newVal <= totalQty) {
                      setState(() => state['good'] = newVal);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCounterCategory(
                  label: 'Damaged / Service',
                  count: damaged,
                  color: AppColors.warning,
                  onChanged: (newVal) {
                    if (newVal >= 0 && newVal <= totalQty) {
                      setState(() => state['damaged'] = newVal);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCounterCategory(
                  label: 'Missing / Lost',
                  count: missing,
                  color: Colors.red,
                  onChanged: (newVal) {
                    if (newVal >= 0 && newVal <= totalQty) {
                      setState(() => state['missing'] = newVal);
                    }
                  },
                ),
              ),
            ],
          ),

          if (damaged > 0) ...[
            const SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Damage notes (e.g. Broken XLR port, lens scratch)',
                hintStyle: AppTextStyles.monoLabel.copyWith(color: AppColors.slate, fontSize: 11),
                filled: true,
                fillColor: AppColors.paper,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.softStone),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColors.softStone),
                ),
              ),
              style: AppTextStyles.bodySmall.copyWith(fontSize: 12),
              onChanged: (txt) => state['note'] = txt,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounterCategory({
    required String label,
    required int count,
    required Color color,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.monoLabel.copyWith(
              fontSize: 9,
              color: color,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () => onChanged(count - 1),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bone,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.softStone),
                  ),
                  child: const Icon(Icons.remove, size: 14, color: AppColors.inkBlack),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$count',
                  style: AppTextStyles.monoMetric.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.inkBlack,
                  ),
                ),
              ),
              InkWell(
                onTap: () => onChanged(count + 1),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.bone,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.softStone),
                  ),
                  child: const Icon(Icons.add, size: 14, color: AppColors.inkBlack),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
