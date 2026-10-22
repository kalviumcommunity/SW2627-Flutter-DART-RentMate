import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Central in-memory equipment inventory repository for RentFlow.
///
/// Manages live fleet metrics, deployment states, and returns reconciliation.
class InventoryRepository {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;

  InventoryRepository._internal() {
    itemsNotifier = ValueNotifier<List<Map<String, dynamic>>>(List.from(_initialItems));
  }

  static final List<Map<String, dynamic>> _initialItems = [
    {
      'sku': 'LT-PNT-700',
      'name': 'Robe Robin Pointe Moving Beam',
      'category': 'Lighting',
      'flightCase': 'FC-L-04',
      'rackBay': 'BAY-02-B',
      'total': 24,
      'available': 8,
      'deployed': 16,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '280W Lamp • 0°–20° Zoom • DMX 24ch',
      'progressRatio': 0.67,
    },
    {
      'sku': 'AU-K2-LARR',
      'name': 'L-Acoustics K2 Line Array Module',
      'category': 'Audio',
      'flightCase': 'FC-A-12',
      'rackBay': 'RIG-01-A',
      'total': 16,
      'available': 12,
      'deployed': 4,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': 'Dual 12" Neodymium • Panflex 70/110° • 147 dB',
      'progressRatio': 0.25,
    },
    {
      'sku': 'VD-PL25-LED',
      'name': 'Absen PL2.5 Pro Outdoor LED Panel',
      'category': 'Video & LED',
      'flightCase': 'FC-V-08',
      'rackBay': 'BAY-06-C',
      'total': 48,
      'available': 48,
      'deployed': 0,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': '2.5mm Pitch • 4500 nits • IP65 Weatherproof',
      'progressRatio': 0.0,
    },
    {
      'sku': 'CT-MQ500M',
      'name': 'Chamsys MagicQ MQ500M Stadium Console',
      'category': 'Power & Control',
      'flightCase': 'FC-C-01',
      'rackBay': 'CTRL-ROOM-1',
      'total': 2,
      'available': 0,
      'deployed': 2,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '256 Universes • 4 Motorized Fader Banks • Dual Touch',
      'progressRatio': 1.0,
    },
    {
      'sku': 'TR-H30V-3M',
      'name': 'Prolyte H30V Heavy Duty Truss 3M',
      'category': 'Rigging & Staging',
      'flightCase': 'TR-BDL-08',
      'rackBay': 'YARD-DOCK-2',
      'total': 32,
      'available': 18,
      'deployed': 14,
      'status': 'IN WAREHOUSE',
      'statusColor': AppColors.success,
      'statusBg': AppColors.successSubtle,
      'specs': '4-Point Box Truss • CCS6 Conical Coupler • 6082T6 Alloy',
      'progressRatio': 0.44,
    },
    {
      'sku': 'AU-PWR-X8',
      'name': 'Powersoft X8 Touring 8-Ch Amplifier',
      'category': 'Audio',
      'flightCase': 'AMP-RK-03',
      'rackBay': 'MAINT-BENCH-1',
      'total': 6,
      'available': 2,
      'deployed': 3,
      'status': 'MAINTENANCE',
      'statusColor': AppColors.warning,
      'statusBg': AppColors.warningSubtle,
      'specs': '8x 5200W @ 2Ω • Dante Networking • Advanced DSP',
      'progressRatio': 0.50,
    },
  ];

  late final ValueNotifier<List<Map<String, dynamic>>> itemsNotifier;

  List<Map<String, dynamic>> get items => itemsNotifier.value;

  int get totalAssetsCount =>
      items.fold(0, (sum, item) => sum + (item['total'] as int));

  int get onStageCount =>
      items.fold(0, (sum, item) => sum + (item['deployed'] as int));

  int get inWarehouseCount =>
      items.fold(0, (sum, item) => sum + (item['available'] as int));

  int get maintenanceCount => items.fold(0, (sum, item) {
        final total = item['total'] as int;
        final available = item['available'] as int;
        final deployed = item['deployed'] as int;
        final maint = total - (available + deployed);
        return sum + (maint > 0 ? maint : (item['status'] == 'MAINTENANCE' ? 1 : 0));
      });

  /// Reconciles returns by SKU, adjusting available stock, maintenance, and deployed counts.
  void reconcileReturn({
    required String sku,
    required int goodQty,
    required int damagedQty,
    required int missingQty,
  }) {
    final current = List<Map<String, dynamic>>.from(itemsNotifier.value);
    final index = current.indexWhere(
      (element) => element['sku'].toString().toUpperCase() == sku.toUpperCase(),
    );

    if (index != -1) {
      final item = Map<String, dynamic>.from(current[index]);
      final int total = item['total'] as int;
      final int prevAvailable = item['available'] as int;
      final int prevDeployed = item['deployed'] as int;

      final newAvailable = (prevAvailable + goodQty).clamp(0, total);
      final newDeployed = (prevDeployed - (goodQty + damagedQty + missingQty)).clamp(0, total);

      item['available'] = newAvailable;
      item['deployed'] = newDeployed;
      item['progressRatio'] = total > 0 ? (newDeployed / total).clamp(0.0, 1.0) : 0.0;

      if (damagedQty > 0) {
        item['status'] = 'MAINTENANCE';
        item['statusColor'] = AppColors.warning;
        item['statusBg'] = AppColors.warningSubtle;
      } else if (newDeployed > 0) {
        item['status'] = 'DEPLOYED';
        item['statusColor'] = AppColors.burntCopper;
        item['statusBg'] = AppColors.copperSubtle;
      } else {
        item['status'] = 'IN WAREHOUSE';
        item['statusColor'] = AppColors.success;
        item['statusBg'] = AppColors.successSubtle;
      }

      current[index] = item;
      itemsNotifier.value = current;
    }
  }

  /// Adds a new equipment item into the warehouse registry.
  void addEquipment(Map<String, dynamic> item) {
    itemsNotifier.value = [item, ...itemsNotifier.value];
  }

  /// Finds an equipment item by SKU or Barcode.
  Map<String, dynamic>? findBySku(String sku) {
    final clean = sku.trim().toUpperCase();
    try {
      return items.firstWhere(
        (i) => i['sku'].toString().toUpperCase() == clean ||
               i['flightCase'].toString().toUpperCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }
}
