import '../entities/search/recent_search.dart';

/// Repository interface for recent searches functionality
/// Stores and retrieves user's search history for quick access
///
/// Current implementation uses SharedPreferences for local storage.
/// Future: Will sync with Supabase for cross-device history.
abstract class RecentSearchesRepository {
  /// Stored searches, newest first. Null [limit] returns all of them: how
  /// many to show is the UI's call.
  Future<List<RecentSearch>> getRecentSearches({int? limit});

  /// Add a search query to recent searches
  /// If the query already exists, it will be moved to the top
  Future<void> addRecentSearch(String query);

  /// Remove a specific search from history
  Future<void> removeRecentSearch(String query);

  /// Clear all recent searches
  Future<void> clearRecentSearches();
}
