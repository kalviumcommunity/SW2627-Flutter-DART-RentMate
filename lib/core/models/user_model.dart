import 'package:cloud_firestore/cloud_firestore.dart';

/// User operational roles defined in RentMate PRD/TRD.
enum UserRole {
  coordinator,
  warehouse,
  admin;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'warehouse':
        return UserRole.warehouse;
      case 'admin':
        return UserRole.admin;
      case 'coordinator':
      default:
        return UserRole.coordinator;
    }
  }

  String get value => name;
}

/// User profile domain model representing records in `users/{userId}`.
class UserModel {
  final String userId;
  final String name;
  final String email;
  final UserRole role;
  final bool active;
  final DateTime createdAt;

  const UserModel({
    required this.userId,
    required this.name,
    required this.email,
    this.role = UserRole.coordinator,
    this.active = true,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, {String? id}) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return UserModel(
      userId: id ?? map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: UserRole.fromString(map['role'] as String? ?? 'coordinator'),
      active: map['active'] as bool? ?? true,
      createdAt: parseDate(map['createdAt']),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel.fromMap(data, id: doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.value,
      'active': active,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    UserRole? role,
    bool? active,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
