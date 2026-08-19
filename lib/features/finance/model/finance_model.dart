import 'package:flutter/widgets.dart';

/// Model representing user permissions status and credentials for Finance.
class FinancePermissionModel {
  final String role;
  final bool isRestricted;
  final List<String> requiredCapabilities;

  const FinancePermissionModel({
    required this.role,
    required this.isRestricted,
    required this.requiredCapabilities,
  });
}

/// Model representing monthly trend coordinates for custom charts.
class FinanceChartPoint {
  final String month;
  final double value;

  const FinanceChartPoint({required this.month, required this.value});
}

/// Model representing a personal commission rate cut card.
class CommissionRateModel {
  final String label;
  final String rate;
  final String description;
  final String status;

  const CommissionRateModel({
    required this.label,
    required this.rate,
    required this.description,
    required this.status,
  });
}

/// Model representing a single row in the read-only commission structure table.
class CommissionStructureItemModel {
  final String role;
  final String directReferralCut;
  final String appJoinCut;
  final IconData icon;

  const CommissionStructureItemModel({
    required this.role,
    required this.directReferralCut,
    required this.appJoinCut,
    required this.icon,
  });
}

/// Model representing metrics and chart datasets for Finance dashboard.
class FinanceMetricsModel {
  final String totalRevenue;
  final String circleRevenue;
  final int dealsClosed;
  final String commissionDue;
  final List<FinanceChartPoint> revenueTrend;
  final List<FinanceChartPoint> businessDeals;
  final List<CommissionRateModel> commissionRates;
  final List<CommissionStructureItemModel> commissionStructure;

  const FinanceMetricsModel({
    required this.totalRevenue,
    required this.circleRevenue,
    required this.dealsClosed,
    required this.commissionDue,
    required this.revenueTrend,
    required this.businessDeals,
    required this.commissionRates,
    required this.commissionStructure,
  });
}
