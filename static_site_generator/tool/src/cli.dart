import 'dart:io';

/// Read off `Platform.script` — the URI of the tool being run — so the default
/// build directory is the package's own, not whatever `build/` the working
/// directory happens to hold. Every tool sits one level down, in `tool/`.
final String packageRoot = File.fromUri(Platform.script).parent.parent.path;

/// Accepts `--flag value` and `--flag=value`, and refuses anything else.
///
/// Refuses, because an unrecognised flag that parses as "nothing was passed"
/// runs a gate over the default build and reports PASS — a green answer to a
/// question nobody asked. Null after printing why.
Map<String, String>? parseArgs(List<String> args, Set<String> known) {
  final values = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    final equals = arg.indexOf('=');
    final name = equals == -1 ? arg : arg.substring(0, equals);

    if (!known.contains(name)) {
      stderr.writeln('unknown option: $arg');
      stderr.writeln('known options: ${(known.toList()..sort()).join(', ')}');
      return null;
    }
    if (equals != -1) {
      values[name] = arg.substring(equals + 1);
    } else if (i + 1 < args.length) {
      values[name] = args[++i];
    } else {
      stderr.writeln('$name needs a value.');
      return null;
    }
  }
  return values;
}

/// Absolute, and without the trailing slash a shell completion adds — every
/// root-relative path in a report is cut from a full path using this as the
/// prefix, and `build//` matches none of them.
String normalizeDir(String path) {
  var absolute = Directory(path).absolute.path;
  while (absolute.length > 1 && absolute.endsWith(Platform.pathSeparator)) {
    absolute = absolute.substring(0, absolute.length - 1);
  }
  return absolute;
}
