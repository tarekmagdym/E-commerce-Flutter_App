import '../models/user_model.dart';

/// Handles the current user's profile data.
///
/// Mocked with an in-memory user + delays, matching the rest of the
/// services in this project. Swap each method body for a real API
/// call once the backend is connected — callers already treat these
/// as async and never touch the shape of the data.
class UserService {
  static UserModel _currentUser = UserModel(
    id: 'u1',
    fullName: 'Ahmed Tarek',
    email: 'ahmed.tarek@example.com',
    phone: '+20 100 123 4567',
    memberSince: DateTime(2023, 4, 12),
  );

  Future<UserModel> getCurrentUser() async {
    // Real call will be: GET /users/me
    await Future.delayed(const Duration(milliseconds: 400));
    return _currentUser;
  }

  Future<UserModel> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    // Real call will be: PUT /users/me
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = _currentUser.copyWith(
      fullName: fullName,
      email: email,
      phone: phone,
    );
    return _currentUser;
  }

  Future<void> logout() async {
    // Real call will be: POST /auth/logout, then clear tokens via
    // LocalStorage.
    await Future.delayed(const Duration(milliseconds: 300));
  }
}
