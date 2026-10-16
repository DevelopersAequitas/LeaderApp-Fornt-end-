import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/features/reports/model/report_model.dart';
import 'package:leaderapp/features/reports/view/services/report_export_service.dart';

void main() {
  group('Reports Dummy Data Filtering Tests', () {
    test('isDummyPeer correctly flags Siddharth Verma and Pooja Sharma', () {
      expect(ReportModel.isDummyPeer('Siddharth Verma'), isTrue);
      expect(ReportModel.isDummyPeer('siddharth verma'), isTrue);
      expect(ReportModel.isDummyPeer('Sidhdharth Verma'), isTrue);
      expect(ReportModel.isDummyPeer('Pooja Sharma'), isTrue);
      expect(ReportModel.isDummyPeer('pooja sharma'), isTrue);
      expect(ReportModel.isDummyPeer('Apex Dynamics Pvt Ltd', '76265b49-4e41-406e-bb8c-7182d5f6536c'), isTrue);
      expect(ReportModel.isDummyPeer('BioHealth Labs', 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d'), isTrue);

      // Real user names must NOT be flagged
      expect(ReportModel.isDummyPeer('Arjun Patel'), isFalse);
      expect(ReportModel.isDummyPeer('Vikram Mehta'), isFalse);
    });

    test('isDummyReport flags rep_101 and dummy seeded reports', () {
      const dummyReport = ReportModel(
        id: 'rep_101',
        type: 'Monthly',
        circleName: 'Mumbai Tech Sunrise',
        status: 'Approved',
        date: 'August 2026',
        content: 'Strong monthly participation with 4 new peer referrals closed.',
        author: 'Arjun Patel',
      );
      expect(ReportModel.isDummyReport(dummyReport), isTrue);

      const realReport = ReportModel(
        id: 'real_uuid_999',
        type: 'Monthly',
        circleName: 'Delhi Central',
        status: 'Approved',
        date: 'September 2026',
        content: 'Authentic meeting conducted with 40 members.',
        author: 'Mohit Sharma',
      );
      expect(ReportModel.isDummyReport(realReport), isFalse);
    });

    test('ReportModel.fromJson filters out dummy peers in peers_roster', () {
      final json = {
        'id': 'rep_200',
        'report_type': 'Monthly',
        'circle_name': 'Mumbai Tech Sunrise',
        'status': 'Submitted',
        'period': 'September 2026',
        'summary_text': 'Valid report content',
        'submitted_by': 'Vikram Mehta',
        'submitter_avatar_url': 'https://example.com/avatar.png',
        'peers_roster': [
          {
            'peer_id': '76265b49-4e41-406e-bb8c-7182d5f6536c',
            'name': 'Siddharth Verma',
            'company': 'Apex Dynamics',
            'designation': 'CEO',
            'status': 'Active',
          },
          {
            'peer_id': 'a1b2c3d4-e5f6-4a5b-8c7d-9e0f1a2b3c4d',
            'name': 'Pooja Sharma',
            'company': 'BioHealth',
            'designation': 'MD',
            'status': 'Active',
          },
          {
            'peer_id': 'valid_peer_01',
            'name': 'Ramesh Kumar',
            'company': 'Tech Corp',
            'designation': 'CTO',
            'status': 'Active',
          },
        ],
      };

      final report = ReportModel.fromJson(json);

      expect(report.authorAvatarUrl, 'https://example.com/avatar.png');
      expect(report.peersRoster.length, 1);
      expect(report.peersRoster.first.name, 'Ramesh Kumar');
    });
  });

  group('Reports CSV Export Tests', () {
    test('generateCsvData includes headers and proper quoting', () {
      const report = ReportModel(
        id: 'rep_csv_1',
        circleName: 'Mumbai Pioneers, Inc.',
        date: 'October 2026',
        type: 'Monthly',
        status: 'Submitted',
        author: 'Aarav Patel',
        authorRole: 'Circle Chair',
        attendancePercentage: 92.5,
        dealsClosedValue: '₹ 15,00,000',
        totalRevenue: '₹ 25,00,000',
        content: 'Good progress\nSecond line',
      );

      final List<ReportPeerRosterItem> peers = [
        const ReportPeerRosterItem(
          peerId: 'peer_1',
          name: 'Vikram, Shah',
          company: 'Shah "Ventures"',
          designation: 'CEO',
          status: 'Active',
          platformMembershipStart: '2024-01-01',
          platformMembershipEnd: '2025-01-01',
          circleJoiningDate: '2024-01-01',
          circleRenewalDate: '2025-01-01',
          attendance: '95%',
          dealsClosed: '₹ 5,00,000',
          p2pCount: 4,
          referralsCount: 6,
        ),
      ];

      final csv = ReportExportService.generateCsvData(report, peers);

      expect(csv, contains('CIRCLE PERFORMANCE REPORT'));
      expect(csv, contains('"Mumbai Pioneers, Inc."'));
      expect(csv, contains('Attendance,92.5%'));
      expect(csv, contains('"Vikram, Shah"'));
      expect(csv, contains('"Shah ""Ventures"""'));
      expect(csv, contains('peer_1'));
      expect(csv, contains('4,6'));
    });
  });
}

