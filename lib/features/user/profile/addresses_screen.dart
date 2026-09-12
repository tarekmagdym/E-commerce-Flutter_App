import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/address_model.dart';
import '../../../services/address_service.dart';

/// New screen (not part of the original scaffold), reached from
/// Profile > Addresses. When [selectMode] is true (e.g. from
/// Checkout's "Change" button), tapping an address pops it back to
/// the caller instead of just managing the list.
class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  final _service = AddressService();

  List<AddressModel> _addresses = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final addresses = await _service.getAddresses();
      if (!mounted) return;
      setState(() {
        _addresses = addresses;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _setDefault(String id) {
    _service.setDefault(id);
    setState(() {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: a.id == id)).toList();
    });
  }

  void _removeAddress(String id) {
    _service.removeAddress(id);
    setState(() => _addresses = _addresses.where((a) => a.id != id).toList());
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.addressesTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComingSoon(AppStrings.addAddress),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          AppStrings.addAddress,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadAddresses);
    if (_addresses.isEmpty) return _buildEmptyState();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 90),
      itemCount: _addresses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return _AddressTile(
          address: address,
          onSetDefault: () => _setDefault(address.id),
          onRemove: () => _removeAddress(address.id),
          onSelect: widget.selectMode ? () => Navigator.of(context).pop(address) : null,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.location_off_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.noAddressesTitle,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.noAddressesSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.address,
    required this.onSetDefault,
    required this.onRemove,
    this.onSelect,
  });

  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onRemove;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: address.isDefault ? AppColors.primary : AppColors.border,
          width: address.isDefault ? 1.4 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      address.fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          AppStrings.defaultLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${address.addressLine}, ${address.shortLocation}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          if (onSelect == null)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
              onSelected: (value) {
                if (value == 'default') onSetDefault();
                if (value == 'remove') onRemove();
              },
              itemBuilder: (context) => [
                if (!address.isDefault)
                  const PopupMenuItem(value: 'default', child: Text(AppStrings.setAsDefault)),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text(AppStrings.removeAddress, style: TextStyle(color: AppColors.danger)),
                ),
              ],
            )
          else
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );

    return onSelect != null
        ? InkWell(borderRadius: BorderRadius.circular(16), onTap: onSelect, child: content)
        : content;
  }
}