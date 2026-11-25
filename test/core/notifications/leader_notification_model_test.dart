import 'package:flutter_test/flutter_test.dart';
import 'package:leaderapp/features/notifications/model/leader_notification_model.dart';

void main() {
  group('LeaderNotificationModel.isLeaderNotification', () {
    test('keeps requirement_lead notification even when screen is /post-details', () {
      final model = LeaderNotificationModel.fromJson({
        'id': '01a20cd6-651b-7300-9a5c-0ca438e5dc35',
        'title': 'Potential Business Match Found!',
        'message': 'Chirag Mali is looking for: "a relevant requirement"',
        'body': 'Chirag Mali is looking for: "a relevant requirement"',
        'category': 'requirement_lead',
        'type': 'requirement_lead',
        'is_unread': true,
        'is_read': false,
        'screen': '/post-details',
        'data': {
          'type': 'requirement_lead',
          'screen': '/post-details',
          'campaign_id': '019ee3ca-54e4-7078-941e-8f090ac3eebc',
          'activity_type': 'requirement',
          'notification_type': 'requirement_match',
        },
        'created_at': '2026-11-24T09:15:06+00:00',
      });

      expect(model.isUnread, isTrue);
      expect(model.isLeaderNotification, isTrue);
    });

    test('still filters out consumer social post notifications', () {
      final likeNotif = LeaderNotificationModel.fromJson({
        'id': 'n-like',
        'title': 'New like',
        'message': 'Someone liked your post',
        'category': 'social',
        'type': 'post_like',
        'is_unread': true,
        'screen': '/post-details',
        'created_at': '2026-11-24T09:15:06+00:00',
      });

      expect(likeNotif.isLeaderNotification, isFalse);
    });
  });
}
