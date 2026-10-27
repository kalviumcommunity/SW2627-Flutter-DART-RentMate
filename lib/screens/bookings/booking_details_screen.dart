import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/availability_service.dart';
import '../../core/services/booking_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/equipment_scan_dialog.dart';
import '../../widgets/rentflow_button.dart';
import '../dispatch/return_intake_sheet.dart';

/// Full Booking Detail Screen (RentFlow Section 5.4 - 5.8 & Phase 6).
///
/// Features:
/// - Dynamic status timeline tracker (Confirmed -> Packing -> Ready -> Dispatched -> Completed).
/// - Client contact card with instant call/email action buttons.
/// - Venue, timing, and logistics overview.
/// - Dynamic Itemized Equipment Manifest tailored to event category with SKUs.
/// - Interactive packing checklist with checkboxes for warehouse crew to check off flight cases (Phase 6).
/// - Barcode & QR code scanning modal integration (resolves GLITCH-09).
/// - Direct trigger for Returns & Reconciliation Intake Sheet (Phase 6).
class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String eventTitle;
  final String clientName;
  final String clientPhone;
  final String venue;
  final String dates;
  final String status;
  final int totalItems;
  final double grandTotal;
  final String category;
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
    this.totalItems = 24,
    this.grandTotal = 48500.0,
    this.category = 'Wedding',
    this.manifestItems,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late String _currentStatus;
  final Set<String> _loadedSkus = {};
  late List<Map<String, dynamic>> _effectiveItems;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.status;
    _effectiveItems = _computeEffectiveManifestItems();

    // Sync persistent checklist progress from booking repository
    final repoBooking = BookingRepository().getBookingById(widget.bookingId);
    if (repoBooking != null && repoBooking.packedSkus.isNotEmpty) {
      _loadedSkus.addAll(repoBooking.packedSkus);
    } else {
      // If booking is already READY, DISPATCHED, or COMPLETED, default items to loaded
      final upper = _currentStatus.toUpperCase();
      if (upper == 'READY' || upper == 'DISPATCHED' || upper == 'COMPLETED') {
        for (final item in _effectiveItems) {
          _loadedSkus.add(item['sku'] as String);
        }
      } else if (upper == 'PACKING') {
        // Partially packed for demo
        if (_effectiveItems.isNotEmpty) {
          _loadedSkus.add(_effectiveItems.first['sku'] as String);
        }
      }
    }
  }

  List<Map<String, dynamic>> _computeEffectiveManifestItems() {
    if (widget.manifestItems != null && widget.manifestItems!.isNotEmpty) {
      return List.from(widget.manifestItems!);
    }
    final cat = widget.category.toLowerCase();
    if (cat.contains('corporate') ||
        widget.eventTitle.toLowerCase().contains('summit') ||
        widget.eventTitle.toLowerCase().contains('launch')) {
      return [
        {
          'name': 'd&b audiotechnik V-Series Array Module',
          'sku': 'AU-DB-V8',
          'flightCase': 'FC-A-14',
          'bay': 'BAY-01-A',
          'qty': 4,
          'rate': 2200.0,
        },
        {
          'name': 'P3.91 High-Res LED Video Wall (500x500mm)',
          'sku': 'VIS-LED-P391',
          'flightCase': 'FC-V-08',
          'bay': 'BAY-06-C',
          'qty': 16,
          'rate': 1200.0,
        },
        {
          'name': 'Shure Axient Digital Wireless Podium Kit',
          'sku': 'SND-SHURE-AXD',
          'flightCase': 'FC-MIC-02',
          'bay': 'CTRL-BENCH-1',
          'qty': 4,
          'rate': 1100.0,
        },
        {
          'name': 'Barco E2 Gen 2 4K Presentation Switcher',
          'sku': 'VIS-BARCO-E2',
          'flightCase': 'FC-C-02',
          'bay': 'CTRL-ROOM-1',
          'qty': 1,
          'rate': 4500.0,
        },
        {
          'name': 'Robe Robin MegaPointe Moving Head',
          'sku': 'LGT-ROBE-MP',
          'flightCase': 'FC-L-06',
          'bay': 'BAY-02-B',
          'qty': 6,
          'rate': 950.0,
        },
      ];
    } else if (cat.contains('fashion') || cat.contains('gala') || cat.contains('private')) {
      return [
        {
          'name': 'Heavy Duty Aluminum Box Truss (3m)',
          'sku': 'STG-TRS-3M',
          'flightCase': 'TR-BDL-08',
          'bay': 'YARD-DOCK-2',
          'qty': 8,
          'rate': 600.0,
        },
        {
          'name': 'Sharpy 230W 7R Beam Moving Head',
          'sku': 'LGT-SHARPY-230',
          'flightCase': 'FC-L-04',
          'bay': 'BAY-02-A',
          'qty': 8,
          'rate': 850.0,
        },
        {
          'name': 'Martin MAC Quantum Profile Moving Head',
          'sku': 'LGT-MARTIN-MQ',
          'flightCase': 'FC-L-09',
          'bay': 'BAY-03-A',
          'qty': 6,
          'rate': 1100.0,
        },
        {
          'name': 'JBL PRX815W Powered Loudspeaker',
          'sku': 'SND-JBL-PRX',
          'flightCase': 'FC-A-04',
          'bay': 'BAY-01-B',
          'qty': 4,
          'rate': 750.0,
        },
        {
          'name': 'P2.6 Ultra-Fine LED Runway Display',
          'sku': 'VIS-LED-P26',
          'flightCase': 'FC-V-02',
          'bay': 'BAY-06-A',
          'qty': 4,
          'rate': 1800.0,
        },
      ];
    }
    return [
      {
        'name': 'JBL VRX932LA Line Array Speaker',
        'sku': 'SND-JBL-VRX932',
        'flightCase': 'FC-A-12',
        'bay': 'RIG-01-A',
        'qty': 4,
        'rate': 1500.0,
      },
      {
        'name': 'Sharpy 230W 7R Beam Moving Head',
        'sku': 'LGT-SHARPY-230',
        'flightCase': 'FC-L-04',
        'bay': 'BAY-02-A',
        'qty': 6,
        'rate': 850.0,
      },
      {
        'name': 'P3.91 High-Res LED Video Wall (500x500mm)',
        'sku': 'VIS-LED-P391',
        'flightCase': 'FC-V-08',
        'bay': 'BAY-06-C',
        'qty': 8,
        'rate': 1200.0,
      },
      {
        'name': 'Heavy Duty Aluminum Box Truss (3m)',
        'sku': 'STG-TRS-3M',
        'flightCase': 'TR-BDL-08',
        'bay': 'YARD-DOCK-2',
        'qty': 4,
        'rate': 600.0,
      },
      {
        'name': 'Shure ULXD4 Wireless Dual Mic Set',
        'sku': 'SND-SHURE-ULXD',
        'flightCase': 'FC-MIC-01',
        'bay': 'CTRL-BENCH-1',
        'qty': 2,
        'rate': 950.0,
      },
    ];
  }

  int get _currentStepIndex {
    switch (_currentStatus.toUpperCase()) {
      case 'CONFIRMED':
        return 0;
      case 'PACKING':
        return 1;
      case 'READY':
        return 2;
      case 'DISPATCHED':
      case 'ON STAGE':
        return 3;
      case 'RETURNED':
      case 'COMPLETED':
      case 'AWAITING RETURN':
        return 4;
      default:
        return 0;
    }
  }

  void _openBarcodeScanner(BuildContext context) {
    final skus = _effectiveItems
        .map((i) => [i['sku'].toString(), (i['flightCase'] ?? '').toString()])
        .expand((x) => x)
        .where((s) => s.isNotEmpty)
        .toList();

    EquipmentScanDialog.show(
      context,
      title: 'MANIFEST CHECKLIST SCAN',
      subtitle: 'Scan flight case barcode to verify loading for #${widget.bookingId}',
      targetSkus: skus,
      onScanned: (scannedCode) {
        final code = scannedCode.trim().toUpperCase();
        String? matchedSku;

        for (final item in _effectiveItems) {
          if (item['sku'].toString().toUpperCase() == code ||
              (item['flightCase'] != null &&
                  item['flightCase'].toString().toUpperCase() == code)) {
            matchedSku = item['sku'] as String;
            break;
          }
        }

        if (matchedSku != null) {
          setState(() {
            _loadedSkus.add(matchedSku!);
            if (_loadedSkus.length == _effectiveItems.length) {
              if (_currentStatus == 'PACKING' || _currentStatus == 'CONFIRMED') {
                _currentStatus = 'READY';
                BookingRepository().updateBookingStatus(widget.bookingId, 'READY');
              }
            } else if (_currentStatus == 'CONFIRMED') {
              _currentStatus = 'PACKING';
              BookingRepository().updateBookingStatus(widget.bookingId, 'PACKING');
            }
          });
          BookingRepository().updateBookingChecklist(widget.bookingId, _loadedSkus.toList());

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.inkBlack,
              content: Text(
                'Flight Case $code verified & checked off as loaded into vehicle!',
                style: const TextStyle(color: AppColors.bone),
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
    );
  }

  void _openReturnIntakeSheet(BuildContext context) {
    ReturnIntakeSheet.show(
      context,
      bookingId: widget.bookingId,
      eventTitle: widget.eventTitle,
      clientName: widget.clientName,
      manifestItems: _effectiveItems,
      onReconciled: () {
        setState(() {
          _currentStatus = 'COMPLETED';
        });
      },
    );
  }

  void _confirmCancelBooking(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text('Cancel Reservation?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel booking #${widget.bookingId}? This will immediately release all ${widget.totalItems} equipment items back into available warehouse capacity.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Booking', style: TextStyle(color: AppColors.slate)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await AvailabilityService().cancelBooking(widget.bookingId);
                setState(() {
                  _currentStatus = 'CANCELLED';
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.inkBlack,
                      content: Text('Reservation #${widget.bookingId} CANCELLED. Equipment capacity released.'),
                    ),
                  );
                }
              } catch (e) {
                debugPrint('ERROR in cancelBooking: $e');
              }
            },
            child: const Text('Confirm Cancellation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double gearSubtotal = _effectiveItems.fold(
      0.0,
      (sum, item) => sum + ((item['qty'] as num) * (item['rate'] as num)),
    );
    final double logisticsAndCrew =
        (widget.grandTotal > gearSubtotal) ? (widget.grandTotal - gearSubtotal) : 0.0;

    final int totalFlightCases = _effectiveItems.length;
    final int loadedCount = _loadedSkus.length;
    final double packingRatio = totalFlightCases > 0 ? (loadedCount / totalFlightCases) : 0.0;
    final bool allLoaded = loadedCount == totalFlightCases;

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
              'RESERVATION #${widget.bookingId}',
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
            icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.burntCopper),
            onPressed: () => _openBarcodeScanner(context),
            tooltip: 'Scan Barcode',
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppColors.slate),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Generating Dispatch Manifest PDF for #${widget.bookingId}...')),
              );
            },
            tooltip: 'Print Manifest',
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
                            widget.category.toUpperCase(),
                            style: AppTextStyles.monoLabel.copyWith(
                              fontSize: 9,
                              color: AppColors.burntCopper,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          widget.bookingId,
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
                      widget.eventTitle,
                      style: AppTextStyles.screenTitle.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMetaRow(Icons.location_on_outlined, widget.venue),
                    _buildMetaRow(Icons.calendar_month_outlined, widget.dates),
                    _buildMetaRow(Icons.inventory_2_outlined, '${widget.totalItems} Total Units Reserved'),
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
                        widget.clientName.isNotEmpty ? widget.clientName.substring(0, 1) : 'C',
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
                            widget.clientName,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.clientPhone,
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
                          SnackBar(content: Text('Calling ${widget.clientPhone}...')),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_outlined, color: AppColors.burntCopper, size: 20),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening chat with ${widget.clientName}...')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Equipment Manifest Checklist & Packing Progress Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EQUIPMENT MANIFEST CHECKLIST',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 11,
                          color: AppColors.slate,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$loadedCount / $totalFlightCases FLIGHT CASES LOADED',
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 10,
                          color: allLoaded ? AppColors.success : AppColors.burntCopper,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _openBarcodeScanner(context),
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 14),
                    label: const Text('Scan Case'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.burntCopper,
                      side: const BorderSide(color: AppColors.burntCopper),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Interactive Packing Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: packingRatio,
                  minHeight: 6,
                  backgroundColor: AppColors.softStone,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    allLoaded ? AppColors.success : AppColors.burntCopper,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Manifest Items with Interactive Loading Checkboxes
              ..._effectiveItems.map((item) {
                final sku = item['sku'] as String;
                final isLoaded = _loadedSkus.contains(sku);
                return _buildManifestChecklistItem(item, isLoaded);
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
                      '₹${widget.grandTotal.toInt()}',
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
              if (allLoaded && (_currentStatus == 'PACKING' || _currentStatus == 'CONFIRMED'))
                RentFlowButton(
                  label: 'Confirm All Loaded & Mark Ready for Dispatch',
                  icon: Icons.local_shipping_outlined,
                  onPressed: () {
                    setState(() => _currentStatus = 'READY');
                    BookingRepository().updateBookingStatus(widget.bookingId, 'READY');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.inkBlack,
                        content: Text('Reservation #${widget.bookingId} marked as READY for Dispatch!'),
                      ),
                    );
                  },
                )
              else if (_currentStatus == 'READY')
                RentFlowButton(
                  label: 'Dispatch Vehicle (Departure)',
                  icon: Icons.send_rounded,
                  onPressed: () async {
                    try {
                      await BookingRepository().persistDispatchRecord(
                        bookingId: widget.bookingId,
                        recordedBy: AuthService().currentUser?.email ?? 'operations_lead',
                        items: _effectiveItems,
                      );
                      setState(() => _currentStatus = 'DISPATCHED');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.inkBlack,
                            content: Text('Reservation #${widget.bookingId} DISPATCHED to venue!'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.danger,
                            content: Text('Failed to dispatch vehicle: $e'),
                          ),
                        );
                      }
                    }
                  },
                )
              else if (_currentStatus == 'DISPATCHED' || _currentStatus == 'AWAITING RETURN')
                RentFlowButton(
                  label: 'Open Return Intake & Reconcile Stock',
                  icon: Icons.assignment_turned_in_outlined,
                  onPressed: () => _openReturnIntakeSheet(context),
                )
              else
                RentFlowButton(
                  label: 'Open Warehouse Dispatch Checklist',
                  icon: Icons.checklist_rounded,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Checklist Active: $loadedCount of $totalFlightCases flight cases loaded into vehicle.',
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 10),
              RentFlowSecondaryButton(
                label: 'Return Intake Sheet (Returns Flow)',
                leading: const Icon(Icons.assignment_return_outlined, size: 18),
                onPressed: () => _openReturnIntakeSheet(context),
              ),
              if (_currentStatus != 'CANCELLED' && _currentStatus != 'COMPLETED') ...[
                const SizedBox(height: 10),
                RentFlowSecondaryButton(
                  label: 'Cancel Reservation & Release Capacity',
                  leading: const Icon(Icons.cancel_outlined, size: 18, color: AppColors.danger),
                  onPressed: () => _confirmCancelBooking(context),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline() {
    if (_currentStatus.toUpperCase() == 'CANCELLED') {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.dangerSubtle,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.cancel_outlined, color: AppColors.danger, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RESERVATION CANCELLED',
                    style: AppTextStyles.monoLabel.copyWith(
                      fontSize: 10,
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All reserved equipment units have been released back to warehouse available pool.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11,
                      color: AppColors.inkBlack,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
                  _currentStatus,
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
              _buildTimelineStep('Dispatched', step >= 3, step == 3),
              _buildTimelineLine(step >= 4),
              _buildTimelineStep('Returned', step >= 4, step >= 4),
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

  Widget _buildManifestChecklistItem(Map<String, dynamic> item, bool isLoaded) {
    final name = item['name'] as String;
    final sku = item['sku'] as String;
    final qty = (item['qty'] as num).toInt();
    final flightCase = (item['flightCase'] as String?) ?? 'FC-GEN-01';
    final bay = (item['bay'] as String?) ?? 'BAY-01-A';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isLoaded ? AppColors.successSubtle.withValues(alpha: 0.3) : AppColors.paper,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isLoaded ? AppColors.success.withValues(alpha: 0.6) : AppColors.softStone,
          width: isLoaded ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // Interactive Checkbox for Warehouse Crew
          Checkbox(
            value: isLoaded,
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _loadedSkus.add(sku);
                  if (_loadedSkus.length == _effectiveItems.length) {
                    if (_currentStatus == 'PACKING' || _currentStatus == 'CONFIRMED') {
                      _currentStatus = 'READY';
                      BookingRepository().updateBookingStatus(widget.bookingId, 'READY');
                    }
                  } else if (_currentStatus == 'CONFIRMED') {
                    _currentStatus = 'PACKING';
                    BookingRepository().updateBookingStatus(widget.bookingId, 'PACKING');
                  }
                } else {
                  _loadedSkus.remove(sku);
                  if (_loadedSkus.isEmpty && _currentStatus == 'PACKING') {
                    _currentStatus = 'CONFIRMED';
                    BookingRepository().updateBookingStatus(widget.bookingId, 'CONFIRMED');
                  } else if (_loadedSkus.length < _effectiveItems.length && _currentStatus == 'READY') {
                    _currentStatus = 'PACKING';
                    BookingRepository().updateBookingStatus(widget.bookingId, 'PACKING');
                  }
                }
              });
              BookingRepository().updateBookingChecklist(widget.bookingId, _loadedSkus.toList());
            },
          ),
          const SizedBox(width: 4),

          // Quantity Badge
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
          const SizedBox(width: 10),

          // Item Name & Location / Flight Case Tag
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    decoration: isLoaded ? TextDecoration.lineThrough : null,
                    color: isLoaded ? AppColors.slate : AppColors.inkBlack,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.bone,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: AppColors.softStone),
                      ),
                      child: Text(
                        flightCase,
                        style: AppTextStyles.monoLabel.copyWith(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: AppColors.inkBlack,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$sku • $bay',
                      style: AppTextStyles.monoLabel.copyWith(
                        fontSize: 9.5,
                        color: AppColors.slate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Status Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isLoaded ? AppColors.successSubtle : AppColors.bone,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isLoaded ? AppColors.success : AppColors.softStone,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLoaded ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 12,
                  color: isLoaded ? AppColors.success : AppColors.slate,
                ),
                const SizedBox(width: 4),
                Text(
                  isLoaded ? 'LOADED' : 'STAGED',
                  style: AppTextStyles.monoLabel.copyWith(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: isLoaded ? AppColors.success : AppColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
