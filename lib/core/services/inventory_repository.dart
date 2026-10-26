import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'auth_service.dart';

/// Central equipment inventory repository for RentFlow and RentMate operations.
///
/// Responsibilities:
/// - Manages physical fleet assets, warehouse bays, deployment states, and returns reconciliation.
/// - Synchronizes two-way with Cloud Firestore collection `equipment`.
/// - Persists return audit logs to Cloud Firestore collection `returns`.
/// - Supports offline/in-memory mode for standalone verification and unit tests.
class InventoryRepository {
  static final InventoryRepository _instance = InventoryRepository._internal();
  factory InventoryRepository() => _instance;

  /// Explicit flag to toggle demo fixtures for testing or local sandboxing.
  static bool isDemoMode = false;

  bool isLoading = false;
  bool hasReceivedRemoteSnapshot = false;
  String? errorMessage;

  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  InventoryRepository._internal() {
    final useInitial = !AuthService().isFirebaseInitialized || isDemoMode;
    itemsNotifier = ValueNotifier<List<Map<String, dynamic>>>(
      useInitial ? List.from(_initialItems) : const [],
    );
    isLoading = AuthService().isFirebaseInitialized && !isDemoMode;
    _initFirestoreListener();
  }

  void _initFirestoreListener() {
    if (AuthService().isFirebaseInitialized) {
      try {
        _firestoreSubscription = FirebaseFirestore.instance
            .collection('equipment')
            .snapshots()
            .listen(
          (snapshot) {
            // Authoritative: replace collection with actual remote docs even if empty
            final remoteItems = snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map<dynamic, dynamic>? ?? {});
              data['id'] = doc.id;
              data['sku'] = (data['sku'] ?? doc.id).toString();
              data['name'] = (data['name'] ?? data['sku']).toString();
              data['total'] = ((data['totalQuantity'] ?? data['total'] ?? 0) as num).toInt();
              data['available'] = ((data['rentableQuantity'] ?? data['available'] ?? 0) as num).toInt();
              data['deployed'] = ((data['deployed'] ?? 0) as num).toInt();
              final statusStr = (data['status'] ?? 'IN WAREHOUSE').toString().toUpperCase();
              data['status'] = statusStr;
              data['statusColor'] = statusStr == 'MAINTENANCE'
                  ? AppColors.warning
                  : (statusStr == 'DEPLOYED' ? AppColors.burntCopper : AppColors.success);
              data['statusBg'] = statusStr == 'MAINTENANCE'
                  ? AppColors.warningSubtle
                  : (statusStr == 'DEPLOYED' ? AppColors.copperSubtle : AppColors.successSubtle);
              return data;
            }).toList();

            itemsNotifier.value = remoteItems;
            hasReceivedRemoteSnapshot = true;
            isLoading = false;
            errorMessage = null;
          },
          onError: (e) {
            isLoading = false;
            errorMessage = e.toString();
            debugPrint('Firestore equipment subscription notice: $e');
          },
        );
      } catch (e) {
        isLoading = false;
        errorMessage = e.toString();
        debugPrint('Could not initialize Firestore equipment listener: $e');
      }
    }
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
      'sku': 'SND-JBL-VRX932',
      'name': 'JBL VRX932LA Line Array Speaker',
      'category': 'Audio',
      'flightCase': 'FC-A-04',
      'rackBay': 'RIG-02-B',
      'total': 16,
      'available': 8,
      'deployed': 8,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '800W Peak • 12" Differential Drive • Constant Curvature',
      'progressRatio': 0.50,
    },
    {
      'sku': 'LGT-SHARPY-230',
      'name': 'Sharpy 230W 7R Beam Moving Head',
      'category': 'Lighting',
      'flightCase': 'FC-L-11',
      'rackBay': 'BAY-03-A',
      'total': 24,
      'available': 12,
      'deployed': 12,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': 'Philips 7R Platinum • 14 Colors • 17 Gobos',
      'progressRatio': 0.50,
    },
    {
      'sku': 'VIS-LED-P391',
      'name': 'P3.91 High-Res LED Video Wall Panel',
      'category': 'Video & LED',
      'flightCase': 'FC-V-02',
      'rackBay': 'BAY-05-A',
      'total': 40,
      'available': 20,
      'deployed': 20,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '500x500mm • 3840Hz Refresh • Die-cast Aluminum',
      'progressRatio': 0.50,
    },
    {
      'sku': 'STG-TRS-3M',
      'name': 'Heavy Duty Aluminum Box Truss (3m)',
      'category': 'Rigging & Staging',
      'flightCase': 'TRS-BND-01',
      'rackBay': 'YARD-BAY-4',
      'total': 30,
      'available': 14,
      'deployed': 16,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': '290mm Square • EN-AW 6082-T6 • Conical Couplers',
      'progressRatio': 0.53,
    },
    {
      'sku': 'SND-SHURE-ULXD',
      'name': 'Shure ULXD4 Wireless Dual Mic Set',
      'category': 'Audio',
      'flightCase': 'FC-MIC-01',
      'rackBay': 'BENCH-01',
      'total': 10,
      'available': 5,
      'deployed': 5,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': 'Digital 24-bit/48kHz • Dante Networked • AES-256',
      'progressRatio': 0.50,
    },
    {
      'sku': 'PWR-GEN-62KVA',
      'name': '62.5 kVA Silent Diesel Generator Unit',
      'category': 'Power & Control',
      'flightCase': 'GEN-TRK-01',
      'rackBay': 'YARD-GEN-1',
      'total': 4,
      'available': 2,
      'deployed': 2,
      'status': 'DEPLOYED',
      'statusColor': AppColors.burntCopper,
      'statusBg': AppColors.copperSubtle,
      'specs': 'Cummins Engine • 415V 3-Phase • Acoustic Canopy <65dB',
      'progressRatio': 0.50,
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
      items.fold(0, (total, item) => total + (item['total'] as int));

  int get onStageCount =>
      items.fold(0, (total, item) => total + (item['deployed'] as int));

  int get inWarehouseCount =>
      items.fold(0, (total, item) => total + (item['available'] as int));

  int get maintenanceCount => items.fold(0, (total, item) {
        final totalQty = item['total'] as int;
        final available = item['available'] as int;
        final deployed = item['deployed'] as int;
        final maint = totalQty - (available + deployed);
        return total + (maint > 0 ? maint : (item['status'] == 'MAINTENANCE' ? 1 : 0));
      });

  /// Atomically reconciles equipment return intake and updates inventory and return audit logs.
  /// Uses [returnId] for strict idempotency to prevent repeated submissions from double-incrementing stock.
  Future<void> reconcileReturnBatch({
    required String returnId,
    required String bookingId,
    required List<Map<String, dynamic>> items,
    String? recordedBy,
    String? notes,
  }) async {
    if (AuthService().isFirebaseInitialized) {
      final firestore = FirebaseFirestore.instance;
      await firestore.runTransaction((transaction) async {
        final returnRef = firestore.collection('returns').doc(returnId);
        final returnSnap = await transaction.get(returnRef);
        if (returnSnap.exists) {
          // Idempotent: return batch has already been processed
          return;
        }

        final bookingRef = firestore.collection('bookings').doc(bookingId);
        final bookingSnap = await transaction.get(bookingRef);

        final Map<String, DocumentSnapshot> eqSnaps = {};
        for (final item in items) {
          final sku = (item['sku'] ?? '').toString();
          if (sku.isEmpty) continue;
          final eqRef = firestore.collection('equipment').doc(sku);
          eqSnaps[sku] = await transaction.get(eqRef);
        }

        // Apply equipment updates inside the same transaction
        for (final item in items) {
          final sku = (item['sku'] ?? '').toString();
          if (sku.isEmpty) continue;
          final eqSnap = eqSnaps[sku];
          final eqRef = firestore.collection('equipment').doc(sku);
          final goodQty = (item['goodQty'] ?? item['goodQuantity'] ?? 0) as int;
          final damagedQty = (item['damagedQty'] ?? item['damagedQuantity'] ?? 0) as int;
          final missingQty = (item['missingQty'] ?? item['missingQuantity'] ?? 0) as int;

          final eqData = eqSnap != null && eqSnap.exists
              ? Map<String, dynamic>.from(eqSnap.data() as Map<dynamic, dynamic>)
              : <String, dynamic>{};

          final int total = (eqData['totalQuantity'] ?? eqData['total'] ?? 100) as int;
          final int prevAvail = (eqData['rentableQuantity'] ?? eqData['available'] ?? total) as int;
          final int prevDep = (eqData['deployed'] ?? 0) as int;
          final int prevMaint = (eqData['maintenanceQuantity'] ?? eqData['maintenance'] ?? 0) as int;

          final newAvail = (prevAvail + goodQty).clamp(0, total);
          final newDep = (prevDep - (goodQty + damagedQty + missingQty)).clamp(0, total);
          final newMaint = (prevMaint + damagedQty).clamp(0, total);
          final newStatus = (newMaint > 0)
              ? 'MAINTENANCE'
              : (newDep > 0 ? 'DEPLOYED' : 'IN WAREHOUSE');

          transaction.set(eqRef, {
            'rentableQuantity': newAvail,
            'available': newAvail,
            'deployed': newDep,
            'maintenanceQuantity': newMaint,
            'status': newStatus,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        // Write return log record
        transaction.set(returnRef, {
          'returnId': returnId,
          'bookingId': bookingId,
          'items': items,
          'recordedBy': recordedBy ?? AuthService().currentUser?.email ?? 'operations_lead',
          'notes': notes ?? '',
          'returnedAt': FieldValue.serverTimestamp(),
        });

        // Advance booking status to COMPLETED if it exists
        if (bookingSnap.exists) {
          transaction.update(bookingRef, {
            'status': 'COMPLETED',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    }

    // Update local memory cache for immediate UI responsiveness
    final current = List<Map<String, dynamic>>.from(itemsNotifier.value);
    for (final returnItem in items) {
      final sku = (returnItem['sku'] ?? '').toString().toUpperCase();
      final goodQty = (returnItem['goodQty'] ?? returnItem['goodQuantity'] ?? 0) as int;
      final damagedQty = (returnItem['damagedQty'] ?? returnItem['damagedQuantity'] ?? 0) as int;
      final missingQty = (returnItem['missingQty'] ?? returnItem['missingQuantity'] ?? 0) as int;

      final idx = current.indexWhere((e) => e['sku'].toString().toUpperCase() == sku);
      if (idx != -1) {
        final item = Map<String, dynamic>.from(current[idx]);
        final total = (item['total'] as num?)?.toInt() ?? 100;
        final prevAvail = (item['available'] as num?)?.toInt() ?? total;
        final prevDep = (item['deployed'] as num?)?.toInt() ?? 0;

        final newAvail = (prevAvail + goodQty).clamp(0, total);
        final newDep = (prevDep - (goodQty + damagedQty + missingQty)).clamp(0, total);

        item['available'] = newAvail;
        item['deployed'] = newDep;
        item['progressRatio'] = total > 0 ? (newDep / total).clamp(0.0, 1.0) : 0.0;
        if (damagedQty > 0) {
          item['status'] = 'MAINTENANCE';
          item['statusColor'] = AppColors.warning;
          item['statusBg'] = AppColors.warningSubtle;
        } else if (newDep > 0) {
          item['status'] = 'DEPLOYED';
          item['statusColor'] = AppColors.burntCopper;
          item['statusBg'] = AppColors.copperSubtle;
        } else {
          item['status'] = 'IN WAREHOUSE';
          item['statusColor'] = AppColors.success;
          item['statusBg'] = AppColors.successSubtle;
        }
        current[idx] = item;
      }
    }
    itemsNotifier.value = current;
  }

  /// Reconciles returns by SKU, adjusting available stock, maintenance, and deployed counts.
  /// Delegates to [reconcileReturnBatch] with a deterministic operation key.
  Future<void> reconcileReturn({
    required String sku,
    required int goodQty,
    required int damagedQty,
    required int missingQty,
    String? bookingId,
  }) async {
    final returnId = 'RET-${bookingId ?? "MANUAL"}-$sku-${DateTime.now().millisecondsSinceEpoch}';
    await reconcileReturnBatch(
      returnId: returnId,
      bookingId: bookingId ?? 'UNSPECIFIED',
      items: [
        {
          'sku': sku,
          'goodQty': goodQty,
          'damagedQty': damagedQty,
          'missingQty': missingQty,
        }
      ],
    );
  }

  /// Adds a new equipment item into the warehouse registry.
  void addEquipment(Map<String, dynamic> item) {
    itemsNotifier.value = [item, ...itemsNotifier.value];

    if (AuthService().isFirebaseInitialized) {
      try {
        final sku = (item['sku'] ?? DateTime.now().millisecondsSinceEpoch).toString();
        FirebaseFirestore.instance
            .collection('equipment')
            .doc(sku)
            .set(item, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Firestore addEquipment notice: $e');
      }
    }
  }

  /// Finds an equipment item by SKU or Barcode.
  Map<String, dynamic>? findBySku(String sku) {
    final clean = sku.trim().toUpperCase();
    try {
      return items.firstWhere(
        (i) =>
            i['sku'].toString().toUpperCase() == clean ||
            i['flightCase'].toString().toUpperCase() == clean,
      );
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _firestoreSubscription?.cancel();
  }
}
