import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/constants/constants.dart';
import '../../core/utils/text_utils.dart' show truncateGraphemes;
import 'reader_layout.dart';
import 'reader_pane.dart';

part 'reader_tab.freezed.dart';
part 'reader_tab.g.dart';

/// Represents a single tab in the reader interface.
///
/// **A tab is a node, not a cursor into a file.** [nodeKey] is the whole of
/// what it reads; the content file, where the unit starts and where it ends
/// are all *derived* from it through `ReaderUnitResolver`. Nothing here may
/// reconstruct that locally.
///
/// **Persistence warning**: this entity is serialized to disk via
/// [toJson]/[fromJson] (see `TabsNotifier`). Adding a non-nullable field
/// without a `@Default(...)` will cause `_$ReaderTabFromJson` to throw on
/// every previously-saved tab, and `TabsNotifier._loadTabs` will silently
/// wipe the user's tab list as a result. Either give new fields a default,
/// or bump `StorageKeys.openTabs` to a new version so the old data is ignored
/// instead of misread.
@freezed
class ReaderTab with _$ReaderTab {
  const ReaderTab._();

  @Assert(
    'splitRatio >= 0.0 && splitRatio <= 1.0',
    'splitRatio must be between 0.0 and 1.0',
  )
  const factory ReaderTab({
    /// Short label for tab display (truncated if needed)
    required String label,

    /// Full name for tooltip or expanded view
    required String fullName,

    /// The node this tab reads. Its subtree is the unit. Null only for a tab
    /// with no content.
    String? nodeKey,

    /// The row scroll offset 0 sits on, as a document coordinate: what a
    /// search hit or a `?e=` link named, or where the reader re-anchored.
    /// Null is the unit's top. It never moves the unit, which is [nodeKey]'s.
    int? anchorPageIndex,
    int? anchorEntryIndex,

    /// Pali name of the node for reference
    String? paliName,

    /// Sinhala name of the node for reference
    String? sinhalaName,

    /// Universal text identifier (e.g., 'dn1', 'mn100', 'sn1-1')
    /// This is edition-agnostic and used for cross-edition alignment
    /// Nullable for backward compatibility - derived from contentFileId if needed
    String? textId,

    /// List of panes to display in this tab
    /// Each pane shows one TextLayer (edition + language + script combination)
    /// Empty list means using legacy dual-pane mode (Pali + Sinhala)
    /// Nullable for backward compatibility
    @Default([]) List<ReaderPane> panes,

    /// Reader layout mode for this tab (per-tab setting)
    /// Defaults to paliOnly for portrait mode, can be changed by user
    @Default(ReaderLayout.paliOnly) ReaderLayout layout,

    /// Split ratio for side-by-side layout (0.0 to 1.0)
    /// Represents the proportion of width for the left (Pali) pane
    @Default(0.5) double splitRatio,

    /// Last known scroll offset in pixels, measured from the anchor row
    /// (negative above it). Persisted so a reload resumes where reading stopped.
    @Default(0.0) double scrollOffset,
  }) = _ReaderTab;

  /// JSON deserialization for SharedPreferences-backed persistence.
  factory ReaderTab.fromJson(Map<String, dynamic> json) =>
      _$ReaderTabFromJson(json);

  /// Creates a tab reading [nodeKey]'s unit, anchored at
  /// [anchorPageIndex]/[anchorEntryIndex] when given.
  factory ReaderTab.fromNode({
    required String nodeKey,
    required String paliName,
    required String sinhalaName,
    int? anchorPageIndex,
    int? anchorEntryIndex,
    ReaderLayout layout = ReaderLayout.paliOnly,
  }) {
    return ReaderTab(
      label: truncateGraphemes(paliName, 20),
      fullName: '$paliName / $sinhalaName',
      nodeKey: nodeKey,
      anchorPageIndex: anchorPageIndex,
      anchorEntryIndex: anchorEntryIndex,
      paliName: paliName,
      sinhalaName: sinhalaName,
      layout: layout,
    );
  }

  /// The anchor row as `(page, entry)`, or null for the unit's top.
  (int, int)? get anchor => anchorPageIndex != null && anchorEntryIndex != null
      ? (anchorPageIndex!, anchorEntryIndex!)
      : null;

  /// Checks if this tab's node is a commentary (atthakatha)
  bool get isCommentary =>
      nodeKey != null && nodeKey!.startsWith(TipitakaNodeKeys.commentary);

  /// Checks if this tab's node is a treatise (e.g. Visuddhimagga)
  bool get isTreatise =>
      nodeKey != null && nodeKey!.startsWith(TipitakaNodeKeys.treatises);
}
