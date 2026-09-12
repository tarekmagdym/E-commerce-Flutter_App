import 'package:flutter/material.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String avatarColorHex;
  final String role;
  final bool isBlocked;
  final String provider;
  final DateTime? memberSince;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.avatarColorHex = '#4F6EF7',
    this.role = 'user',
    this.isBlocked = false,
    this.provider = 'local',
    this.memberSince,
  });

  bool get isAdmin => role == 'admin';

  /// Parsed Flutter [Color] for avatar backgrounds, circles, etc.
  Color get avatarColor {
    final hex = avatarColorHex.replaceAll('#', '');
    final normalized = hex.length == 6 ? 'FF$hex' : hex;
    final value = int.tryParse(normalized, radix: 16);
    return value != null ? Color(value) : const Color(0xFF4F6EF7);
  }

  /// Up to 2 uppercase initials from the full name, e.g.
  /// "Ahmed Tarek" -> "AT", "Cher" -> "C".
  String get initials {
    final parts =
        fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      avatarColorHex: json['avatarColor'] ?? '#4F6EF7',
      role: json['role'] ?? 'user',
      isBlocked: json['isBlocked'] ?? false,
      provider: json['provider'] ?? 'local',
      memberSince: json['memberSince'] != null
          ? DateTime.tryParse(json['memberSince'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatarColor': avatarColorHex,
      'role': role,
      'isBlocked': isBlocked,
      'provider': provider,
      'memberSince': memberSince?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? fullName,
    String? email,
    String? phone,
    String? avatarColorHex,
  }) {
    return UserModel(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarColorHex: avatarColorHex ?? this.avatarColorHex,
      role: role,
      isBlocked: isBlocked,
      provider: provider,
      memberSince: memberSince,
    );
  }
}
