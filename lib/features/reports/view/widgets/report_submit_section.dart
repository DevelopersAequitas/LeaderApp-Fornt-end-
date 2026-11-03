import 'package:flutter/material.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/helpers/session_manager.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/report_model.dart';

/// Form component for leaders to draft and submit weekly/monthly/quarterly circle reports.
/// Provides rich multi-option selectors for:
/// - All Peers vs Specific Peers (with search and Select All / Manual Select)
/// - All Activities vs Specific Activities (with Select All / Manual Select)
/// - Peer with Activities detailed breakdown table preview
/// - Upward routing to higher leadership tiers up to Super Admin
class ReportSubmitSection extends StatefulWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final String circleName;
  final List<String> availableCircles;
  final ValueChanged<String>? onCircleChanged;
  final TextEditingController periodController;
  final TextEditingController attendanceController;
  final TextEditingController dealsClosedController;
  final TextEditingController totalRevenueController;
  final TextEditingController contentController;
  final TextEditingController highlightsController;
  final TextEditingController challengesController;
  final TextEditingController actionItemsController;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  // New Scope Options & Callbacks
  final String peersScopeMode;
  final ValueChanged<String> onPeersScopeModeChanged;
  final List<ReportPeerRosterItem> availableCirclePeers;
  final Set<String> selectedPeerIds;
  final ValueChanged<bool> onSelectAllPeers;
  final ValueChanged<String> onToggleSelectPeer;
  final bool isLoadingPeers;

  final String activitiesScopeMode;
  final ValueChanged<String> onActivitiesScopeModeChanged;
  final Set<String> selectedActivityKeys;
  final ValueChanged<bool> onSelectAllActivities;
  final ValueChanged<String> onToggleSelectActivity;

  final bool includePeerWithActivities;
  final ValueChanged<bool> onToggleIncludePeerWithActivities;

  const ReportSubmitSection({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.circleName,
    this.availableCircles = const [],
    this.onCircleChanged,
    required this.periodController,
    required this.attendanceController,
    required this.dealsClosedController,
    required this.totalRevenueController,
    required this.contentController,
    required this.highlightsController,
    required this.challengesController,
    required this.actionItemsController,
    required this.isSubmitting,
    required this.onSubmit,
    this.peersScopeMode = 'all',
    required this.onPeersScopeModeChanged,
    this.availableCirclePeers = const [],
    this.selectedPeerIds = const {},
    required this.onSelectAllPeers,
    required this.onToggleSelectPeer,
    this.isLoadingPeers = false,
    this.activitiesScopeMode = 'all',
    required this.onActivitiesScopeModeChanged,
    this.selectedActivityKeys = const {
      'p2p_meetings',
      'referrals',
      'deals_closed',
      'testimonials',
      'visitor_registrations',
      'attendance',
    },
    required this.onSelectAllActivities,
    required this.onToggleSelectActivity,
    this.includePeerWithActivities = true,
    required this.onToggleIncludePeerWithActivities,
  });

  @override
  State<ReportSubmitSection> createState() => _ReportSubmitSectionState();
}

class _ReportSubmitSectionState extends State<ReportSubmitSection> {
  String _peerSearchQuery = '';

  static const List<Map<String, dynamic>> _activityDefs = [
    {
      'key': 'p2p_meetings',
      'label': 'P2P Meetings',
      'icon': Icons.handshake_rounded,
      'color': Color(0xFF2563EB),
    },
    {
      'key': 'referrals',
      'label': 'Business Referrals',
      'icon': Icons.swap_horiz_rounded,
      'color': Color(0xFF7C3AED),
    },
    {
      'key': 'deals_closed',
      'label': 'Deals Closed & Revenue',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF059669),
    },
    {
      'key': 'testimonials',
      'label': 'Endorsements & Testimonials',
      'icon': Icons.verified_rounded,
      'color': Color(0xFFD97706),
    },
    {
      'key': 'visitor_registrations',
      'label': 'Visitor Registrations',
      'icon': Icons.person_add_alt_1_rounded,
      'color': Color(0xFF0891B2),
    },
    {
      'key': 'attendance',
      'label': 'Meeting Attendance',
      'icon': Icons.event_available_rounded,
      'color': Color(0xFFE11D48),
    },
  ];

  String _getUpperRecipientLabel() {
    final role = SessionManager().currentRole;
    switch (role) {
      case UserRole.chairBusinessGrowth:
      case UserRole.chairMembership:
      case UserRole.chairEvents:
      case UserRole.circleChair:
        return 'To: Circle Founder ➔ Circle Director ➔ District Executive Director ➔ Super Admin';
      case UserRole.circleFounder:
      case UserRole.circleDirector:
        return 'To: Industry Director ➔ District Executive Director ➔ Super Admin';
      case UserRole.industryDirector:
        return 'To: District Executive Director ➔ Country Director ➔ Super Admin';
      case UserRole.districtExecDirector:
        return 'To: Country Director ➔ Super Admin';
      case UserRole.countryDirector:
        return 'To: Super Admin & National Council';
      case UserRole.superAdmin:
        return 'Global Executive Submission ➔ Platform-wide Records';
    }
  }

  void _showCirclePicker(BuildContext context) {
    if (widget.availableCircles.isEmpty && widget.circleName.isEmpty) return;

    final circles = widget.availableCircles.isNotEmpty
        ? widget.availableCircles
        : (widget.circleName.isNotEmpty ? [widget.circleName] : <String>[]);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered = circles
                .where((c) => c.toLowerCase().contains(query.toLowerCase()))
                .toList();

            return Material(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.65,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Text(
                            'Select Circle for Report',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.text,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${circles.length} Available',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (val) => setSheetState(() => query = val),
                        decoration: InputDecoration(
                          hintText: 'Search circle name...',
                          hintStyle: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No matching circles found.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final item = filtered[idx];
                                final isSelected =
                                    item.toLowerCase() == widget.circleName.toLowerCase();
                                return ListTile(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    widget.onCircleChanged?.call(item);
                                  },
                                  leading: const SquareRoundedGradientIcon(
                                    icon: Icons.group_work_rounded,
                                    iconSize: 18,
                                    boxSize: 36,
                                    showBorder: true,
                                  ),
                                  title: Text(
                                    item,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.w500
                                          : FontWeight.w400,
                                      fontSize: 13,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.text,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? const Icon(
                                          Icons.check_circle_rounded,
                                          color: Color(0xFF16A34A),
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.chevron_right_rounded,
                                          color: AppColors.textSecondary,
                                          size: 20,
                                        ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Banner with Hierarchy Upward Routing
          _buildHeader(),
          const SizedBox(height: 12),

          // 2. Report Type Selector Pills
          _buildTypeSelector(),
          const SizedBox(height: 14),

          // 3. Circle Field with Interactive Picker
          _buildCircleField(context),
          const SizedBox(height: 14),

          // 4. Period & Attendance Row
          _buildPeriodAndAttendanceRow(),
          const SizedBox(height: 14),

          // 5. Deals & Revenue Row
          _buildFinancialsRow(),
          const SizedBox(height: 16),

          // 6. Peers Scope & Manual Selector Card
          _buildPeersScopeSection(),
          const SizedBox(height: 16),

          // 7. Activity Types Scope & Selector Card
          _buildActivitiesScopeSection(),
          const SizedBox(height: 16),

          // 8. Peer with Activities Breakdown Preview
          _buildPeerWithActivitiesSection(),
          const SizedBox(height: 16),

          // 9. Executive Summary & Notes (Required)
          _buildField(
            title: 'EXECUTIVE SUMMARY & NOTES *',
            controller: widget.contentController,
            maxLines: 4,
          ),
          const SizedBox(height: 14),

          // 10. Key Highlights & Wins
          _buildField(
            title: 'KEY HIGHLIGHTS & WINS',
            controller: widget.highlightsController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),

          // 11. Challenges Faced
          _buildField(
            title: 'CHALLENGES FACED & ROADBLOCKS',
            controller: widget.challengesController,
            maxLines: 2,
          ),
          const SizedBox(height: 14),

          // 12. Action Items
          _buildField(
            title: 'ACTION ITEMS & NEXT STEPS',
            controller: widget.actionItemsController,
            maxLines: 2,
          ),
          const SizedBox(height: 18),

          // 13. Submit Button
          _buildSubmitButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const SquareRoundedGradientIcon(
            icon: Icons.description_outlined,
            iconSize: 20,
            boxSize: 40,
            showBorder: true,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Submit Leadership Performance Report',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _getUpperRecipientLabel(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector() {
    const types = ['Weekly', 'Monthly', 'Quarterly', 'Annual'];

    return Row(
      children: types.map((type) {
        final isSelected = widget.selectedType.toLowerCase() == type.toLowerCase();
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            child: InkWell(
              onTap: () => widget.onTypeChanged(type),
              borderRadius: BorderRadius.circular(10),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppColors.brandGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.border,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.24),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCircleField(BuildContext context) {
    final displayName = widget.circleName.isNotEmpty ? widget.circleName : 'Select Circle';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'REPORT CIRCLE TARGET *',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: () => _showCirclePicker(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.group_work_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: widget.circleName.isNotEmpty ? AppColors.text : AppColors.textSecondary,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodAndAttendanceRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: _buildField(
            title: 'PERIOD (E.G. SEP 2026) *',
            controller: widget.periodController,
            hintText: 'e.g. September 2026',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: _buildField(
            title: 'ATTENDANCE %',
            controller: widget.attendanceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: 'e.g. 94.5',
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildField(
            title: 'DEALS CLOSED VALUE',
            controller: widget.dealsClosedController,
            hintText: 'e.g. ₹18.5L',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildField(
            title: 'TOTAL REVENUE VALUE',
            controller: widget.totalRevenueController,
            hintText: 'e.g. ₹24.0L',
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // Control A: Peers Scope & Manual Selector
  // =========================================================================
  Widget _buildPeersScopeSection() {
    final isSpecific = widget.peersScopeMode == 'specific';
    final totalPeers = widget.availableCirclePeers.length;
    final selectedCount = widget.selectedPeerIds.length;
    final allSelected = totalPeers > 0 && selectedCount >= totalPeers;

    final filteredPeers = widget.availableCirclePeers.where((p) {
      if (_peerSearchQuery.isEmpty) return true;
      final q = _peerSearchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.company.toLowerCase().contains(q);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'PEER ROSTER SCOPE',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSpecific ? '$selectedCount / $totalPeers selected' : 'All $totalPeers peers',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scope Mode Toggle Pills
          Row(
            children: [
              Expanded(
                child: _buildScopeOptionPill(
                  title: 'All Peers ($totalPeers)',
                  icon: Icons.groups_rounded,
                  isSelected: !isSpecific,
                  onTap: () => widget.onPeersScopeModeChanged('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScopeOptionPill(
                  title: 'Specific Peers',
                  icon: Icons.how_to_reg_rounded,
                  isSelected: isSpecific,
                  onTap: () => widget.onPeersScopeModeChanged('specific'),
                ),
              ),
            ],
          ),

          // If Specific Peers is active: show search + select all + peer checklist
          if (isSpecific) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => setState(() => _peerSearchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Search peers by name or company...',
                      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search_rounded, size: 16, color: AppColors.textSecondary),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => widget.onSelectAllPeers(!allSelected),
                  icon: Icon(
                    allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                    size: 16,
                  ),
                  label: Text(
                    allSelected ? 'Clear All' : 'Select All',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (widget.isLoadingPeers)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else if (filteredPeers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _peerSearchQuery.isNotEmpty
                      ? 'No peers matching "$_peerSearchQuery"'
                      : 'No peers found in this circle.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              )
            else
              Container(
                constraints: const BoxConstraints(maxHeight: 240),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(6),
                  itemCount: filteredPeers.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, idx) {
                    final peer = filteredPeers[idx];
                    final isChecked = widget.selectedPeerIds.contains(peer.peerId);

                    return InkWell(
                      onTap: () => widget.onToggleSelectPeer(peer.peerId),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (_) => widget.onToggleSelectPeer(peer.peerId),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            const SizedBox(width: 6),
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                              backgroundImage: peer.avatarUrl != null && peer.avatarUrl!.isNotEmpty
                                  ? NetworkImage(peer.avatarUrl!)
                                  : null,
                              child: peer.avatarUrl == null || peer.avatarUrl!.isEmpty
                                  ? Text(
                                      peer.name.isNotEmpty ? peer.name[0].toUpperCase() : 'P',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    peer.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                                      color: isChecked ? AppColors.text : AppColors.textSecondary,
                                    ),
                                  ),
                                  if (peer.company.isNotEmpty)
                                    Text(
                                      peer.company,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Mini Activity indicators
                            Text(
                              'P2P: ${peer.p2pCount}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Ref: ${peer.referralsCount}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // Control B: Activity Types Scope & Selector
  // =========================================================================
  Widget _buildActivitiesScopeSection() {
    final isSpecific = widget.activitiesScopeMode == 'specific';
    final selectedCount = widget.selectedActivityKeys.length;
    final allSelected = selectedCount >= _activityDefs.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 18, color: Color(0xFFE11D48)),
              const SizedBox(width: 8),
              const Text(
                'REPORT ACTIVITY INCLUSION',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isSpecific ? '$selectedCount / ${_activityDefs.length} types' : 'All 6 Activities',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Scope Mode Toggle Pills
          Row(
            children: [
              Expanded(
                child: _buildScopeOptionPill(
                  title: 'All Activities (6)',
                  icon: Icons.auto_awesome_rounded,
                  isSelected: !isSpecific,
                  onTap: () => widget.onActivitiesScopeModeChanged('all'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScopeOptionPill(
                  title: 'Specific Activities',
                  icon: Icons.checklist_rounded,
                  isSelected: isSpecific,
                  onTap: () => widget.onActivitiesScopeModeChanged('specific'),
                ),
              ),
            ],
          ),

          // If Specific Activities is active: show select all + activity grid
          if (isSpecific) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$selectedCount activities selected for inclusion',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
                TextButton.icon(
                  onPressed: () => widget.onSelectAllActivities(!allSelected),
                  icon: Icon(
                    allSelected ? Icons.deselect_rounded : Icons.select_all_rounded,
                    size: 16,
                  ),
                  label: Text(
                    allSelected ? 'Clear All' : 'Select All',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _activityDefs.map((act) {
                final key = act['key'] as String;
                final label = act['label'] as String;
                final icon = act['icon'] as IconData;
                final color = act['color'] as Color;
                final isChecked = widget.selectedActivityKeys.contains(key);

                return InkWell(
                  onTap: () => widget.onToggleSelectActivity(key),
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isChecked ? color.withValues(alpha: 0.08) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isChecked ? color : AppColors.border,
                        width: isChecked ? 1.2 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, size: 16, color: isChecked ? color : AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isChecked ? FontWeight.w600 : FontWeight.w400,
                            color: isChecked ? color : AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isChecked ? Icons.check_circle_rounded : Icons.circle_outlined,
                          size: 15,
                          color: isChecked ? color : AppColors.textSecondary.withValues(alpha: 0.6),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // =========================================================================
  // Control C: Peer with Activities Breakdown Preview Table
  // =========================================================================
  Widget _buildPeerWithActivitiesSection() {
    final effectivePeers = widget.peersScopeMode == 'specific'
        ? widget.availableCirclePeers.where((p) => widget.selectedPeerIds.contains(p.peerId)).toList()
        : widget.availableCirclePeers;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.table_chart_rounded, size: 18, color: Color(0xFF7C3AED)),
              const SizedBox(width: 8),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PEER WITH ACTIVITIES BREAKDOWN',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                        letterSpacing: 0.4,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Cross-references each peer with their individual activity metrics in this report',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: widget.includePeerWithActivities,
                onChanged: widget.onToggleIncludePeerWithActivities,
                activeThumbColor: const Color(0xFF7C3AED),
              ),
            ],
          ),

          if (widget.includePeerWithActivities) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Roster matrix will be attached for ${effectivePeers.length} peers.',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Live Preview Table
            if (effectivePeers.isNotEmpty)
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      headingRowHeight: 34,
                      dataRowMinHeight: 32,
                      dataRowMaxHeight: 38,
                      horizontalMargin: 10,
                      columnSpacing: 16,
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Peer',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'P2P',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Referrals',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Deals',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Att.',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                      rows: effectivePeers.take(20).map((p) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                p.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                              ),
                            ),
                            DataCell(
                              Text('${p.p2pCount}', style: const TextStyle(fontSize: 11)),
                            ),
                            DataCell(
                              Text('${p.referralsCount}', style: const TextStyle(fontSize: 11)),
                            ),
                            DataCell(
                              Text(
                                p.dealsClosed.isNotEmpty ? p.dealsClosed : '₹0',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                            DataCell(
                              Text(p.attendance, style: const TextStyle(fontSize: 11)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeOptionPill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.10) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String title,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return PrimaryButton(
      label: 'Submit Report for Leadership Review →',
      isLoading: widget.isSubmitting,
      leadingIcon: Icons.send_rounded,
      onPressed: widget.onSubmit,
    );
  }
}
