import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
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
    if (rawDate.isEmpty || rawDate == 'null') {
      return 'N/A';
    }
    try {
      final parsed = DateTime.tryParse(rawDate);
      if (parsed != null) {
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
        final day = parsed.day.toString().padLeft(2, '0');
        final monthStr = monthNames[(parsed.month - 1).clamp(0, 11)];
        return '$day $monthStr ${parsed.year}';
      }
      final clean = rawDate.split('T').first;
      final parts = clean.split('-');
      if (parts.length == 3) {
        final year = parts[0];
        final monthInt = int.tryParse(parts[1]) ?? 1;
        final day = parts[2].padLeft(2, '0');
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
        return '$day $monthStr $year';
      }
      return clean;
    } catch (_) {
      return rawDate;
    }
  }

  String _formatPrice(dynamic rawPrice) {
    if (rawPrice == null) return '₹0';
    final str =
        rawPrice.toString().replaceAll('₹', '').replaceAll(',', '').trim();
    if (str.isEmpty || str == 'null') return '₹0';
    final numVal = num.tryParse(str);
    if (numVal != null) {
      if (numVal == numVal.toInt()) {
        final intVal = numVal.toInt();
        final formatted = intVal.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            );
        return '₹$formatted';
      }
      return '₹${numVal.toStringAsFixed(2)}';
    }
    return rawPrice.toString().startsWith('₹')
        ? rawPrice.toString()
        : '₹$rawPrice';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return const Color(0xFF16A34A);
      case 'pending':
        return const Color(0xFFEAB308);
      case 'expired':
      case 'cancelled':
      case 'inactive':
        return const Color(0xFFDC2626);
      default:
        return AppColors.text;
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
                    gradient: AppColors.brandGradient,
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
                          Icon(Icons.devices_rounded, size: 16),
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

  /// App Membership Tab - displays only the subscription details card as requested
  Widget _buildAppMembershipTab(BuildContext context) {
    final appSub = details.appSubscription;
    final planPrice = _formatPrice(appSub?.price);
    final status = (appSub?.status ?? 'active').toUpperCase();
    final startDateText = _formatDate(appSub?.startDate ?? '');
    final endDateText = _formatDate(appSub?.endDate ?? '');
    final daysLeftText = '${appSub?.daysLeft ?? 0} Days';
    final statusColor = _getStatusColor(appSub?.status ?? 'active');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SUBSCRIPTION DETAILS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Membership Status',
                  value: status,
                  valueColor: statusColor,
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

  /// Circle Membership Tab - displays only the circle subscription details card as requested
  Widget _buildCircleMembershipTab(BuildContext context) {
    final circleSub = details.circleSubscription;
    final planPrice = _formatPrice(circleSub?.amount);
    final status = (circleSub?.status ?? 'pending').toUpperCase();
    final startDateText = _formatDate(circleSub?.startDate ?? '');
    final endDateText = _formatDate(circleSub?.endDate ?? '');
    final daysLeftText = '${circleSub?.daysLeft ?? 0} Days';
    final statusColor = _getStatusColor(circleSub?.status ?? 'pending');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'SUBSCRIPTION DETAILS',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDetailRow(
                  icon: Icons.check_circle_outline_rounded,
                  label: 'Membership Status',
                  value: status,
                  valueColor: statusColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.brandGradient.createShader(bounds),
            child: Icon(icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor ?? AppColors.text,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
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
      color: Color(0xFFF1F5F9),
      indent: 16,
      endIndent: 16,
    );
  }
}
