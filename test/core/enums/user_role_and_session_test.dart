import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/core/enums/user_role.dart';
import 'package:leaderapp/core/helpers/session_manager.dart';

void main() {
  group('Batch 2: Canonical UserRole & SessionManager Security', () {
    test('All canonical backend role keys parse accurately', () {
      expect(UserRole.fromLabel('super_admin'), UserRole.superAdmin);
      expect(UserRole.fromLabel('superAdmin'), UserRole.superAdmin);
      expect(UserRole.fromLabel('global_founder'), UserRole.globalFounder);
      expect(UserRole.fromLabel('globalFounder'), UserRole.globalFounder);
      expect(UserRole.fromLabel('country_director'), UserRole.countryDirector);
      expect(UserRole.fromLabel('eed'), UserRole.countryDirector);
      expect(UserRole.fromLabel('ded'), UserRole.districtExecDirector);
      expect(
        UserRole.fromLabel('districtExecDirector'),
        UserRole.districtExecDirector,
      );
      expect(UserRole.fromLabel('industry_director'), UserRole.industryDirector);
      expect(UserRole.fromLabel('id'), UserRole.industryDirector);
      expect(UserRole.fromLabel('circle_founder'), UserRole.circleFounder);
      expect(UserRole.fromLabel('cf'), UserRole.circleFounder);
      expect(UserRole.fromLabel('circle_director'), UserRole.circleDirector);
      expect(UserRole.fromLabel('cd'), UserRole.circleDirector);
      expect(
        UserRole.fromLabel('chairBusinessGrowth'),
        UserRole.chairBusinessGrowth,
      );
      expect(UserRole.fromLabel('chairMembership'), UserRole.chairMembership);
      expect(UserRole.fromLabel('chairEventsPrograms'), UserRole.chairEvents);
      expect(UserRole.fromLabel('circleChair'), UserRole.circleChair);
      expect(UserRole.fromLabel('committee_leader'), UserRole.committeeLeader);
      expect(UserRole.fromLabel('committeeLeader'), UserRole.committeeLeader);
      expect(UserRole.fromLabel('vice_chair'), UserRole.viceChair);
      expect(UserRole.fromLabel('viceChair'), UserRole.viceChair);
      expect(UserRole.fromLabel('secretary'), UserRole.secretary);
    });

    test('Unknown or null roles fail safely without becoming superAdmin', () {
      expect(UserRole.fromLabel(null), isNull);
      expect(UserRole.fromLabel(''), isNull);
      expect(UserRole.fromLabel('unknown_role'), isNull);
      expect(UserRole.fromLabel('circle_administrator_helper'), isNull);
      expect(UserRole.fromLabel('not_super_admin'), isNull);
    });

    test(
      'Custom role labels containing admin cannot escalate privileges or isSuperAdmin',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': 'u-1',
          'name': 'Regular Chair',
          'email': 'chair@peersglobal.com',
          'phone': '9000000000',
          'role': 'circleChair',
          'custom_role_label': 'Circle Admin Coordinator',
        });

        expect(SessionManager().currentRole, UserRole.circleChair);
        expect(SessionManager().isSuperAdmin, isFalse);
        expect(SessionManager().permissions.canAccessRoleManagement, isFalse);
        expect(SessionManager().permissions.canAccessFinanceTab, isFalse);
      },
    );

    test(
      'Legitimate superAdmin and globalFounder retain executive access',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': 'u-gf',
          'name': 'Global Founder',
          'email': 'gf@peersglobal.com',
          'phone': '9000000001',
          'role': 'global_founder',
        });
        expect(SessionManager().currentRole, UserRole.globalFounder);
        expect(SessionManager().isSuperAdmin, isTrue);
        expect(SessionManager().permissions.canAccessRoleManagement, isTrue);

        await SessionManager().updateFromAuthProfile({
          'id': 'u-sa',
          'name': 'Super Admin',
          'email': 'sa@peersglobal.com',
          'phone': '9000000002',
          'role': 'super_admin',
        });
        expect(SessionManager().currentRole, UserRole.superAdmin);
        expect(SessionManager().isSuperAdmin, isTrue);
        expect(SessionManager().permissions.canAccessRoleManagement, isTrue);
      },
    );

    test(
      'Vice Chair, Secretary, and Committee Leader receive aligned permissions',
      () async {
        await SessionManager().updateFromAuthProfile({
          'id': 'u-vc',
          'name': 'Vice Chair',
          'email': 'vc@peersglobal.com',
          'phone': '9000000003',
          'role': 'vice_chair',
        });
        expect(SessionManager().currentRole, UserRole.viceChair);
        expect(SessionManager().permissions.canAccessDashboard, isTrue);
        expect(SessionManager().permissions.canAccessPeersTab, isTrue);
        expect(SessionManager().permissions.canAccessTeamsTab, isFalse);
        expect(SessionManager().permissions.canAccessFinanceTab, isFalse);

        await SessionManager().updateFromAuthProfile({
          'id': 'u-sec',
          'name': 'Secretary',
          'email': 'sec@peersglobal.com',
          'phone': '9000000004',
          'role': 'secretary',
        });
        expect(SessionManager().currentRole, UserRole.secretary);
        expect(SessionManager().permissions.canAccessTeamsTab, isFalse);

        await SessionManager().updateFromAuthProfile({
          'id': 'u-cl',
          'name': 'Committee Leader',
          'email': 'cl@peersglobal.com',
          'phone': '9000000005',
          'role': 'committee_leader',
        });
        expect(SessionManager().currentRole, UserRole.committeeLeader);
        expect(SessionManager().permissions.canAccessTeamsTab, isTrue);
        expect(SessionManager().permissions.canAccessFinanceTab, isFalse);
      },
    );
  });
}
