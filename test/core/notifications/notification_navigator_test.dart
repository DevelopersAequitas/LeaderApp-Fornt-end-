import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/models/leader_permissions.dart';
import 'package:leaderapp/core/notifications/notification_destination.dart';
import 'package:leaderapp/core/notifications/notification_navigator.dart';

class _Nav implements NotificationNavTarget {
  bool available = true;
  /// Each entry is `route|arguments` (arguments stringified so maps compare by value).
  final List<String> pushed = [];

  @override
  bool get isAvailable => available;

  @override
  Future<void> pushNamed(String route, {Object? arguments}) async {
    pushed.add(arguments == null ? route : '$route|$arguments');
  }

  List<String> get routes => pushed.map((p) => p.split('|').first).toList();
}

class _Harness {
  _Harness({
    LeaderPermissions? permissions,
    this.circle = 'CIRCLE_OBJ',
    this.report = 'REPORT_OBJ',
  }) : perms = permissions ?? LeaderPermissions.allGranted;

  final _Nav nav = _Nav();
  bool authenticated = true;
  LeaderPermissions perms;
  Object? circle;
  Object? report;
  bool circleThrows = false;
  final List<String> messages = [];
  DateTime clock = DateTime(2026, 11, 24, 12);

  late final NotificationNavigator navigator = NotificationNavigator(
    target: nav,
    isAuthenticated: () => authenticated,
    permissions: () => perms,
    resolveCircle: (id) async {
      if (circleThrows) throw Exception('offline');
      return circle;
    },
    resolveReport: (id) async => report,
    showMessage: messages.add,
    now: () => clock,
  );
}

Future<void> _flush() => Future<void>.delayed(Duration.zero);

void main() {
  group('payload → destination (legacy hints keep working)', () {
    NotificationDestination d(Map<String, dynamic> m) =>
        NotificationPayload.fromMap(m).destination;

    test('screen/route/click_action hints map to the same tabs as before', () {
      expect(d({'screen': 'teams'}), const HomeTabDestination(2));
      expect(d({'route': '/circles'}), const HomeTabDestination(2));
      expect(d({'click_action': 'finance'}), const HomeTabDestination(3));
      expect(d({'screen': 'reports'}), const HomeTabDestination(4));
      expect(d({'screen': 'peers'}), const HomeTabDestination(1));
      expect(d({'screen': '/dashboard'}), const HomeTabDestination(0));
      expect(d({'screen': 'profile'}), const ProfileDestination());
      expect(d({'screen': 'notifications'}), const NotificationsFeedDestination());
    });

    test('type and category also route (feed behaviour preserved)', () {
      expect(d({'type': 'role_assigned'}), const RoleManagementDestination());
      expect(d({'type': 'tenure_started'}), const RoleManagementDestination());
      expect(d({'type': 'payout_ready'}), const HomeTabDestination(3));
      expect(d({'notification_type': 'attendance_alert'}), const HomeTabDestination(4));
      expect(d({'type': 'p2p_logged'}), const HomeTabDestination(1));
      expect(d({'category': 'circle'}), const HomeTabDestination(2));
    });

    test('empty or unknown payload names no destination', () {
      expect(d({}), const NoDestination());
      expect(d({'screen': '   '}), const NoDestination());
      expect(d({'screen': 'something_else'}), const NoDestination());
    });

    test('an arbitrary string from the payload is never pushed as a route', () {
      // Before: pushNamed(<any payload string>). Now: unknown → NoDestination.
      expect(d({'route': '/admin/delete-everything'}), const NoDestination());
    });
  });

  group('entity ids (proposed contract) are kept, not lost', () {
    test('peer / circle / report entities carry their id', () {
      expect(
        NotificationPayload.fromMap({'entity_type': 'peer', 'entity_id': 'p-1'}).destination,
        const PeerProfileDestination('p-1'),
      );
      expect(
        NotificationPayload.fromMap({'entity_type': 'Circle', 'entity_id': 'c-9'}).destination,
        const CircleDetailsDestination('c-9'),
      );
      expect(
        NotificationPayload.fromMap({'entity_type': 'report', 'entity_id': 'r-3'}).destination,
        const ReportDetailsDestination('r-3'),
      );
    });

    test('an entity wins over a vague legacy hint (peer push no longer lands on the list)', () {
      final p = NotificationPayload.fromMap(
        {'screen': 'peer_profile', 'entity_type': 'peer', 'entity_id': 'p-7'},
      );
      expect(p.destination, const PeerProfileDestination('p-7'));
    });

    test('entity type without an id, or an unsupported type, falls back to hints', () {
      expect(
        NotificationPayload.fromMap({'screen': 'peers', 'entity_type': 'peer'}).destination,
        const HomeTabDestination(1),
      );
      expect(
        NotificationPayload.fromMap({'entity_type': 'invoice', 'entity_id': '1'}).destination,
        const NoDestination(),
      );
    });
  });

  group('readiness, authentication and cold start', () {
    test('a tap before the app is ready is queued, then opened once', () async {
      final h = _Harness();
      h.navigator.handle({'screen': 'finance'});
      await _flush();
      expect(h.nav.pushed, isEmpty); // cold start: nothing happens yet
      expect(h.navigator.hasPending, isTrue);

      h.navigator.markReady(); // home shell mounted
      await _flush();
      expect(h.nav.pushed, ['/home|{tab: 3}']);
      expect(h.navigator.hasPending, isFalse);

      h.navigator.markReady(); // a second ready signal must not re-open it
      await _flush();
      expect(h.nav.pushed.length, 1);
    });

    test('a tap while signed out waits for authentication', () async {
      final h = _Harness();
      h.authenticated = false;
      h.navigator.markReady();
      h.navigator.handle({'screen': 'reports'});
      await _flush();
      expect(h.nav.pushed, isEmpty);

      h.authenticated = true; // login finished, home shell mounts again
      h.navigator.markReady();
      await _flush();
      expect(h.nav.pushed, ['/home|{tab: 4}']);
    });

    test('no navigator yet (tree not mounted) keeps it pending', () async {
      final h = _Harness();
      h.nav.available = false;
      h.navigator.markReady();
      h.navigator.handle({'screen': 'peers'});
      await _flush();
      expect(h.nav.pushed, isEmpty);
      h.nav.available = true;
      h.navigator.markReady();
      await _flush();
      expect(h.nav.routes, ['/home']);
    });

    test('when ready and signed in a tap opens immediately (foreground/background)', () async {
      final h = _Harness();
      h.navigator.markReady();
      h.navigator.handle({'screen': 'teams'});
      await _flush();
      expect(h.nav.pushed, ['/home|{tab: 2}']);
    });

    test('only the latest pending tap is kept', () async {
      final h = _Harness();
      h.navigator.handle({'screen': 'finance'});
      h.navigator.handle({'screen': 'reports'});
      h.navigator.markReady();
      await _flush();
      expect(h.nav.pushed, ['/home|{tab: 4}']);
    });

    test('a stale pending tap is discarded after the TTL', () async {
      final h = _Harness();
      h.navigator.handle({'screen': 'finance'});
      h.clock = h.clock.add(const Duration(minutes: 16));
      h.navigator.markReady();
      await _flush();
      expect(h.nav.pushed, isEmpty);
    });

    test('reset() (sign-out) drops a pending tap and requires a new ready signal', () async {
      final h = _Harness();
      h.navigator.handle({'screen': 'finance'});
      h.navigator.reset();
      h.navigator.markReady();
      await _flush();
      expect(h.nav.pushed, isEmpty);
    });

    test('an identical tap delivered twice within 2 s opens once', () async {
      final h = _Harness();
      h.navigator.markReady();
      h.navigator.handle({'screen': 'finance'});
      h.navigator.handle({'screen': 'finance'});
      await _flush();
      expect(h.nav.pushed.length, 1);
      h.clock = h.clock.add(const Duration(seconds: 3));
      h.navigator.handle({'screen': 'finance'});
      await _flush();
      expect(h.nav.pushed.length, 2);
    });
  });

  group('entities: valid, deleted and unauthorised', () {
    test('peer profile opens by id', () async {
      final h = _Harness()..navigator.markReady();
      h.navigator.handle({'entity_type': 'peer', 'entity_id': 'p-42'});
      await _flush();
      expect(h.nav.pushed, ['/peer-profile|p-42']);
    });

    test('circle and report are fetched by id and passed on', () async {
      final h = _Harness()..navigator.markReady();
      h.navigator.handle({'entity_type': 'circle', 'entity_id': 'c-1'});
      h.clock = h.clock.add(const Duration(seconds: 5));
      h.navigator.handle({'entity_type': 'report', 'entity_id': 'r-1'});
      await _flush();
      expect(h.nav.pushed, [
        '/circle-details|CIRCLE_OBJ',
        '/report-details|REPORT_OBJ',
      ]);
    });

    test('a deleted/missing Circle shows a message and opens the feed', () async {
      final h = _Harness(circle: null)..navigator.markReady();
      h.navigator.handle({'entity_type': 'circle', 'entity_id': 'gone'});
      await _flush();
      expect(h.messages, ['That Circle is no longer available.']);
      expect(h.nav.routes, ['/notifications']);
    });

    test('a failing lookup is treated as unavailable, never a crash', () async {
      final h = _Harness()..navigator.markReady();
      h.circleThrows = true;
      h.navigator.handle({'entity_type': 'circle', 'entity_id': 'c-1'});
      await _flush();
      expect(h.messages, ['That Circle is no longer available.']);
      expect(h.nav.routes, ['/notifications']);
    });

    test('a deleted report shows its own message', () async {
      final h = _Harness(report: null)..navigator.markReady();
      h.navigator.handle({'entity_type': 'report', 'entity_id': 'gone'});
      await _flush();
      expect(h.messages, ['That report is no longer available.']);
    });

    test('an unauthorised destination is blocked with a message and the feed', () async {
      final h = _Harness(permissions: const LeaderPermissions())..navigator.markReady();
      h.navigator.handle({'screen': 'finance'});
      await _flush();
      expect(h.messages, ['You do not have access to that screen.']);
      expect(h.nav.routes, ['/notifications']);
    });

    test('permissions are checked per destination kind', () {
      const none = LeaderPermissions(
        canAccessDashboard: false,
        canAccessPeersTab: false,
        canViewPeerProfile: false,
        canAccessReportsTab: false,
      );
      expect(isDestinationAllowed(const HomeTabDestination(3), none), isFalse);
      expect(isDestinationAllowed(const HomeTabDestination(1), none), isFalse);
      expect(isDestinationAllowed(const HomeTabDestination(4), none), isFalse);
      expect(isDestinationAllowed(const PeerProfileDestination('x'), none), isFalse);
      expect(isDestinationAllowed(const CircleDetailsDestination('x'), none), isFalse);
      expect(isDestinationAllowed(const ReportDetailsDestination('x'), none), isFalse);
      expect(isDestinationAllowed(const RoleManagementDestination(), none), isFalse);
      expect(isDestinationAllowed(const NotificationsFeedDestination(), none), isTrue);
      expect(isDestinationAllowed(const HomeTabDestination(3), LeaderPermissions.allGranted), isTrue);
    });
  });

  group('unknown payloads', () {
    test('a push tap with no destination opens the feed', () async {
      final h = _Harness()..navigator.markReady();
      h.navigator.handle({});
      await _flush();
      expect(h.nav.routes, ['/notifications']);
    });

    test('a tap inside the feed with no destination stays put (just marks read)', () async {
      final h = _Harness()..navigator.markReady();
      h.navigator.handle({}, openFeedWhenUnknown: false);
      await _flush();
      expect(h.nav.pushed, isEmpty);
    });
  });
}
