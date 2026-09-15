import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String fmtMoney(num value) {
  final hasDecimals = value % 1 != 0;
  return '\$${NumberFormat('#,##0${hasDecimals ? '.00' : ''}').format(value)}';
}

String fmtCompact(num value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return value.toStringAsFixed(0);
}

String fmtDate(DateTime d) => DateFormat('dd MMM yyyy, HH:mm').format(d);

String timeAgo(DateTime d) {
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return DateFormat('dd MMM').format(d);
}

const Map<String, Color> kStatusColors = {
  'processing': Color(0xFFF59E0B),
  'shipped': Color(0xFF3B82F6),
  'delivered': Color(0xFF22C55E),
  'cancelled': Color(0xFFEF4444),
};

Color statusColor(String status) =>
    kStatusColors[status] ?? const Color(0xFF6B7280);

Widget statusChip(String status) {
  final color = statusColor(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(status[0].toUpperCase() + status.substring(1),
        style: TextStyle(
            color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

void showMsg(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
    ));
}