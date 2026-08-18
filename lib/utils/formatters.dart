import 'package:intl/intl.dart';

final _pesoWhole = NumberFormat('#,###');
final _pesoDecimal = NumberFormat('#,##0.00');
final _longDate = DateFormat('MMMM d, yyyy');
final _shortDate = DateFormat('MMM d, yyyy');
final _isoDate = DateFormat('yyyy-MM-dd');

String formatPeso(num amount) {
  final value = amount.toDouble();
  if (value == value.roundToDouble()) {
    return '₱${_pesoWhole.format(value.round())}';
  }
  return '₱${_pesoDecimal.format(value)}';
}

String formatLongDate(DateTime date) => _longDate.format(date);

String formatShortDate(DateTime date) => _shortDate.format(date);

String toIsoDate(DateTime date) => _isoDate.format(date);

DateTime parseIsoDate(String value) {
  try {
    return DateTime.parse(value);
  } catch (_) {
    return DateTime.now();
  }
}

double parseAmount(String raw) {
  final cleaned = raw.replaceAll(',', '').trim();
  return double.tryParse(cleaned) ?? 0;
}

String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  if (parts.isEmpty) return '?';
  final list = parts.take(2).map((p) => p[0].toUpperCase());
  return list.join();
}
