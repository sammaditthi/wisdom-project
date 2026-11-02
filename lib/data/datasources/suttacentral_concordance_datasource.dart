import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/services.dart';

/// Loads the committed SuttaCentral↔BJT concordance asset, built by
/// `tools/suttacentral_map/`. Loaded once and kept in memory, like the
/// navigation tree; [SuttaCentralRefResolver.fromJson] (in `wisdom_shared`)
/// reads it.
abstract class SuttaCentralConcordanceDataSource {
  /// The decoded asset. Throws if it is missing or malformed.
  Future<Map<String, dynamic>> load();
}

class SuttaCentralConcordanceDataSourceImpl
    implements SuttaCentralConcordanceDataSource {
  /// Web fetches it into `rootBundle`'s string cache before a first visit
  /// shows the app (`WebDatabaseInstaller`), so it is read from that cache.
  static const String assetPath = 'assets/data/sc-to-bjt.json';

  @override
  Future<Map<String, dynamic>> load() async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e, stack) {
      // Non-fatal: without it there is no reference jump and no SuttaCentral
      // link; FTS is unaffected. Rethrown so the FutureProvider surfaces an
      // error state, which its readers treat as "no resolver".
      developer.log('Failed to load SC↔BJT concordance',
          name: 'SCConcordance', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
