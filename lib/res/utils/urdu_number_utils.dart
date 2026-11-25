/// Utility for converting Western digits (0-9) into Urdu/Eastern Arabic digits (۰-۹).
class UrduNumberUtils {
  UrduNumberUtils._();

  static const List<String> _urduDigits = <String>[
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹',
  ];

  /// Converts digits in [input] to Urdu numerals when [useUrduNumerals] is true.
  static String format(Object input, {bool useUrduNumerals = true}) {
    final String text = input.toString();
    if (!useUrduNumerals) return text;

    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      final int codeUnit = text.codeUnitAt(i);
      if (codeUnit >= 48 && codeUnit <= 57) {
        buffer.write(_urduDigits[codeUnit - 48]);
      } else {
        buffer.writeCharCode(codeUnit);
      }
    }
    return buffer.toString();
  }
}