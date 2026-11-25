/// The `retry:` for every root ProviderScope and ProviderContainer, app and
/// tests alike. Riverpod 3 retries a failing provider for ~38 s by default,
/// showing loading all the while. Our data is all local (bundled DBs, assets),
/// so a failed load fails again: show the error at once.
Duration? noProviderRetry(int retryCount, Object error) => null;
