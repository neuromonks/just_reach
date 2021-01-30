class CurrencyApi {
  static const String CURRENCY_SIGN = "₹";
  static const String CURRENCY_CODE = "INR";

  // static const String CURRENCY_SIGN = "\₹";
  // static const String CURRENCY_CODE = "USD";

  static String getSign({bool afterSpace = false}) {
    return CURRENCY_SIGN + (afterSpace ? " " : "");
  }

  static String doubleToString(double value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }
}
