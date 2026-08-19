import '../enums/user_role.dart';

/// A session profile model describing a logged-in user.
class UserSession {
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String regionalScope;
  final List<String> managedCircles;
  final String memberSince;
  final int capabilitiesCount;

  const UserSession({
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.regionalScope,
    required this.managedCircles,
    required this.memberSince,
    required this.capabilitiesCount,
  });
}

/// Singleton manager for tracking the active user's session and role-based permissions.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();

  factory SessionManager() {
    return _instance;
  }

  SessionManager._internal();

  /// Predefined profiles matching the auto-fill options on the sign-in screen.
  static final Map<String, UserSession> _predefinedSessions = {
    'arjun@peersglobal.in': const UserSession(
      name: 'Arjun Patel',
      email: 'arjun@peersglobal.in',
      phone: '+919876543209',
      role: UserRole.circleChair,
      regionalScope: 'Own Circle',
      managedCircles: ['Mumbai Tech Sunrise'],
      memberSince: 'Jan 2023',
      capabilitiesCount: 14,
    ),
    'sanjana@peersglobal.in': const UserSession(
      name: 'Sanjana Mehta',
      email: 'sanjana@peersglobal.in',
      phone: '+919876543201',
      role: UserRole.circleFounder,
      regionalScope: 'Own Circle(s)',
      managedCircles: ['Mumbai Tech Sunrise', 'Pune Tech Innovators'],
      memberSince: 'Mar 2022',
      capabilitiesCount: 26,
    ),
    'rohit@peersglobal.in': const UserSession(
      name: 'Rohit Sharma',
      email: 'rohit@peersglobal.in',
      phone: '+919876543202',
      role: UserRole.circleDirector,
      regionalScope: 'Own Circle(s)',
      managedCircles: [
        'Mumbai Tech Sunrise',
        'Pune Manufacturing Hub',
        'Pune Tech Hub',
      ],
      memberSince: 'Nov 2022',
      capabilitiesCount: 20,
    ),
    'kavitha@peersglobal.in': const UserSession(
      name: 'Kavitha Rao',
      email: 'kavitha@peersglobal.in',
      phone: '+919876543212',
      role: UserRole.industryDirector,
      regionalScope: 'Assigned Industries',
      managedCircles: ['Mumbai Tech Sunrise', 'Tech Sunrise Industry'],
      memberSince: 'Apr 2021',
      capabilitiesCount: 30,
    ),
    'vikram@peersglobal.in': const UserSession(
      name: 'Vikram Malhotra',
      email: 'vikram@peersglobal.in',
      phone: '+919876543204',
      role: UserRole.districtExecDirector,
      regionalScope: 'One District',
      managedCircles: ['Mumbai Tech Sunrise', 'Pune Digital Node', 'Goa Creators Circle'],
      memberSince: 'May 2022',
      capabilitiesCount: 42,
    ),
    'meera@peersglobal.in': const UserSession(
      name: 'Meera Sen',
      email: 'meera@peersglobal.in',
      phone: '+919876543205',
      role: UserRole.countryDirector,
      regionalScope: 'Entire Country',
      managedCircles: ['All National Circles'],
      memberSince: 'Sep 2020',
      capabilitiesCount: 60,
    ),
    'admin@peersglobal.in': const UserSession(
      name: 'Super Admin',
      email: 'admin@peersglobal.in',
      phone: '+919876543200',
      role: UserRole.superAdmin,
      regionalScope: 'Global',
      managedCircles: ['All Platform Circles'],
      memberSince: 'Jan 2020',
      capabilitiesCount: 99,
    ),
  };

  /// The active user session. Defaults to Circle Chair (Arjun Patel).
  UserSession _currentSession = _predefinedSessions['arjun@peersglobal.in']!;

  /// Gets the current user session details.
  UserSession get currentSession => _currentSession;

  /// Gets the current active role.
  UserRole get currentRole => _currentSession.role;

  /// Initializes the session based on the email/phone used to log in.
  void initializeSession(String emailOrPhone) {
    final cleanInput = emailOrPhone.trim().toLowerCase();
    
    // Look up in our predefined list of email mock users
    if (_predefinedSessions.containsKey(cleanInput)) {
      _currentSession = _predefinedSessions[cleanInput]!;
      return;
    }

    // Fallback/dynamic session setup for custom emails
    _currentSession = UserSession(
      name: 'User (${cleanInput.split('@').first})',
      email: cleanInput,
      phone: '+919999999999',
      role: UserRole.circleChair, // Default to Circle Chair
      regionalScope: 'Own Circle',
      managedCircles: ['Mumbai Tech Sunrise'],
      memberSince: 'Aug 2026',
      capabilitiesCount: 10,
    );
  }

  /// Clears the session upon sign out.
  void clearSession() {
    _currentSession = _predefinedSessions['arjun@peersglobal.in']!;
  }
}
