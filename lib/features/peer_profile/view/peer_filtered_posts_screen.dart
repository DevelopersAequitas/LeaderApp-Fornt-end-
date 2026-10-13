import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';
import 'widgets/peer_post_card.dart';

/// Screen listing filtered posts (Collaboration, Requirement, Get Help) for a peer.
class PeerFilteredPostsScreen extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;
  final String title;
  final String postTypeFilter;

  const PeerFilteredPostsScreen({
    super.key,
    required this.peer,
    required this.details,
    required this.title,
    required this.postTypeFilter,
  });

  List<PeerPostModel> get _filteredPosts {
    final filter = postTypeFilter.toLowerCase();
    if (filter == 'collaboration') {
      final matches = details.posts.where((p) {
        final pt = p.postType.toLowerCase();
        return pt == 'collaboration' ||
            pt == 'story' ||
            pt == 'standard' ||
            p.content.toLowerCase().contains('collaborat');
      }).toList();
      return matches.isNotEmpty ? matches : details.posts;
    } else if (filter == 'requirement') {
      return details.posts.where((p) {
        final pt = p.postType.toLowerCase();
        return pt == 'requirement' ||
            p.title.toLowerCase().contains('requirement') ||
            p.content.toLowerCase().contains('requirement');
      }).toList();
    } else if (filter == 'ask' || filter == 'get_help') {
      return details.posts.where((p) {
        final pt = p.postType.toLowerCase();
        return pt == 'ask' ||
            pt == 'get_help' ||
            p.title.toLowerCase().contains('help') ||
            p.content.toLowerCase().contains('help');
      }).toList();
    }
    return details.posts;
  }

  @override
  Widget build(BuildContext context) {
    final posts = _filteredPosts;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar(
        title: title,
        subtitle: peer.name,
        showBackButton: true,
      ),
      body: SafeArea(
        top: false,
        child: posts.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final peerCat = (peer.level4Category != null &&
                          peer.level4Category!.isNotEmpty)
                      ? peer.level4Category!
                      : peer.circle;
                  return PeerPostCard(
                    post: posts[index],
                    peerName: peer.name,
                    peerAvatarUrl: peer.avatarUrl,
                    peerDesignation: peer.designation,
                    peerCompany: peer.company,
                    peerCategory: peerCat,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    IconData icon;
    if (postTypeFilter == 'collaboration') {
      icon = Icons.connect_without_contact_rounded;
    } else if (postTypeFilter == 'requirement') {
      icon = Icons.assignment_outlined;
    } else {
      icon = Icons.volunteer_activism_rounded;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No $title recorded yet',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'When ${peer.name} records $title activities, they will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
