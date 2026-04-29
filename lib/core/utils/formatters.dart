import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final _formatter = NumberFormat.currency(
    symbol: '₹',
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static final _compact = NumberFormat.compactCurrency(
    symbol: '₹',
    locale: 'en_IN',
  );

  static String format(double amount) => _formatter.format(amount);
  static String compact(double amount) => _compact.format(amount);
  static String formatAbs(double amount) => _formatter.format(amount.abs());
}

class DateFormatter {
  DateFormatter._();

  static String dayMonth(DateTime date) => DateFormat('d MMM').format(date);
  static String full(DateTime date) => DateFormat('d MMM yyyy').format(date);
  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
  static String time(DateTime date) => DateFormat('hh:mm a').format(date);
  static String relative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return full(date);
  }
}
