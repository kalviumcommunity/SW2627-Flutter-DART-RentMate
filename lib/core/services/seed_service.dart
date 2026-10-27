import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';
import 'booking_repository.dart';
import 'inventory_repository.dart';
import 'availability_service.dart';

/// Authoritative Data Seeder for RentFlow / RentMate operations.
///
/// Seeds both local memory stores (for offline/demo and widget tests) and
/// Cloud Firestore collections (`equipment`, `bookings`, `allocations`, `users`)
/// for end-to-end multi-device testing.
class SeedService {
  static final SeedService _instance = SeedService._internal();
  factory SeedService() => _instance;
  SeedService._internal();

  /// Default equipment dataset with comprehensive staging, audio, lighting, and power fleet assets.
  static final List<Map<String, dynamic>> initialEquipment = [
    {
      'sku': 'LT-PNT-700',
      'name': 'Robe Robin Pointe Moving Beam',
      'category': 'Lighting',
      'flightCase': 'FC-L-04',
      'rackBay': 'BAY-02-B',
      'totalQuantity': 24,
      'total': 24,
      'rentableQuantity': 8,
      'available': 8,
      'deployed': 16,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 1800.0,
      'status': 'DEPLOYED',
      'specs': '280W Lamp • 0°–20° Zoom • DMX 24ch',
    },
    {
      'sku': 'AU-K2-LARR',
      'name': 'L-Acoustics K2 Line Array Module',
      'category': 'Audio',
      'flightCase': 'FC-A-12',
      'rackBay': 'RIG-01-A',
      'totalQuantity': 16,
      'total': 16,
      'rentableQuantity': 12,
      'available': 12,
      'deployed': 4,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 3000.0,
      'status': 'IN WAREHOUSE',
      'specs': 'Dual 12" Neodymium • Panflex 70/110° • 147 dB',
    },
    {
      'sku': 'VD-PL25-LED',
      'name': 'Absen PL2.5 Pro Outdoor LED Panel',
      'category': 'Video & LED',
      'flightCase': 'FC-V-08',
      'rackBay': 'BAY-06-C',
      'totalQuantity': 48,
      'total': 48,
      'rentableQuantity': 48,
      'available': 48,
      'deployed': 0,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 1400.0,
      'status': 'IN WAREHOUSE',
      'specs': '2.5mm Pitch • 4500 nits • IP65 Weatherproof',
    },
    {
      'sku': 'SND-JBL-VRX932',
      'name': 'JBL VRX932LA Line Array Speaker',
      'category': 'Audio',
      'flightCase': 'FC-A-04',
      'rackBay': 'RIG-02-B',
      'totalQuantity': 16,
      'total': 16,
      'rentableQuantity': 8,
      'available': 8,
      'deployed': 8,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 1500.0,
      'status': 'DEPLOYED',
      'specs': '800W Peak • 12" Differential Drive • Constant Curvature',
    },
    {
      'sku': 'LGT-SHARPY-230',
      'name': 'Sharpy 230W 7R Beam Moving Head',
      'category': 'Lighting',
      'flightCase': 'FC-L-11',
      'rackBay': 'BAY-03-A',
      'totalQuantity': 24,
      'total': 24,
      'rentableQuantity': 12,
      'available': 12,
      'deployed': 12,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 850.0,
      'status': 'DEPLOYED',
      'specs': 'Philips 7R Platinum • 14 Colors • 17 Gobos',
    },
    {
      'sku': 'VIS-LED-P391',
      'name': 'P3.91 High-Res LED Video Wall Panel',
      'category': 'Video & LED',
      'flightCase': 'FC-V-02',
      'rackBay': 'BAY-05-A',
      'totalQuantity': 40,
      'total': 40,
      'rentableQuantity': 20,
      'available': 20,
      'deployed': 20,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 1200.0,
      'status': 'DEPLOYED',
      'specs': '500x500mm • 3840Hz Refresh • Die-cast Aluminum',
    },
    {
      'sku': 'STG-TRS-3M',
      'name': 'Heavy Duty Aluminum Box Truss (3m)',
      'category': 'Rigging & Staging',
      'flightCase': 'TRS-BND-01',
      'rackBay': 'YARD-BAY-4',
      'totalQuantity': 30,
      'total': 30,
      'rentableQuantity': 14,
      'available': 14,
      'deployed': 16,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 600.0,
      'status': 'DEPLOYED',
      'specs': '290mm Square • EN-AW 6082-T6 • Conical Couplers',
    },
    {
      'sku': 'SND-SHURE-ULXD',
      'name': 'Shure ULXD4 Wireless Dual Mic Set',
      'category': 'Audio',
      'flightCase': 'FC-MIC-01',
      'rackBay': 'BENCH-01',
      'totalQuantity': 10,
      'total': 10,
      'rentableQuantity': 5,
      'available': 5,
      'deployed': 5,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 950.0,
      'status': 'DEPLOYED',
      'specs': 'Digital 24-bit/48kHz • Dante Networked • AES-256',
    },
    {
      'sku': 'PWR-GEN-62KVA',
      'name': '62.5 kVA Silent Diesel Generator Unit',
      'category': 'Power & Control',
      'flightCase': 'GEN-TRK-01',
      'rackBay': 'YARD-GEN-1',
      'totalQuantity': 4,
      'total': 4,
      'rentableQuantity': 2,
      'available': 2,
      'deployed': 2,
      'maintenanceQuantity': 0,
      'maintenance': 0,
      'dailyRate': 4500.0,
      'status': 'DEPLOYED',
      'specs': 'Cummins Engine • 415V 3-Phase • Acoustic Canopy <65dB',
    },
    {
      'sku': 'AU-PWR-X8',
      'name': 'Powersoft X8 Touring 8-Ch Amplifier',
      'category': 'Audio',
      'flightCase': 'AMP-RK-03',
      'rackBay': 'MAINT-BENCH-1',
      'totalQuantity': 6,
      'total': 6,
      'rentableQuantity': 2,
      'available': 2,
      'deployed': 3,
      'maintenanceQuantity': 1,
      'maintenance': 1,
      'dailyRate': 2500.0,
      'status': 'MAINTENANCE',
      'specs': '8x 5200W @ 2Ω • Dante Networking • Advanced DSP',
    },
  ];

  /// Populates both local in-memory repositories and Cloud Firestore.
  ///
  /// Returns a summary report of seeded records.
  Future<SeedResult> seedDatabase({bool force = false}) async {
    final result = SeedResult();

    // 1. Always seed local repositories for instant zero-latency UI reactivity
    InventoryRepository().resetToInitial();
    BookingRepository().resetToInitial();
    AvailabilityService().resetAndSeedAllocations();
    result.localSeeded = true;
    result.equipmentCount = initialEquipment.length;
    result.bookingsCount = BookingRepository().bookings.length;

    // 2. If Firebase is initialized, persist to Cloud Firestore collections
    if (AuthService().isFirebaseInitialized) {
      try {
        final firestore = FirebaseFirestore.instance;

        // Check if equipment collection already has data (unless force is requested)
        if (!force) {
          final existingEq = await firestore.collection('equipment').limit(1).get();
          if (existingEq.docs.isNotEmpty) {
            result.firestoreSeeded = false;
            result.message = 'Firestore already contains records. Local state refreshed.';
            return result;
          }
        }

        final batch = firestore.batch();

        // Seed Equipment collection (Key = SKU)
        for (final item in initialEquipment) {
          final sku = item['sku'] as String;
          final docRef = firestore.collection('equipment').doc(sku);
          batch.set(docRef, {
            'sku': sku,
            'name': item['name'],
            'category': item['category'],
            'flightCase': item['flightCase'],
            'rackBay': item['rackBay'],
            'totalQuantity': item['totalQuantity'],
            'total': item['total'],
            'rentableQuantity': item['rentableQuantity'],
            'available': item['available'],
            'deployed': item['deployed'],
            'maintenanceQuantity': item['maintenanceQuantity'],
            'maintenance': item['maintenance'],
            'dailyRate': item['dailyRate'],
            'status': item['status'],
            'specs': item['specs'],
            'active': true,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        // Seed Bookings collection
        for (final booking in BookingRepository().bookings) {
          final bRef = firestore.collection('bookings').doc(booking.id);
          final map = booking.toMap();
          map['createdAt'] = FieldValue.serverTimestamp();
          map['updatedAt'] = FieldValue.serverTimestamp();
          batch.set(bRef, map, SetOptions(merge: true));
        }

        // Seed default coordinator profile if signed in
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userRef = firestore.collection('users').doc(currentUser.uid);
          batch.set(userRef, {
            'uid': currentUser.uid,
            'email': currentUser.email ?? 'coordinator@rentflow.ops',
            'displayName': currentUser.displayName ?? 'Operations Coordinator',
            'role': 'coordinator',
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        await batch.commit();

        // Reconcile daily allocations across all bookings
        await AvailabilityService().ensureAllocationsReconciled();

        result.firestoreSeeded = true;
        result.message = 'Successfully seeded Cloud Firestore and local fleet with ${initialEquipment.length} equipment assets & ${BookingRepository().bookings.length} bookings.';
      } catch (e) {
        result.firestoreSeeded = false;
        result.firestoreError = e.toString();
        result.message = 'Local memory seeded successfully. Firestore sync notice: $e';
        debugPrint('SeedService Firestore Notice: $e');
      }
    } else {
      result.message = 'Local in-memory operational fleet successfully seeded (${initialEquipment.length} items, ${BookingRepository().bookings.length} bookings).';
    }

    return result;
  }
}

class SeedResult {
  bool localSeeded = false;
  bool firestoreSeeded = false;
  int equipmentCount = 0;
  int bookingsCount = 0;
  String? firestoreError;
  String message = '';
}
