/// The site's icons, each drawn once. A page carries an empty `<span>` per
/// icon; `site.css` paints it with a mask cut from the SVG here. Both sides
/// build from [siteIcons], so a class cannot be renamed on one side only.
///
/// Inline SVG repeated the same shapes on every page; a stylesheet rule is
/// downloaded once (backlog B2).
library;

/// One icon: the class its mask rule matches, and the SVG it is cut from.
class SiteIcon {
  /// The class `site.css` paints this icon's mask on.
  final String maskClass;

  /// Every class on the span: [maskClass], after a size class it shares.
  final String classes;

  /// Drawn in black: a mask reads only alpha, and `currentColor` means nothing
  /// inside a `data:` URL. The span's `background-color` is the colour.
  final String svg;

  const SiteIcon(
    this.maskClass, {
    required String paint,
    required String shapes,
    String? sizeClass,
  })  : classes = sizeClass == null ? maskClass : '$sizeClass $maskClass',
        svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" '
            '$paint>$shapes</svg>';

  /// Hidden from assistive tech, as the SVG was: every control that shows an
  /// icon is named by its own `title`, `aria-label` or text.
  String get markup => '<span class="$classes" aria-hidden="true"></span>';

  /// [svg] as a `data:` URL for a double-quoted CSS `url()`. Attribute quotes
  /// become `'` and `%`, `#`, `<`, `>` are escaped; spaces stay as they are.
  String get maskUrl => 'data:image/svg+xml,'
      '${svg.replaceAll('"', "'").splitMapJoin(_unsafe, onMatch: _escape)}';
}

final RegExp _unsafe = RegExp('[%#<>]');

String _escape(Match match) =>
    '%${match[0]!.codeUnitAt(0).toRadixString(16).toUpperCase()}';

const String _stroke = 'fill="none" stroke="black" stroke-width="1.6"';
const String _round = 'stroke-linecap="round" stroke-linejoin="round"';

/// A page outline, split by one line: down the middle or across it.
const String _frame = '<rect x="3" y="4" width="18" height="16" rx="1.5"/>';

const SiteIcon sideBySideIcon = SiteIcon('sbs-icon',
    sizeClass: 'layout-icon',
    paint: _stroke,
    shapes: '$_frame<line x1="12" y1="4" x2="12" y2="20"/>');

const SiteIcon stackedIcon = SiteIcon('stack-icon',
    sizeClass: 'layout-icon',
    paint: _stroke,
    shapes: '$_frame<line x1="3" y1="12" x2="21" y2="12"/>');

const SiteIcon upIcon = SiteIcon('up-icon',
    paint: '$_stroke $_round',
    shapes: '<path d="M12 19V5"/><path d="M5 12l7-7 7 7"/>');

const SiteIcon searchIcon = SiteIcon('search-icon',
    paint: '$_stroke stroke-linecap="round"',
    shapes: '<circle cx="11" cy="11" r="7"/><path d="M20 20l-4.3-4.3"/>');

const SiteIcon searchCloseIcon = SiteIcon('search-close-icon',
    paint: '$_stroke stroke-linecap="round"',
    shapes: '<path d="M6 6l12 12"/><path d="M18 6L6 18"/>');

/// The ↗ that says the link opens a new tab. A heavier stroke, as it is
/// drawn smaller than the rest.
const SiteIcon newTabIcon = SiteIcon('new-tab-icon',
    paint: 'fill="none" stroke="black" stroke-width="2" $_round',
    shapes: '<path d="M7 17L17 7"/><path d="M9 7h8v8"/>');

/// The ⋮. Filled, not stroked.
const SiteIcon moreIcon = SiteIcon('more-icon',
    paint: 'fill="black"',
    shapes: '<circle cx="12" cy="5" r="1.6"/><circle cx="12" cy="12" r="1.6"/>'
        '<circle cx="12" cy="19" r="1.6"/>');

/// Every icon, in the order the stylesheet writes their rules.
const List<SiteIcon> siteIcons = [
  sideBySideIcon,
  stackedIcon,
  upIcon,
  searchIcon,
  moreIcon,
  newTabIcon,
  searchCloseIcon,
];
