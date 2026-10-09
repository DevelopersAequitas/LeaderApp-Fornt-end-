import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../model/peer_profile_model.dart';

/// Card widget rendering a user post matching the feed design layout.
class PeerPostCard extends StatelessWidget {
  final PeerPostModel post;
  final String? peerName;
  final String? peerAvatarUrl;
  final String? peerDesignation;
  final String? peerCompany;
  final String? peerCategory;
  final VoidCallback? onDelete;

  const PeerPostCard({
    super.key,
    required this.post,
    this.peerName,
    this.peerAvatarUrl,
    this.peerDesignation,
    this.peerCompany,
    this.peerCategory,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = post.authorName.isNotEmpty
        ? post.authorName.toUpperCase()
        : (peerName != null && peerName!.isNotEmpty ? peerName!.toUpperCase() : 'PEER MEMBER');

    final displayAvatar = post.authorAvatarUrl.isNotEmpty
        ? post.authorAvatarUrl
        : (peerAvatarUrl ?? '');

    final displayDesignationCompany = post.designationCompany.isNotEmpty
        ? post.designationCompany
        : [
            if (peerDesignation != null && peerDesignation!.isNotEmpty) peerDesignation!,
            if (peerCompany != null && peerCompany!.isNotEmpty) peerCompany!,
          ].join(' · ');

    final displayCategory = post.level4Category.isNotEmpty
        ? post.level4Category
        : (peerCategory ?? '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header (Date & Actions)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  post.createdAt.isNotEmpty ? post.createdAt : 'Recent',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz, color: Colors.grey.shade600, size: 20),
                  onPressed: onDelete,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Author Profile Info Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: displayAvatar.isNotEmpty ? NetworkImage(displayAvatar) : null,
                  child: displayAvatar.isEmpty
                      ? Text(
                          displayName.isNotEmpty ? displayName[0] : 'P',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),

                // Name & Subtitle Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Verified Badge
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.isVerified) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified,
                              size: 15,
                              color: Color(0xFF9333EA),
                            ),
                            const SizedBox(width: 3),
                            const Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9333EA),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),

                      // Designation · Company
                      if (displayDesignationCompany.isNotEmpty)
                        Text(
                          displayDesignationCompany,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                      // Level 4 Category Tag
                      if (displayCategory.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          displayCategory,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7C3AED),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // 3. Post Content Text
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF334155),
                  height: 1.4,
                ),
              ),
            ),

          // Post Title / Sub-type if available
          if (post.title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],

          // 4. Attached Image (if available)
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  post.imageUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // 5. Action Icons Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                // Like Heart
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 22,
                          color: post.isLiked ? Colors.red : Colors.grey.shade600,
                        ),
                        if (post.likesCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${post.likesCount}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Comment Bubble
                InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 21,
                          color: Colors.grey.shade600,
                        ),
                        if (post.commentsCount > 0) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const Spacer(),

                // Bookmark Icon
                IconButton(
                  icon: Icon(Icons.bookmark_border, size: 22, color: Colors.grey.shade600),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 18),

                // Share Icon
                IconButton(
                  icon: Icon(Icons.share_outlined, size: 21, color: Colors.grey.shade600),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
