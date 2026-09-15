import 'package:flutter/material.dart';

class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatarColor = const Color(0xFF4F6EF7),
    this.memberSince,
    this.role = 'customer',
    this.isBlocked = false,
    this.ordersCount = 0,
  });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final Color avatarColor;
  final DateTime? memberSince;

  /// Admin-facing fields — not used by the customer-facing Profile
  /// screen, only by Admin Users.
  final String role;
  final bool isBlocked;
  final int ordersCount;

  /// Two-letter initials used as an avatar placeholder until real
  /// profile photos are wired up.
  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    bool? isBlocked,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarColor: avatarColor,
      memberSince: memberSince,
      role: role,
      isBlocked: isBlocked ?? this.isBlocked,
      ordersCount: ordersCount,
    );
  }
}
