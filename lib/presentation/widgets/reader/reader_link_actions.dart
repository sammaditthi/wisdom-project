import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/utils/url_launcher_utils.dart';
import '../../providers/breadcrumb_provider.dart';
import '../../providers/deep_link_provider.dart';
import '../../providers/suttacentral_provider.dart'
    show activeSuttaCentralUrlProvider;
import '../../providers/tab_provider.dart';

// The reader's outward actions (deep-linking doc, Section B), all in the
// toolbar's ⋮ menu: Copy link, Copy path, Open on SuttaCentral, and on the web
// Open as HTML page.

/// Copies the active tab's breadcrumb, names joined by its › marks, and
/// confirms with a SnackBar. The whole trail, however much the bar shows.
Future<void> copyActiveTabPath(BuildContext context, WidgetRef ref) async {
  final segments = ref.read(breadcrumbPathProvider);
  if (segments.isEmpty) return;
  final messenger = ScaffoldMessenger.of(context);
  final snackBar =
      _copiedSnackBar(context, AppLocalizations.of(context).pathCopied);
  await Clipboard.setData(ClipboardData(
    text: segments.map((s) => s.displayName).join(breadcrumbSeparator),
  ));
  messenger.showSnackBar(snackBar);
}

/// Copies the active tab's shareable link and confirms with a SnackBar.
Future<void> copyActiveTabLink(BuildContext context, WidgetRef ref) async {
  final link = _activeTabLink(ref);
  if (link == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final snackBar =
      _copiedSnackBar(context, AppLocalizations.of(context).linkCopied);
  await ref.read(copyTipitakaLinkProvider)(link);
  messenger.showSnackBar(snackBar);
}

/// A copy's confirmation: the message with a tick after it, as a chosen
/// row's tick sits after its label.
SnackBar _copiedSnackBar(BuildContext context, String message) {
  return SnackBar(
    content: Row(
      children: [
        Flexible(child: Text(message)),
        const SizedBox(width: 12),
        // The text's colour, as Material gives a snackbar's own ✕.
        Icon(
          Icons.check,
          size: 20,
          color: Theme.of(context).colorScheme.onInverseSurface,
        ),
      ],
    ),
  );
}

/// Opens the active tab's text on the static site, in a new tab. Web only.
/// A short sutta opens as `<chapter>#<sutta>`, the page the site serves.
Future<void> openAsHtmlPage(BuildContext context, WidgetRef ref) async {
  final link = _activeTabLink(ref);
  if (link == null) return;
  final url = await ref.read(tipitakaLinkUrlBuilderProvider)(link);
  if (!context.mounted) return;
  await UrlLauncherUtils.launchInAppBrowser(context, url.toString());
}

/// Opens the active tab's text on SuttaCentral: Bhikkhu Bodhi's translation
/// when SuttaCentral has it, else Bhikkhu Sujato's (Ajahn Brahmali's for the
/// Vinaya). The ⋮ menu leaves the row out when there is no counterpart.
Future<void> openOnSuttaCentral(BuildContext context, WidgetRef ref) async {
  final url = ref.read(activeSuttaCentralUrlProvider);
  if (url == null) return;
  await UrlLauncherUtils.launchInAppBrowser(context, url.toString());
}

TipitakaLink? _activeTabLink(WidgetRef ref) {
  final nodeKey = ref.read(activeNodeKeyProvider);
  return nodeKey == null ? null : TipitakaLink(nodeKey: nodeKey);
}
