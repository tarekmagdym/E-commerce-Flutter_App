import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../models/user_model.dart';
import '../../../services/admin_user_service.dart';

class AdminUserDetailsScreen extends StatefulWidget {
  const AdminUserDetailsScreen({super.key, required this.user});

  final UserModel user;

  @override
  State<AdminUserDetailsScreen> createState() => _AdminUserDetailsScreenState();
}

class _AdminUserDetailsScreenState extends State<AdminUserDetailsScreen> {
  final _service = AdminUserService();

  late bool _isBlocked;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _isBlocked = widget.user.isBlocked;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _handleToggleBlock() async {
    setState(() => _isUpdating = true);
    await _service.toggleBlock(widget.user.id);
    if (!mounted) return;
    setState(() {
      _isBlocked = !_isBlocked;
      _isUpdating = false;
    });
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(AppStrings.deleteUserTitle),
        content: Text('${AppStrings.deleteUserMessagePrefix} "${widget.user.fullName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.deleteLabel, style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deleteUser(widget.user.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: user.avatarColor,
                    child: Text(
                      user.initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(user.email, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  if (_isBlocked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        AppStrings.blockedLabel,
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.danger),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 28),
            _buildInfoCard(Icons.phone_outlined, user.phone.isEmpty ? '—' : user.phone),
            const SizedBox(height: 12),
            _buildInfoCard(
              Icons.calendar_today_outlined,
              user.memberSince != null
                  ? '${AppStrings.memberSincePrefix} ${_formatDate(user.memberSince!)}'
                  : AppStrings.memberSincePrefix,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(Icons.receipt_long_outlined, '${user.ordersCount} ${AppStrings.ordersLabel}'),
            const SizedBox(height: 28),
            CustomButton(
              label: _isBlocked ? AppStrings.unblockUser : AppStrings.blockUser,
              backgroundColor: _isBlocked ? AppColors.success : AppColors.danger,
              isLoading: _isUpdating,
              onPressed: _handleToggleBlock,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _handleDelete,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text(
                  AppStrings.deleteLabel,
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        ],
      ),
    );
  }
}