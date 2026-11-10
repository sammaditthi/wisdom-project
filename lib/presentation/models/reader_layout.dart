import '../../core/localization/l10n/app_localizations.dart';

/// Represents the layout mode for the bilingual reader
///
/// The user's last-selected layout is persisted per-device via
/// `LastReaderLayoutNotifier` and seeds the layout of newly opened tabs.
enum ReaderLayout {
  /// Display only Pali content in a single column
  paliOnly,

  /// Display only Sinhala content in a single column
  sinhalaOnly,

  /// Display both Pali and Sinhala content side by side (horizontal)
  sideBySide,

  /// Display Pali and Sinhala content stacked vertically
  /// (Pali paragraph followed by its Sinhala translation, repeating)
  stacked;

  /// Short label for compact UI controls (the reader toolbar's Layout button).
  /// Displayed as text for [paliOnly] and [sinhalaOnly]; [sideBySide] and
  /// [stacked] use icons instead but labels are kept for completeness.
  String get shortLabel => switch (this) {
        ReaderLayout.paliOnly => 'P',
        ReaderLayout.sideBySide => 'P|S',
        ReaderLayout.stacked => 'P/S',
        ReaderLayout.sinhalaOnly => 'S',
      };

  /// The layout's localized name, as the toolbar's Layout menu shows it.
  String label(AppLocalizations l10n) => switch (this) {
        ReaderLayout.paliOnly => l10n.layoutPaliOnly,
        ReaderLayout.sideBySide => l10n.layoutSideBySide,
        ReaderLayout.stacked => l10n.layoutStacked,
        ReaderLayout.sinhalaOnly => l10n.layoutSinhalaOnly,
      };
}
