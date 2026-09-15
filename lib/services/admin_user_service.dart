import 'package:flutter/material.dart';
import '../models/user_model.dart';

/// New service (not part of the original scaffold), listing all
/// customers for Admin Users. Separate from UserService, which only
/// manages the single logged-in customer's own profile.
class AdminUserService {
  static final List<UserModel> _users = [
    UserModel(
      id: 'u1',
      fullName: 'Ahmed Tarek',
      email: 'ahmed.tarek@example.com',
      phone: '+20 100 123 4567',
      memberSince: DateTime(2023, 4, 12),
      ordersCount: 4,
    ),
    UserModel(
      id: 'u2',
      fullName: 'Mona Hassan',
      email: 'mona.hassan@example.com',
      phone: '+20 101 555 2211',
      avatarColor: const Color(0xFF22C55E),
      memberSince: DateTime(2023, 8, 2),
      ordersCount: 7,
    ),
    UserModel(
      id: 'u3',
      fullName: 'Youssef Adel',
      email: 'youssef.adel@example.com',
      phone: '+20 111 222 3344',
      avatarColor: const Color(0xFFF59E0B),
      memberSince: DateTime(2024, 1, 20),
      ordersCount: 2,
    ),
    UserModel(
      id: 'u4',
      fullName: 'Salma Fathy',
      email: 'salma.fathy@example.com',
      phone: '+20 122 987 6543',
      avatarColor: const Color(0xFFEF4444),
      memberSince: DateTime(2024, 5, 9),
      ordersCount: 0,
      isBlocked: true,
    ),
    UserModel(
      id: 'u5',
      fullName: 'Karim Nabil',
      email: 'karim.nabil@example.com',
      phone: '+20 155 333 8899',
      avatarColor: const Color(0xFF3B82F6),
      memberSince: DateTime(2024, 11, 3),
      ordersCount: 1,
    ),
  ];

  Future<List<UserModel>> getUsers() async {
    // Real call will be: GET /admin/users
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_users);
  }

  /// Real call will be: PATCH /admin/users/:id { isBlocked }
  Future<void> toggleBlock(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _users.indexWhere((u) => u.id == id);
    if (index == -1) return;
    _users[index] = _users[index].copyWith(isBlocked: !_users[index].isBlocked);
  }

  /// Real call will be: DELETE /admin/users/:id
  Future<void> deleteUser(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _users.removeWhere((u) => u.id == id);
  }
}