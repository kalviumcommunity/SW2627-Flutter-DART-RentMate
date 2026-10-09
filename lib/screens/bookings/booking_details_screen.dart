import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';

/// Full Booking Detail Screen (RentFlow Section 5.4 - 5.8).
///
/// Features:
/// - Status timeline tracker (Confirmed -> Packing -> Dispatched -> Returned).
/// - Client contact card with instant call/email action buttons.
/// - Venue, timing, and logistics overview.
/// - Complete Itemized Equipment Manifest with SKUs.
/// - Financial summary and deposit tracker.
class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  final String eventTitle;
  final String clientName;
  final String clientPhone;
  final String venue;
  final String dates;
  final String status;
  final int totalItems;
  final double grandTotal;

  const BookingDetailsScreen({
    super.key,
    this.bookingId = 'BK-8942',
    this.eventTitle = 'Sharma Royal Wedding & Sangeet',
    this.clientName = 'Rajesh Sharma',
    this.clientPhone = '+91 98765 43210',
    this.venue = 'The Oberoi Rajvilas, Jaipur',
    this.dates = '14 Oct 2026, 10:00 AM — 15 Oct 2026, 11:30 PM',
    this.status = 'READY',
    this.totalItems = 24,
    this.grandTotal = 48500.0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bone,
      appBar: AppBar(
        backgroundColor: AppColors.bone,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.inkBlack),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Details',
              style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            Text(
              'RESERVATION #$bookingId',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: AppColors.burntCopper,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.slate),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Generating Dispatch Manifest PDF...')),
              );
            },
            tooltip: 'Print Manifest',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: AppColors.slate),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Status Banner
              _buildStatusTimeline(),
              const SizedBox(height: 18),

              // Event Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.softStone),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.copperSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'WEDDING RECEPTION',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 9,
                              color: AppColors.burntCopper,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          bookingId,
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      eventTitle,
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetaRow(Icons.location_on_outlined, venue),
                    _buildMetaRow(Icons.calendar_month_outlined, dates),
                    _buildMetaRow(Icons.inventory_2_outlined, '$totalItems Total Units Reserved'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Client Contact Tile
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.paper,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.softStone),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.copperSubtle,
                      child: Text(
                        clientName.substring(0, 1),
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.burntCopper,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            clientPhone,
                            style: AppTextStyles.monoData.copyWith(
                              fontSize: 11,
                              color: AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_outlined, color: AppColors.burntCopper, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Calling $clientPhone...')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, color: AppColors.burntCopper, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening chat with $clientName...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Equipment Manifest Section
              Text(
                'EQUIPMENT MANIFEST ($totalItems UNITS)',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 11,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),

              _buildManifestItem('JBL VRX932LA Line Array Speaker', 'SND-JBL-VRX932', 4, 1500.0),
              _buildManifestItem('Sharpy 230W 7R Beam Moving Head', 'LGT-SHARPY-230', 6, 850.0),
              _buildManifestItem('P3.91 High-Res LED Video Wall (500x500mm)', 'VIS-LED-P391', 8, 1200.0),
              _buildManifestItem('Heavy Duty Aluminum Box Truss (3m)', 'STG-TRS-3M', 4, 600.0),
              _buildManifestItem('Shure ULXD4 Wireless Dual Mic Set', 'SND-SHURE-ULXD', 2, 950.0),
              const SizedBox(height: 16),

              // Financial Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.inkBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL ESTIMATE',
                          style: AppTextStyles.monoLabel.copyWith(
                            color: AppColors.bone.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'DEPOSIT RECEIVED',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${grandTotal.toInt()}',
                      style: AppTextStyles.monoMetric.copyWith(
                        color: AppColors.burntCopper,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              RentFlowButton(
                label: 'Open Warehouse Dispatch Checklist',
                icon: Icons.local_shipping_outlined,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening Dispatch Checklist for #BK-8942...')),
                  );
                },
              ),
              const SizedBox(height: 10),
              RentFlowSecondaryButton(
                label: 'Modify Booking Manifest',
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DISPATCH LIFECYCLE',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 10,
                  color: AppColors.slate,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.successSubtle,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 10,
                    color: AppColors.success,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildTimelineStep('Confirmed', true, true),
              _buildTimelineLine(true),
              _buildTimelineStep('Packing', true, true),
              _buildTimelineLine(true),
              _buildTimelineStep('Ready', true, true),
              _buildTimelineLine(false),
              _buildTimelineStep('Dispatched', false, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String label, bool isDone, bool isCurrent) {
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone ? AppColors.burntCopper : AppColors.bone,
            border: Border.all(
              color: isDone ? AppColors.burntCopper : AppColors.softStone,
              width: 2,
            ),
          ),
          child: isDone
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.monoLabel.copyWith(
            fontSize: 8,
            color: isDone ? AppColors.inkBlack : AppColors.slate,
            fontWeight: isDone ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isDone) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 14),
        color: isDone ? AppColors.burntCopper : AppColors.softStone,
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.burntCopper),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.inkBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManifestItem(String name, String sku, int qty, double rate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.copperSubtle,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${qty}x',
              style: AppTextStyles.monoLabel.copyWith(
                fontSize: 10,
                color: AppColors.burntCopper,
                fontWeight: FontWeight.w800,
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
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.inkBlack,
                  ),
                ),
                Text(
                  sku,
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 9,
                    color: AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₹${(qty * rate).toInt()}',
            style: AppTextStyles.monoData.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
