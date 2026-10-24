import 'package:flutter/material.dart';

import '../../../core/localization/l10n/app_localizations.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/url_launcher_utils.dart';
import '../../../core/version/app_version.gen.dart';
import '../../../domain/entities/dictionary/dictionary_info.dart';
import 'settings_row.dart';

/// Settings → Anumodanā: who and what this app is built on.
///
/// Rejoicing in the merit of the work it stands on, and the attribution the
/// text and dictionary licences require — see
/// `docs/general/things-to-consider-before-going-live.md`, blocker 1. Proper
/// names, dictionary names and licence names are never translated.
class AnumodanaPage extends StatelessWidget {
  const AnumodanaPage({super.key});

  /// The Buddha Jayanti Tripiṭaka is a printed edition; it has no site of its
  /// own, so its row carries no link.
  static const _tipitakaLkUrl = 'https://tipitaka.lk';
  static const _suttaCentralUrl = 'https://suttacentral.net';
  static const _dpdUrl = 'https://www.dpdict.net';

  /// The one dictionary whose licence asks to be cited where it is used.
  static const _dpdId = 'DPD';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        settingsGutter,
        0,
        settingsGutter,
        28,
      ),
      children: [
        // Hidden until the wording is refined. When it comes back it is the
        // first section again, and Text sources drops `isFirst`.
        // SettingsSection(
        //   title: l10n.anumodanaLineage,
        //   isFirst: true,
        //   children: [_Prose(l10n.anumodanaLineageBody)],
        // ),
        SettingsSection(
          title: l10n.anumodanaTextSources,
          isFirst: true,
          children: [
            SettingsRow(
              label: 'Buddha Jayanti Tripiṭaka',
              hint: l10n.anumodanaBjtUse,
              leading: const SettingsTile(icon: Icons.menu_book_outlined),
            ),
            SettingsRow(
              label: 'tipitaka.lk',
              hint: l10n.anumodanaTipitakaLkUse,
              leading: const SettingsTile(icon: Icons.language_outlined),
              trailing: const _OpenLinkButton(
                name: 'tipitaka.lk',
                url: _tipitakaLkUrl,
              ),
            ),
            SettingsRow(
              label: 'SuttaCentral',
              hint: l10n.anumodanaSuttaCentralUse,
              leading: const SettingsTile(icon: Icons.translate_outlined),
              trailing: const _OpenLinkButton(
                name: 'SuttaCentral',
                url: _suttaCentralUrl,
              ),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.anumodanaDictionaries,
          hint: l10n.anumodanaDictionariesHint,
          children: [
            _DictionaryGroup(
              label: l10n.anumodanaDictGroupSinhala,
              dictionaries: _dictionariesFor('si'),
            ),
            _DictionaryGroup(
              label: l10n.anumodanaDictGroupEnglish,
              dictionaries: _dictionariesFor('en'),
            ),
          ],
        ),
        SettingsSection(
          title: l10n.anumodanaThanks,
          children: [_Prose(l10n.anumodanaThanksBody)],
        ),
        SettingsSection(
          title: l10n.anumodanaLicences,
          children: const [
            SettingsRow(
              label: 'Noto Sans, Noto Serif, Noto Sans Sinhala, '
                  'Noto Serif Sinhala',
              hint: 'SIL Open Font License 1.1',
              leading: SettingsTile(icon: Icons.text_fields_outlined),
              showDivider: false,
            ),
            _OpenSourceLicencesLink(),
          ],
        ),
      ],
    );
  }

  /// Every bundled dictionary that translates into [targetLanguage], by name.
  ///
  /// Alphabetical, not `DictionaryInfo.all`'s order — that one ranks them for
  /// the lookup sheet, and a ranking here would read as a recommendation.
  static List<DictionaryInfo> _dictionariesFor(String targetLanguage) => [
        for (final d in DictionaryInfo.all.values)
          if (d.targetLanguage == targetLanguage) d,
      ]..sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
        );
}

/// One language group of dictionary rows, under a small label.
class _DictionaryGroup extends StatelessWidget {
  const _DictionaryGroup({required this.label, required this.dictionaries});

  final String label;
  final List<DictionaryInfo> dictionaries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 2),
          child: Text(label, style: context.typography.menuSectionLabel),
        ),
        for (final d in dictionaries)
          SettingsRow(
            label: d.name,
            hint:
                d.id == AnumodanaPage._dpdId ? l10n.anumodanaDpdLicence : null,
            leading: SettingsTile(text: d.abbreviation),
            trailing: d.id == AnumodanaPage._dpdId
                ? _OpenLinkButton(name: d.name, url: AnumodanaPage._dpdUrl)
                : null,
            showDivider: d != dictionaries.last,
          ),
      ],
    );
  }
}

/// The open-source licence list, as a plain link under the font licence.
///
/// Not a row: the MIT/BSD packages and the bundled Noto fonts (OFL) need
/// their text to be readable somewhere in the app, which `showLicensePage`
/// does — but it is the least interesting thing on the page.
class _OpenSourceLicencesLink extends StatelessWidget {
  const _OpenSourceLicencesLink();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          textStyle: context.typography.menuSectionLabel,
          padding: const EdgeInsets.symmetric(vertical: 8),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: () => showLicensePage(
          context: context,
          applicationName: l10n.appTitle,
          applicationVersion: AppVersion.display,
        ),
        child: Text(l10n.openSourceLicences),
      ),
    );
  }
}

/// A paragraph that is a statement rather than a labelled setting.
class _Prose extends StatelessWidget {
  const _Prose(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2, bottom: 4),
      child: Text(text, style: context.typography.listRowTitle),
    );
  }
}

/// Opens a credited source's website in an in-app browser.
class _OpenLinkButton extends StatelessWidget {
  const _OpenLinkButton({required this.name, required this.url});

  final String name;
  final String url;

  @override
  Widget build(BuildContext context) {
    final label = AppLocalizations.of(context).openLinkTo(name);
    return IconButton(
      icon: const Icon(Icons.open_in_new, size: 18),
      tooltip: label,
      onPressed: () => UrlLauncherUtils.launchInAppBrowser(context, url),
    );
  }
}
