import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// A small Chrome DevTools Protocol client over `dart:io`'s own WebSocket.
///
/// `check_in_browser.dart` asks its questions through CDP's `DOM` and `CSS`
/// domains rather than through in-page JavaScript, because half of what it
/// checks is how the site behaves with script execution switched off — and a
/// harness that drives the page with injected script cannot see that at all.
class Cdp {
  Cdp(this._socket) {
    _socket.listen(_onMessage, onDone: _done.complete);
  }

  static Future<Cdp> connect(String wsUrl) async =>
      Cdp(await WebSocket.connect(wsUrl));

  final WebSocket _socket;
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _waiters = <_Waiter>[];
  final _done = Completer<void>();
  int _nextId = 1;

  Future<Map<String, dynamic>> call(
    String method, [
    Map<String, dynamic> params = const {},
  ]) {
    final id = _nextId++;
    final completer = Completer<Map<String, dynamic>>();
    _pending[id] = completer;
    _socket.add(jsonEncode({'id': id, 'method': method, 'params': params}));
    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw TimeoutException('$method timed out'),
    );
  }

  /// Completes on the first of [methods] to arrive. Register it *before* the
  /// call that triggers it: a page can finish loading before a waiter added
  /// afterwards is listening, and then the wait only ever times out.
  Future<void> waitFor(
    Set<String> methods, {
    Duration timeout = const Duration(seconds: 20),
  }) {
    final waiter = _Waiter(methods, Completer());
    _waiters.add(waiter);
    return waiter.completer.future.timeout(timeout, onTimeout: () {
      _waiters.remove(waiter);
      throw TimeoutException('none of $methods arrived');
    });
  }

  Future<void> close() async {
    await _socket.close();
    await _done.future;
  }

  void _onMessage(dynamic raw) {
    final message = jsonDecode(raw as String) as Map<String, dynamic>;
    final id = message['id'];
    if (id is int) {
      final completer = _pending.remove(id);
      if (completer == null) return;
      if (message.containsKey('error')) {
        completer.completeError(StateError('CDP error: ${message['error']}'));
      } else {
        completer.complete((message['result'] as Map).cast<String, dynamic>());
      }
      return;
    }
    final method = message['method'] as String?;
    if (method == null) return;
    for (final waiter in [..._waiters]) {
      if (waiter.methods.contains(method) && !waiter.completer.isCompleted) {
        _waiters.remove(waiter);
        waiter.completer.complete();
      }
    }
  }
}

class _Waiter {
  _Waiter(this.methods, this.completer);

  final Set<String> methods;
  final Completer<void> completer;
}
