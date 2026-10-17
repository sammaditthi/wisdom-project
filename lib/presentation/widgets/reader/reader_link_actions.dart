import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wisdom_shared/wisdom_shared.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/utils/url_launcher_utils.dart';
import '../../providers/deep_link_provider.dart';
import '../../providers/tab_provider.dart';

// The reader's outward actions (deep-linking doc, Section B): Copy link, in
// the Share menu where sharing grows, and on the web Open as web page.

/// Copies the active tab's shareable link and confirms with a SnackBar.
Future<void> copyActiveTabLink(BuildContext context, WidgetRef ref) async {
  final link = _activeTabLink(ref);
  if (link == null) return;
  final messenger = ScaffoldMessenger.of(context);
  final message = AppLocalizations.of(context).linkCopied;
  await ref.read(copyTipitakaLinkProvider)(link);
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

/// Opens the active tab's text on the static site, in a new tab. Web only.
/// A short sutta opens as `<chapter>#<sutta>`, the page the site serves.
Future<void> openAsWebPage(BuildContext context, WidgetRef ref) async {
  final link = _activeTabLink(ref);
  if (link == null) return;
  final url = await ref.read(tipitakaLinkUrlBuilderProvider)(link);
  if (!context.mounted) return;
  await UrlLauncherUtils.launchInAppBrowser(context, url.toString());
}

TipitakaLink? _activeTabLink(WidgetRef ref) {
  final nodeKey = ref.read(activeNodeKeyProvider);
  return nodeKey == null ? null : TipitakaLink(nodeKey: nodeKey);
}
