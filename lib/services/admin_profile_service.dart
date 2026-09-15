import '../models/user_model.dart';

/// Mock admin identity — there's no Admin Login/session yet, so this
/// is a fixed mock account. Once Admin Login exists, swap this for
/// the actual authenticated admin's data.
class AdminProfileService {
  static const UserModel _currentAdmin = UserModel(
    id: 'admin1',
    fullName: 'Sara Ibrahim',
    email: 'sara.ibrahim@shopeasy.com',
    phone: '+20 100 555 7890',
    role: 'admin',
  );

  Future<UserModel> getCurrentAdmin() async {
    // Real call will be: GET /admin/me
    await Future.delayed(const Duration(milliseconds: 400));
    return _currentAdmin;
  }

  Future<void> logout() async {
    // Real call will be: POST /auth/logout, then clear admin tokens.
    await Future.delayed(const Duration(milliseconds: 300));
  }
}