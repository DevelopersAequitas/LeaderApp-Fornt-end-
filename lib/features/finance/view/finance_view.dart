import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';
import '../model/finance_model.dart';
import '../presenter/finance_presenter.dart';

/// The View component of the Finance tab feature.
/// Displays an "Access Restricted" lock card over a blurred mock dashboard background.
class FinanceView extends StatefulWidget {
  final String? selectedCircle;
  const FinanceView({super.key, this.selectedCircle});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView>
    implements FinanceViewContract {
  late final FinanceBloc _bloc;
  late final FinancePresenter _presenter;

  bool _isLoading = false;
  FinancePermissionModel? _permission;
  FinanceMetricsModel? _metrics;

  @override
  void initState() {
    super.initState();
    _bloc = FinanceBloc();
    _presenter = FinancePresenter(view: this, bloc: _bloc);
    _presenter.load(selectedCircle: widget.selectedCircle);
  }

  @override
  void didUpdateWidget(covariant FinanceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCircle != oldWidget.selectedCircle) {
      _presenter.load(selectedCircle: widget.selectedCircle);
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- FinanceViewContract Implementations ---

  @override
  void onFinanceLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onFinanceLoaded() {
    setState(() {
      _isLoading = false;
      _permission = _bloc.state.permission;
      _metrics = _bloc.state.metrics;
    });
  }

  @override
  void onFinanceError(String error) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  // --- UI Widget Builders ---

  Widget _buildMockDashboardBackground() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: const Color(0xFFF9FAFC),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 18, width: 120, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          ...List.generate(
            3,
            (_) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictedCard(FinancePermissionModel permission) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            spreadRadius: 4,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF2F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFFE3E3), width: 1.5),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lock_outline_rounded,
                color: Color(0xFFD32F2F),
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Access Restricted',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: AppColors.text.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              children: const [
                TextSpan(text: 'As a '),
                TextSpan(
                  text: 'Chair',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                TextSpan(
                  text:
                      ', you do not have permissions to access the Finance dashboard. Access is limited to Founder, Director, and Executive levels.',
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'REQUIRED CAPABILITIES',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: permission.requiredCapabilities
                      .map(
                        (cap) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFFE1DDF6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            cap,
                            style: const TextStyle(
                              color: Colors.deepPurple,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              children: [
                const TextSpan(text: 'Logged in as: '),
                TextSpan(
                  text: permission.role,
                  style: const TextStyle(
                    color: Colors.indigo,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFounderFinanceView() {
    final hideCommissionRates =
        SessionManager().currentRole == UserRole.industryDirector ||
        SessionManager().currentRole == UserRole.countryDirector ||
        SessionManager().currentRole == UserRole.superAdmin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildMetricsGrid(),
        _buildRevenueTrendChart(),
        _buildBusinessDealsChart(),
        if (!hideCommissionRates) _buildCommissionRatesSection(),
        _buildCommissionStructureSection(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildCommissionRatesSection() {
    if (_metrics == null || _metrics!.commissionRates.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Commission Rates',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Your cut from joining fees',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: _metrics!.commissionRates.map((rate) {
              return Expanded(
                child: Container(
                  margin: _metrics!.commissionRates.first == rate
                      ? const EdgeInsets.only(right: 8.0)
                      : const EdgeInsets.only(left: 8.0),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFE8EEF8),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rate.label,
                        style: const TextStyle(
                          color: Color(0xFF8B9CB4),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rate.rate,
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rate.description,
                        style: const TextStyle(
                          color: Color(0xFF8B9CB4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rate.status,
                        style: const TextStyle(
                          color: Color(0xFFB58E3D),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionStructureSection() {
    if (_metrics == null || _metrics!.commissionStructure.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Commission Structure',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (SessionManager().currentRole != UserRole.superAdmin)
                Row(
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.grey.shade400,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Read-only',
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            'Joining fee cuts per leader level',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          // Table Header
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  'LEADER ROLE',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'DIRECT\nREFERRAL %',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'APP\nJOIN %',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Table Body Rows
          ..._metrics!.commissionStructure.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  // Role Name & Icon
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F5F9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            item.icon,
                            color: const Color(0xFF1E3A60),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.role,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Direct Referral Cut
                  Expanded(
                    flex: 2,
                    child: SessionManager().currentRole == UserRole.superAdmin
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 72,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE8EEF8)),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '0',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            item.directReferralCut,
                            style: const TextStyle(
                              color: Color(0xFF8B9CB4),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                  // App Join Cut
                  Expanded(
                    flex: 2,
                    child: SessionManager().currentRole == UserRole.superAdmin
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              width: 72,
                              height: 36,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F8FA),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFE8EEF8)),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '0',
                                style: TextStyle(
                                  color: AppColors.text,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Text(
                            item.appJoinCut,
                            style: const TextStyle(
                              color: Color(0xFF8B9CB4),
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    if (_metrics == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: _metrics!.totalRevenue,
                  label: 'Total Revenue',
                  valueColor: const Color(0xFF0F7A50),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  value: _metrics!.circleRevenue,
                  label: 'Circle Revenue',
                  valueColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  value: '${_metrics!.dealsClosed}',
                  label: 'Deals Closed',
                  valueColor: const Color(0xFFB58E3D),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMetricCard(
                  value: _metrics!.commissionDue,
                  label: 'Commission Due',
                  valueColor: const Color(0xFF102640),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF8B9CB4),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueTrendChart() {
    if (_metrics == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue Trend',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Monthly ₹k',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FinanceSplineChart(
            points: _metrics!.revenueTrend,
            minY: 0.0,
            maxY: 600.0,
            yLabels: const [0, 150, 300, 450, 600],
            lineColor: const Color(0xFF0F7A50),
            showMarTooltip: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessDealsChart() {
    if (_metrics == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDEFF3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Business Deals',
            style: TextStyle(
              color: AppColors.text,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Monthly ₹k',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          FinanceSplineChart(
            points: _metrics!.businessDeals,
            minY: 35.0,
            maxY: 140.0,
            yLabels: const [35, 70, 105, 140],
            lineColor: const Color(0xFFB58E3D),
            showMarTooltip: false,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceBloc>.value(
      value: _bloc,
      child: BlocListener<FinanceBloc, FinanceState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: _isLoading || _permission == null
            ? const SizedBox(
                height: 300,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            : _permission!.isRestricted
            ? SizedBox(
                height: 580,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        physics: const NeverScrollableScrollPhysics(),
                        child: _buildMockDashboardBackground(),
                      ),
                    ),
                    Positioned.fill(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                        child: Container(color: Colors.white.withOpacity(0.3)),
                      ),
                    ),
                    Center(
                      child: SingleChildScrollView(
                        child: _buildRestrictedCard(_permission!),
                      ),
                    ),
                  ],
                ),
              )
            : _buildFounderFinanceView(),
      ),
    );
  }
}

class FinanceSplineChart extends StatelessWidget {
  final List<FinanceChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;
  final bool showMarTooltip;

  const FinanceSplineChart({
    super.key,
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
    this.showMarTooltip = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 16, 24, 8),
      child: CustomPaint(
        painter: _SplineChartPainter(
          points: points,
          minY: minY,
          maxY: maxY,
          yLabels: yLabels,
          lineColor: lineColor,
          showMarTooltip: showMarTooltip,
        ),
      ),
    );
  }
}

class _SplineChartPainter extends CustomPainter {
  final List<FinanceChartPoint> points;
  final double minY;
  final double maxY;
  final List<double> yLabels;
  final Color lineColor;
  final bool showMarTooltip;

  _SplineChartPainter({
    required this.points,
    required this.minY,
    required this.maxY,
    required this.yLabels,
    required this.lineColor,
    required this.showMarTooltip,
  });

  void _drawDashedHorizontalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashWidth = 4.0;
    const double dashSpace = 4.0;
    double currentX = start.dx;
    while (currentX < end.dx) {
      canvas.drawLine(
        Offset(currentX, start.dy),
        Offset(
          currentX + dashWidth > end.dx ? end.dx : currentX + dashWidth,
          start.dy,
        ),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawDashedVerticalLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashHeight = 4.0;
    const double dashSpace = 4.0;
    double currentY = start.dy;
    while (currentY < end.dy) {
      canvas.drawLine(
        Offset(start.dx, currentY),
        Offset(
          start.dx,
          currentY + dashHeight > end.dy ? end.dy : currentY + dashHeight,
        ),
        paint,
      );
      currentY += dashHeight + dashSpace;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    const double leftPadding = 40.0;
    const double bottomPadding = 30.0;

    final double chartWidth = size.width - leftPadding;
    final double chartHeight = size.height - bottomPadding;

    final gridPaint = Paint()
      // Faint grey grid lines (slightly darker than before for visibility)
      ..color = const Color(0xFFE4E7ED)
      ..strokeWidth = 1.0;

    final baselinePaint = Paint()
      ..color = const Color(0xFFE4E7ED)
      ..strokeWidth = 1.5;

    // Draw vertical dashed grid lines for X axis coordinates
    final double xSegment = chartWidth / (points.length - 1);
    for (int i = 0; i < points.length; i++) {
      final x = leftPadding + (i * xSegment);
      _drawDashedVerticalLine(
        canvas,
        Offset(x, 0),
        Offset(x, chartHeight),
        gridPaint,
      );
    }

    // Draw horizontal dashed grid lines and Y-axis labels
    for (final label in yLabels) {
      final yRatio = (label - minY) / (maxY - minY);
      final yPos = chartHeight - (yRatio * chartHeight);

      _drawDashedHorizontalLine(
        canvas,
        Offset(leftPadding, yPos),
        Offset(size.width, yPos),
        gridPaint,
      );

      textPainter.text = TextSpan(
        text: '${label.toInt()}',
        style: const TextStyle(
          color: Color(0xFF8B9CB4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          leftPadding - textPainter.width - 12,
          yPos - textPainter.height / 2,
        ),
      );
    }

    // Draw solid horizontal baseline at the bottom of the chart
    canvas.drawLine(
      Offset(leftPadding, chartHeight),
      Offset(size.width, chartHeight),
      baselinePaint,
    );

    if (points.isEmpty) return;

    final List<Offset> pixelPoints = [];
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = leftPadding + (i * xSegment);
      final yRatio = (p.value - minY) / (maxY - minY);
      final y = chartHeight - (yRatio * chartHeight);
      pixelPoints.add(Offset(x, y));
    }

    // Natural flowing spline tangent calculation
    final int n = pixelPoints.length;
    final List<Offset> controlPoints1 = [];
    final List<Offset> controlPoints2 = [];
    const double factor = 0.20; // Natural curve smooth factor

    final List<Offset> tangents = List.filled(n, Offset.zero);
    for (int i = 0; i < n; i++) {
      if (i == 0) {
        tangents[i] = (pixelPoints[1] - pixelPoints[0]) * factor;
      } else if (i == n - 1) {
        tangents[i] = (pixelPoints[n - 1] - pixelPoints[n - 2]) * factor;
      } else {
        tangents[i] = (pixelPoints[i + 1] - pixelPoints[i - 1]) * factor;
      }
    }

    for (int i = 0; i < n - 1; i++) {
      controlPoints1.add(pixelPoints[i] + tangents[i]);
      controlPoints2.add(pixelPoints[i + 1] - tangents[i + 1]);
    }

    // 1. Gradient Fill Path under curve
    final fillPath = Path();
    fillPath.moveTo(pixelPoints[0].dx, chartHeight);
    fillPath.lineTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      fillPath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }
    fillPath.lineTo(pixelPoints.last.dx, chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.12),
          lineColor.withValues(alpha: 0.01),
        ],
      ).createShader(Rect.fromLTWH(leftPadding, 0, chartWidth, chartHeight));

    canvas.drawPath(fillPath, fillPaint);

    // 2. Line Path (natural curve)
    final linePath = Path();
    linePath.moveTo(pixelPoints[0].dx, pixelPoints[0].dy);

    for (int i = 0; i < n - 1; i++) {
      linePath.cubicTo(
        controlPoints1[i].dx,
        controlPoints1[i].dy,
        controlPoints2[i].dx,
        controlPoints2[i].dy,
        pixelPoints[i + 1].dx,
        pixelPoints[i + 1].dy,
      );
    }

    final linePaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(linePath, linePaint);

    // 3. Dots & X labels
    final dotPaint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.fill;

    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < points.length; i++) {
      final pt = pixelPoints[i];

      canvas.drawCircle(pt, 5.0, dotBorderPaint);
      canvas.drawCircle(pt, 3.5, dotPaint);

      textPainter.text = TextSpan(
        text: points[i].month,
        style: const TextStyle(
          color: Color(0xFF8B9CB4),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(pt.dx - textPainter.width / 2, chartHeight + 10),
      );
    }

    if (showMarTooltip && pixelPoints.length > 1) {
      final indicatorPaint = Paint()
        ..color = const Color(0xFFC0D1EB)
        ..strokeWidth = 1.0;
      canvas.drawLine(
        Offset(pixelPoints[1].dx, 0),
        Offset(pixelPoints[1].dx, chartHeight),
        indicatorPaint,
      );

      final highlightOuterPaint = Paint()
        ..color = lineColor.withOpacity(0.2)
        ..style = PaintingStyle.fill;
      final highlightInnerPaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pixelPoints[1], 8.0, highlightOuterPaint);
      canvas.drawCircle(pixelPoints[1], 4.5, highlightInnerPaint);

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(leftPadding + 10, 10, 64, 52),
        const Radius.circular(10),
      );
      final tooltipShadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawRRect(rect.shift(const Offset(0, 2)), tooltipShadowPaint);

      final tooltipBgPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      final tooltipBorderPaint = Paint()
        ..color = const Color(0xFFEDEFF3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      canvas.drawRRect(rect, tooltipBgPaint);
      canvas.drawRRect(rect, tooltipBorderPaint);

      // Text inside tooltip
      textPainter.text = const TextSpan(
        text: 'Mar',
        style: TextStyle(
          color: Color(0xFF8B9CB4),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding + 20, 18));

      textPainter.text = TextSpan(
        text: 'v : 240',
        style: TextStyle(
          color: lineColor,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding + 20, 32));
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) => true;
}
