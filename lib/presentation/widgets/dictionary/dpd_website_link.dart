import 'package:flutter/material.dart';

import '../../../core/utils/url_launcher_utils.dart';
import '../search/search_link_button.dart';

/// "dpdict.net ↗" button that opens a DPD entry's page on the DPD website.
///
/// The link is the first `<a>` href in [html]; every DPD entry has one, all
/// on dpdict.net. Shows nothing if an entry has none.
class DpdWebsiteLink extends StatelessWidget {
  /// The entry's raw HTML meaning, which holds the link.
  final String html;

  const DpdWebsiteLink({super.key, required this.html});

  @override
  Widget build(BuildContext context) {
    final href = UrlLauncherUtils.extractFirstHref(html);
    if (href == null) return const SizedBox.shrink();

    return Semantics(
      link: true,
      child: SearchLinkButton(
        label: 'dpdict.net',
        // The standard "leaves the app" mark, as on "Open as web page".
        icon: Icons.open_in_new,
        onPressed: () => UrlLauncherUtils.launchInAppBrowser(context, href),
      ),
    );
  }
}
