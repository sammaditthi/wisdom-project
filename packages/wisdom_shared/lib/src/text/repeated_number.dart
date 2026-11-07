/// A sutta number such as `6. 1. 2.`: at least one digit, and nothing but
/// digits, dots, spaces, dashes and brackets — so no word, title or `------`.
final RegExp _numberOnly = RegExp(r'^(?=.*\d)[\d.\s()-]+$');

final RegExp _spaces = RegExp(r'\s');

/// Whether a row's two sides are the same sutta number, which a stacked
/// reading shows once. Spacing does not count, as the source sometimes slips
/// one (`4. 2 .6.`). Anything else repeated across the sides is left alone,
/// and so is a number the two sides disagree on.
bool isRepeatedNumber(String pali, String sinhala) =>
    _numberOnly.hasMatch(pali) &&
    pali.replaceAll(_spaces, '') == sinhala.replaceAll(_spaces, '');
