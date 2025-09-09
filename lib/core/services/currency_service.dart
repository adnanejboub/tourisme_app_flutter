import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppCurrency { mad, usd, eur }

class CurrencyService extends ChangeNotifier {
  static const String _prefsKey = 'preferred_currency';

  // Base currency is MAD. Rates are 1 MAD = x target currency units.
  // Example: 50 MAD -> $5.00 with usd rate = 0.10
  static const Map<AppCurrency, double> _rateFromMAD = {
    AppCurrency.mad: 1.0,
    AppCurrency.usd: 0.10,
    AppCurrency.eur: 0.095,
  };

  AppCurrency _current = AppCurrency.mad;
  AppCurrency get current => _current;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString(_prefsKey);
    if (saved != null) {
      _current = _parse(saved);
      notifyListeners();
    }
  }

  Future<void> setCurrency(AppCurrency currency) async {
    _current = currency;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, currency.name);
  }

  static AppCurrency _parse(String value) {
    switch (value.toLowerCase()) {
      case 'usd':
      case 'dollar':
        return AppCurrency.usd;
      case 'eur':
      case 'euro':
        return AppCurrency.eur;
      case 'mad':
      case 'dh':
      default:
        return AppCurrency.mad;
    }
  }

  // Prices from backend are assumed to be in MAD
  double convertFromMAD(double amountMAD, {AppCurrency? to}) {
    final AppCurrency target = to ?? _current;
    final double rate = _rateFromMAD[target] ?? 1.0;
    return amountMAD * rate;
  }

  // Generic converter (via MAD)
  double convert(double amount, AppCurrency from, AppCurrency to) {
    if (from == to) return amount;
    final double amountInMAD = from == AppCurrency.mad
        ? amount
        : amount / (_rateFromMAD[from] ?? 1.0);
    return convertFromMAD(amountInMAD, to: to);
  }

  String _trimTrailingZeros(String value) {
    if (!value.contains('.')) return value;
    value = value.replaceAll(RegExp(r'0+ '), '');
    while (value.endsWith('0')) {
      value = value.substring(0, value.length - 1);
    }
    if (value.endsWith('.')) {
      value = value.substring(0, value.length - 1);
    }
    return value;
  }

  // Format an amount provided in MAD using the selected currency.
  // Symbol appears after the number: e.g., 4.5 $, 4.75 € or 50 DH.
  String format(double amountMAD, {int? fractionDigits}) {
    final double converted = convertFromMAD(amountMAD);
    final int digits = fractionDigits ?? (_current == AppCurrency.mad ? 0 : 2);
    String number = converted.toStringAsFixed(digits);
    if (_current != AppCurrency.mad) {
      number = _trimTrailingZeros(number);
    }
    switch (_current) {
      case AppCurrency.mad:
        return '$number DH';
      case AppCurrency.usd:
        return '$number \$';
      case AppCurrency.eur:
        return '$number €';
    }
  }
}


