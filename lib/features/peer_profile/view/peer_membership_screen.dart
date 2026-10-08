import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../peers/model/peer_model.dart';
import '../model/peer_profile_model.dart';

/// Full-screen display showing App Subscription & Circle Subscription details for a peer.
class PeerMembershipScreen extends StatelessWidget {
  final PeerModel peer;
  final PeerProfileDetailModel details;

  const PeerMembershipScreen({
    super.key,
    required this.peer,
    required this.details,
  });

  String _formatDate(String rawDate) {
    if (rawDate.isEmpty) {
      return 'N/A';
    }
    try {
      final clean = rawDate.split('T').first;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.tryParse(parts[1]) ?? 1;
        final day = parts[2];
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final monthStr = monthNames[(monthInt - 1).clamp(0, 11)];
        return '$monthStr $day, $year';
      }
      return clean;
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(
          title: 'Membership Details',
          showBackButton: true,
          backgroundColor: Colors.white,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    gradient: AppColor.brandGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_membership_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('App Membership'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.groups_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Circle Membership'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildAppMembershipTab(context),
                    _buildCircleMembershipTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// App Membership Tab
  Widget _buildAppMembershipTab(BuildContext context) {
    final appSub = details.appSubscription;
    final planName = (appSub?.planName ?? '').isNotEmpty
        ? appSub!.planName
        : 'App Pro Plan';
    final planPrice = (appSub?.price ?? '').isNotEmpty
        ? appSub!.price
        : '₹0';
    final status = (appSub?.status ?? 'active').toUpperCase();
    final startDateText = _formatDate(appSub?.startDate ?? '');
    final endDateText = _formatDate(appSub?.endDate ?? '');
    final daysLeftText = '${appSub?.daysLeft ?? 0} Days';
    final isActive = (appSub?.status ?? 'active').toLowerCase() == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. App Plan Highlight Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColor.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x221D4ED8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              planName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEAB308),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Price: $planPrice',
                        style: const TextStyle(
                          color: Color(0xE6FFFFFF),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Details Grid List
          const Text(
            'SUBSCRIPTION DETAILS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Membership Status',
                  value: status,
                  valueColor: isActive ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.sell_outlined,
                  label: 'Plan Price',
                  value: planPrice,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Days Left',
                  value: daysLeftText,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Subscription Start Date',
                  value: startDateText,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.event_available_rounded,
                  label: 'Subscription End Date',
                  value: endDateText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Circle Membership Tab
  Widget _buildCircleMembershipTab(BuildContext context) {
    final circleSub = details.circleSubscription;
    final circleName = (circleSub?.circleName ?? '').isNotEmpty
        ? circleSub!.circleName
        : (peer.circle.isNotEmpty ? peer.circle : 'Peers Circle');
    final planPrice = (circleSub?.amount ?? '').isNotEmpty
        ? circleSub!.amount
        : '₹1';
    final status = (circleSub?.status ?? 'pending').toUpperCase();
    final startDateText = _formatDate(circleSub?.startDate ?? '');
    final endDateText = _formatDate(circleSub?.endDate ?? '');
    final daysLeftText = '${circleSub?.daysLeft ?? 0} Days';
    final isActive = (circleSub?.status ?? 'pending').toLowerCase() == 'active';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Circle Banner Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColor.brandGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x221D4ED8),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.diversity_3_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              circleName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFEAB308),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. Details Grid List
          const Text(
            'CIRCLE SUBSCRIPTION DETAILS',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Membership Status',
                  value: status,
                  valueColor: isActive ? const Color(0xFF16A34A) : const Color(0xFFEAB308),
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.sell_outlined,
                  label: 'Plan Price',
                  value: planPrice,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.hourglass_top_rounded,
                  label: 'Days Left',
                  value: daysLeftText,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Subscription Start Date',
                  value: startDateText,
                ),
                _buildDivider(),
                _buildDetailRow(
                  icon: Icons.event_available_rounded,
                  label: 'Subscription End Date',
                  value: endDateText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColor.brandGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 16,
      endIndent: 16,
    );
  }
}
