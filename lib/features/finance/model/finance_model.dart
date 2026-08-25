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

  factory FinanceChartPoint.fromJson(Map<String, dynamic> json) {
    return FinanceChartPoint(
      month: json['month']?.toString() ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }
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

/// Model representing a financial transaction or fee due.
class FinanceTransactionModel {
  final String id;
  final String peerName;
  final String circleName;
  final String amount;
  final String type;
  final String status; // "Paid", "Pending", "Overdue"
  final String date;

  const FinanceTransactionModel({
    required this.id,
    required this.peerName,
    required this.circleName,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
  });

  factory FinanceTransactionModel.fromJson(Map<String, dynamic> json) {
    return FinanceTransactionModel(
      id: json['id']?.toString() ?? '',
      peerName: json['peer_name'] as String? ?? 'Peer',
      circleName: json['circle_name'] as String? ?? json['circle'] as String? ?? '',
      amount: json['amount']?.toString() ?? '₹0',
      type: json['type'] as String? ?? 'Fee',
      status: json['status'] as String? ?? 'Paid',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'peer_name': peerName,
        'circle_name': circleName,
        'amount': amount,
        'type': type,
        'status': status,
        'date': date,
      };
}

/// Model representing metrics and chart datasets for Finance dashboard.
class FinanceMetricsModel {
  final String totalRevenue;
  final String circleRevenue;
  final int dealsClosed;
  final String commissionDue;
  final String? totalCollections;
  final String? totalDues;
  final int? coinIssuancesTotal;
  final List<FinanceChartPoint> revenueTrend;
  final List<FinanceChartPoint> businessDeals;
  final List<CommissionRateModel> commissionRates;
  final List<CommissionStructureItemModel> commissionStructure;

  const FinanceMetricsModel({
    required this.totalRevenue,
    required this.circleRevenue,
    required this.dealsClosed,
    required this.commissionDue,
    this.totalCollections,
    this.totalDues,
    this.coinIssuancesTotal,
    required this.revenueTrend,
    required this.businessDeals,
    required this.commissionRates,
    required this.commissionStructure,
  });

  factory FinanceMetricsModel.fromJson(Map<String, dynamic> json) {
    final revList = <FinanceChartPoint>[];
    if (json['revenue_trend'] is List) {
      for (final item in json['revenue_trend']) {
        if (item is Map<String, dynamic>) {
          revList.add(FinanceChartPoint.fromJson(item));
        }
      }
    }

    final dealsList = <FinanceChartPoint>[];
    if (json['business_deals'] is List) {
      for (final item in json['business_deals']) {
        if (item is Map<String, dynamic>) {
          dealsList.add(FinanceChartPoint.fromJson(item));
        }
      }
    }

    return FinanceMetricsModel(
      totalRevenue: json['projected_annual_revenue']?.toString() ?? json['total_revenue']?.toString() ?? '₹0.0',
      circleRevenue: json['total_collections']?.toString() ?? json['circle_revenue']?.toString() ?? '₹0.0',
      dealsClosed: json['deals_closed'] as int? ?? 0,
      commissionDue: json['total_dues']?.toString() ?? json['commission_due']?.toString() ?? '₹0.0',
      totalCollections: json['total_collections']?.toString() ?? '₹0.0',
      totalDues: json['total_dues']?.toString() ?? '₹0.0',
      coinIssuancesTotal: json['coin_issuances_total'] as int? ?? 0,
      revenueTrend: revList,
      businessDeals: dealsList,
      commissionRates: const [],
      commissionStructure: const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'total_revenue': totalRevenue,
        'circle_revenue': circleRevenue,
        'deals_closed': dealsClosed,
        'commission_due': commissionDue,
        'total_collections': totalCollections,
        'total_dues': totalDues,
        'coin_issuances_total': coinIssuancesTotal,
      };
}
