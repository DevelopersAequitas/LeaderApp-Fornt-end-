// Brand vocabulary check.
//
// ENFORCED (fails the test): per README.md §9, user-facing product copy under
// lib/ must not use the prohibited terms:
//   * "networking"
//   * "network"
//   * "member" / "members"
//
// Also enforces that project prose docs (README.md, documents/**/*.md) do not
// use "networking".
//
// Comments, Dart identifiers, import/export URIs, and snake_case backend keys
// (e.g. `speed_networking`, `circle_members`) are NOT flagged because a
// word-boundary match never fires inside snake_case identifiers and renaming
// backend contracts is explicitly forbidden.
//
// Narrowly scoped allowlists live in [_allowed] with an explicit reason for
// each non-user-facing internal technical literal (API routes, JSON keys,
// backend enum values, OS socket error matchers, or icon matchers).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Entries: relative path -> exact literal texts (or substrings for markdown
/// docs) that are genuinely non-user-facing, with their technical justification.
const Map<String, Map<String, String>> _allowedLibExact = {
  // OS / socket error substring check (never shown to users).
  'lib/core/utils/error_formatter.dart': {
    'network is unreachable':
        'matches raw OS SocketException text to translate into user-safe copy',
  },
  // Backend-supplied event title matcher for icon selection (never displayed).
  'lib/features/circle_details/view/widgets/circle_events_section.dart': {
    'Networking':
        'matches backend event title to choose an icon; never displayed',
  },
  // Backend JSON key in payload parser.
  'lib/features/member_activities/model/member_activity_model.dart': {
    'member': 'backend JSON key for counterpart lookup',
  },
  // Backend notification category/type matcher for icon/color (never displayed).
  'lib/features/notifications/view/widgets/notification_card.dart': {
    'member': 'matches backend notification category/type to pick icon/color',
  },
  // Backend registration_type enum value & JSON key.
  'lib/features/peers/model/peer_model.dart': {
    'member': 'backend JSON key and registration_type enum value',
  },
  // Backend registration_type enum value.
  'lib/features/peer_profile/model/peer_event_models.dart': {
    'member': 'backend registration_type enum value',
  },
  // Backend JSON keys in report roster parser.
  'lib/features/reports/model/report_model.dart': {
    'member': 'backend JSON key in report parser',
    'members': 'backend JSON key fallback in report roster parser',
  },
  // Backend raw designation matcher to normalize to Peer.
  'lib/features/dashboard/view/widgets/dashboard_top_impacters.dart': {
    'member': 'matches raw backend designation string to display Peer instead',
  },
  // Backend notification audience metadata filter.
  'lib/features/notifications/model/leader_notification_model.dart': {
    'member':
        'matches backend audience metadata to exclude consumer notifications; never displayed',
  },
  // Backend raw designation matcher to normalize to Peer.
  'lib/features/leader_activities/view/widgets/leader_ranked_peer_card.dart': {
    'member': 'matches raw backend designation string to display Peer instead',
  },
};

/// Paths whose string literals are strictly API route templates (backend contract).
const Set<String> _apiRouteFiles = {'lib/core/constants/api_endpoints.dart'};

const Map<String, Map<String, String>> _allowedDocsSubstrings = {
  // The README states the rule itself.
  'README.md': {'networking': 'documents the vocabulary rule'},
  // Quoted API example payload (backend text), not project copy.
  'documents/LEADER_APP_ASK_FLOWS_API_DOCUMENTATION.md': {
    'networking': 'verbatim backend payload example',
  },
};

class _Hit {
  _Hit(this.path, this.line, this.text);
  final String path;
  final int line;
  final String text;
  @override
  String toString() => '$path:$line  ${text.trim()}';
}

/// Extracts the text of every string literal in Dart [source] with its line,
/// skipping comments and import/export/part directives.
List<(int line, String text)> _stringLiterals(String source) {
  final out = <(int, String)>[];
  var i = 0;
  var line = 1;
  final n = source.length;

  bool isDirectiveLineStart(int pos) {
    var lineStart = pos;
    while (lineStart > 0 && source[lineStart - 1] != '\n') {
      lineStart--;
    }
    final prefix = source.substring(lineStart, pos).trimLeft();
    return prefix.startsWith('import ') ||
        prefix.startsWith('export ') ||
        prefix.startsWith('part ');
  }

  while (i < n) {
    final c = source[i];
    if (c == '\n') {
      line++;
      i++;
      continue;
    }
    // Comments
    if (c == '/' && i + 1 < n && source[i + 1] == '/') {
      while (i < n && source[i] != '\n') {
        i++;
      }
      continue;
    }
    if (c == '/' && i + 1 < n && source[i + 1] == '*') {
      i += 2;
      while (i + 1 < n && !(source[i] == '*' && source[i + 1] == '/')) {
        if (source[i] == '\n') line++;
        i++;
      }
      i += 2;
      continue;
    }
    // Strings (optionally raw)
    var raw = false;
    final start = i;
    if (c == 'r' &&
        i + 1 < n &&
        (source[i + 1] == "'" || source[i + 1] == '"')) {
      raw = true;
      i++;
    }
    final q = source[i];
    if (q == "'" || q == '"') {
      final skipDirective = isDirectiveLineStart(start);
      final triple = i + 2 < n && source[i + 1] == q && source[i + 2] == q;
      final delim = triple ? q * 3 : q;
      final startLine = line;
      i += delim.length;
      final buf = StringBuffer();
      while (i < n) {
        if (!raw && source[i] == r'\') {
          buf.write(source.substring(i, i + 2 > n ? n : i + 2));
          if (i + 1 < n && source[i + 1] == '\n') line++;
          i += 2;
          continue;
        }
        if (source.startsWith(delim, i)) {
          i += delim.length;
          break;
        }
        if (source[i] == '\n') {
          if (!triple) break;
          line++;
        }
        buf.write(source[i]);
        i++;
      }
      if (!skipDirective) {
        out.add((startLine, buf.toString()));
      }
      continue;
    }
    i = start + 1;
  }
  return out;
}

final _networking = RegExp(r'\bnetworking\b', caseSensitive: false);
final _networkWord = RegExp(r'\bnetwork\b', caseSensitive: false);
final _memberWord = RegExp(r'\bmembers?\b', caseSensitive: false);
final _anyProhibited = RegExp(
  r'\b(networking|network|members?)\b',
  caseSensitive: false,
);

/// Removes Dart string interpolations like `$memberId` or `${members.length}`
/// before checking prose words so internal Dart variable names inside a
/// template string do not trigger false positives.
String _stripInterpolations(String literal) {
  return literal
      .replaceAll(RegExp(r'\$\{[^}]*\}'), ' ')
      .replaceAll(RegExp(r'\$[A-Za-z_][A-Za-z0-9_]*'), ' ');
}

bool _isAllowedLibLiteral(String relPath, String rawLiteral) {
  if (_apiRouteFiles.contains(relPath)) return true;
  final rules = _allowedLibExact[relPath];
  if (rules == null) return false;
  return rules.containsKey(rawLiteral);
}

bool _isAllowedDocLine(String relPath, String text) {
  final rules = _allowedDocsSubstrings[relPath];
  if (rules == null) return false;
  return rules.keys.any(text.contains);
}

Iterable<File> _files(String dir, String ext) => Directory(dir)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith(ext));

void main() {
  final root = Directory.current.path.replaceAll('\\', '/');
  String rel(File f) {
    final p = f.path.replaceAll('\\', '/');
    return p.startsWith(root) ? p.substring(root.length + 1) : p;
  }

  group('brand vocabulary', () {
    test(
      'scanner finds prohibited literals and ignores comments, imports, and identifiers',
      () {
        const src = '''
import 'package:leaderapp/features/member_activities/model/member_activity_model.dart';
// networking and member in a comment
/* network and members in a block comment */
final a = 'Business networking tips';
final b = "Circle Members";
final c = 'Check your network';
final d = 'speed_networking';
final e = 'Membership Experience';
final f = 'Remember to save';
final g = '\${members.length} Peers';
final h = r'raw networking';
final i = \'\'\'multi
line member copy\'\'\';
''';
        final lits = _stringLiterals(src);
        final hits = lits
            .where((l) => _anyProhibited.hasMatch(_stripInterpolations(l.$2)))
            .toList();
        expect(hits.map((h) => h.$2).toList(), [
          'Business networking tips',
          'Circle Members',
          'Check your network',
          'raw networking',
          'multi\nline member copy',
        ]);
        // Snake_case backend identifiers and unrelated words are never flagged.
        expect(_networking.hasMatch('speed_networking'), isFalse);
        expect(_memberWord.hasMatch('Membership Experience'), isFalse);
        expect(_memberWord.hasMatch('Remember'), isFalse);
        expect(_networkWord.hasMatch('networking'), isFalse);
      },
    );

    test(
      'lib/ user-facing string literals never contain "networking", "network", or "member(s)"',
      () {
        final hits = <_Hit>[];
        for (final f in _files('lib', '.dart')) {
          final path = rel(f);
          for (final lit in _stringLiterals(f.readAsStringSync())) {
            final stripped = _stripInterpolations(lit.$2);
            if (_anyProhibited.hasMatch(stripped) &&
                !_isAllowedLibLiteral(path, lit.$2)) {
              hits.add(_Hit(path, lit.$1, lit.$2));
            }
          }
        }
        expect(
          hits,
          isEmpty,
          reason:
              'User-facing copy must not use "networking", "network", or '
              '"member(s)" per README.md §9. Use Peer/Peers/Leaders/Circle '
              'Participants/Executives and Circle Ecosystem/Collaboration/'
              'Community/Connection instead:\n${hits.join('\n')}',
        );
      },
    );

    test('project prose docs never contain "networking"', () {
      final docs = <File>[File('README.md'), ..._files('documents', '.md')];
      final hits = <_Hit>[];
      for (final f in docs) {
        final path = rel(f);
        final lines = f.readAsStringSync().split('\n');
        for (var i = 0; i < lines.length; i++) {
          if (_networking.hasMatch(lines[i]) &&
              !_isAllowedDocLine(path, lines[i])) {
            hits.add(_Hit(path, i + 1, lines[i]));
          }
        }
      }
      expect(hits, isEmpty, reason: hits.join('\n'));
    });
  });
}
