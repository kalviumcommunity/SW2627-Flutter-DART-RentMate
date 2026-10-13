import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/rentflow_button.dart';

/// Full Booking Detail Screen (RentFlow Section 5.4 - 5.8).
///
/// Features:
/// - Dynamic status timeline tracker (Confirmed -> Packing -> Ready -> Dispatched -> Completed).
/// - Client contact card with instant call/email action buttons.
/// - Venue, timing, and logistics overview.
/// - Dynamic Itemized Equipment Manifest tailored to event category with SKUs.
/// - Transparent financial breakdown and deposit tracker.
class BookingDetailsScreen extends StatelessWidget {
  final String bookingId;
  final String eventTitle;
  final String clientName;
  final String clientPhone;
  final String venue;
  final String dates;
  final String status;
  final String category;
  final int totalItems;
  final double grandTotal;
  final List<Map<String, dynamic>>? manifestItems;

  const BookingDetailsScreen({
    super.key,
    this.bookingId = 'BK-8942',
    this.eventTitle = 'Sharma Royal Wedding & Sangeet',
    this.clientName = 'Rajesh Sharma',
    this.clientPhone = '+91 98765 43210',
    this.venue = 'The Oberoi Rajvilas, Jaipur',
    this.dates = '14 Oct 2026, 10:00 AM — 15 Oct 2026, 11:30 PM',
    this.status = 'READY',
    this.category = 'Wedding',
    this.totalItems = 24,
    this.grandTotal = 48500.0,
    this.manifestItems,
  });

  List<Map<String, dynamic>> _getEffectiveManifestItems() {
    if (manifestItems != null && manifestItems!.isNotEmpty) {
      return manifestItems!;
    }
    final cat = category.toLowerCase();
    if (cat.contains('corporate') ||
        eventTitle.toLowerCase().contains('summit') ||
        eventTitle.toLowerCase().contains('launch')) {
      return const [
        {'name': 'd&b audiotechnik V-Series Array Module', 'sku': 'AU-DB-V8', 'qty': 4, 'rate': 2200.0},
        {'name': 'P3.91 High-Res LED Video Wall (500x500mm)', 'sku': 'VIS-LED-P391', 'qty': 16, 'rate': 1200.0},
        {'name': 'Shure Axient Digital Wireless Podium Kit', 'sku': 'SND-SHURE-AXD', 'qty': 4, 'rate': 1100.0},
        {'name': 'Barco E2 Gen 2 4K Presentation Switcher', 'sku': 'VIS-BARCO-E2', 'qty': 1, 'rate': 4500.0},
        {'name': 'Robe Robin MegaPointe Moving Head', 'sku': 'LGT-ROBE-MP', 'qty': 6, 'rate': 950.0},
      ];
    } else if (cat.contains('fashion') || cat.contains('gala') || cat.contains('private')) {
      return const [
        {'name': 'Heavy Duty Aluminum Box Truss (3m)', 'sku': 'STG-TRS-3M', 'qty': 8, 'rate': 600.0},
        {'name': 'Sharpy 230W 7R Beam Moving Head', 'sku': 'LGT-SHARPY-230', 'qty': 8, 'rate': 850.0},
        {'name': 'Martin MAC Quantum Profile Moving Head', 'sku': 'LGT-MARTIN-MQ', 'qty': 6, 'rate': 1100.0},
        {'name': 'JBL PRX815W Powered Loudspeaker', 'sku': 'SND-JBL-PRX', 'qty': 4, 'rate': 750.0},
        {'name': 'P2.6 Ultra-Fine LED Runway Display', 'sku': 'VIS-LED-P26', 'qty': 4, 'rate': 1800.0},
      ];
    }
    return const [
      {'name': 'JBL VRX932LA Line Array Speaker', 'sku': 'SND-JBL-VRX932', 'qty': 4, 'rate': 1500.0},
      {'name': 'Sharpy 230W 7R Beam Moving Head', 'sku': 'LGT-SHARPY-230', 'qty': 6, 'rate': 850.0},
      {'name': 'P3.91 High-Res LED Video Wall (500x500mm)', 'sku': 'VIS-LED-P391', 'qty': 8, 'rate': 1200.0},
      {'name': 'Heavy Duty Aluminum Box Truss (3m)', 'sku': 'STG-TRS-3M', 'qty': 4, 'rate': 600.0},
      {'name': 'Shure ULXD4 Wireless Dual Mic Set', 'sku': 'SND-SHURE-ULXD', 'qty': 2, 'rate': 950.0},
    ];
  }

  int get _currentStepIndex {
    switch (status.toUpperCase()) {
      case 'CONFIRMED':
        return 0;
      case 'PACKING':
        return 1;
      case 'READY':
        return 2;
      case 'DISPATCHED':
        return 3;
      case 'COMPLETED':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveItems = _getEffectiveManifestItems();
    final double gearSubtotal = effectiveItems.fold(
      0.0,
      (sum, item) => sum + ((item['qty'] as num) * (item['rate'] as num)),
    );
    final double logisticsAndCrew =
        (grandTotal > gearSubtotal) ? (grandTotal - gearSubtotal) : 0.0;

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
                SnackBar(content: Text('Generating Dispatch Manifest PDF for #$bookingId...')),
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
                            category.toUpperCase(),
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
                        clientName.isNotEmpty ? clientName.substring(0, 1) : 'C',
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

              ...effectiveItems.map((item) {
                return _buildManifestItem(
                  item['name'] as String,
                  item['sku'] as String,
                  item['qty'] as int,
                  (item['rate'] as num).toDouble(),
                );
              }),
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
                    const SizedBox(height: 10),
                    Divider(color: AppColors.slate.withValues(alpha: 0.5), height: 1),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Manifest Gear Subtotal',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 10,
                            color: AppColors.bone.withValues(alpha: 0.7),
                          ),
                        ),
                        Text(
                          '₹${gearSubtotal.toInt()}',
                          style: AppTextStyles.monoLabel.copyWith(
                            fontSize: 10,
                            color: AppColors.bone,
                          ),
                        ),
                      ],
                    ),
                    if (logisticsAndCrew > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Logistics, Crew & Insurance',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 10,
                              color: AppColors.bone.withValues(alpha: 0.7),
                            ),
                          ),
                          Text(
                            '₹${logisticsAndCrew.toInt()}',
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 10,
                              color: AppColors.bone,
                            ),
                          ),
                        ],
                      ),
                    ],
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
                    SnackBar(content: Text('Opening Dispatch Checklist for #$bookingId...')),
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
    final step = _currentStepIndex;
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
              _buildTimelineStep('Confirmed', step >= 0, step == 0),
              _buildTimelineLine(step >= 1),
              _buildTimelineStep('Packing', step >= 1, step == 1),
              _buildTimelineLine(step >= 2),
              _buildTimelineStep('Ready', step >= 2, step == 2),
              _buildTimelineLine(step >= 3),
              _buildTimelineStep('Dispatched', step >= 3, step >= 3),
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.paper,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.softStone),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.bone,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '${qty}x',
                style: AppTextStyles.monoLabel.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.burntCopper,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(qty * rate).toInt()}',
                style: AppTextStyles.monoData.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkBlack,
                ),
              ),
              Text(
                '₹${rate.toInt()}/day',
                style: AppTextStyles.monoLabel.copyWith(
                  fontSize: 9,
                  color: AppColors.slate,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
