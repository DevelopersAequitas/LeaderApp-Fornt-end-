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

/// Model representing a single row in the read-only or editable commission structure table.
class CommissionStructureItemModel {
  final String role;
  final String? roleId;
  final String directReferralCut;
  final String appJoinCut;
  final String? renewalCut;
  final IconData icon;

  const CommissionStructureItemModel({
    required this.role,
    this.roleId,
    required this.directReferralCut,
    required this.appJoinCut,
    this.renewalCut,
    required this.icon,
  });

  factory CommissionStructureItemModel.fromJson(Map<String, dynamic> json) {
    final roleName = json['role']?.toString() ?? json['role_name']?.toString() ?? '';
    final roleId = json['role_id']?.toString() ?? _inferRoleId(roleName);

    return CommissionStructureItemModel(
      role: roleName,
      roleId: roleId,
      directReferralCut: json['direct_referral_cut']?.toString() ?? '0%',
      appJoinCut: json['app_join_cut']?.toString() ?? '0%',
      renewalCut: json['renewal_cut']?.toString(),
      icon: _getRoleIcon(roleName),
    );
  }

  static String _inferRoleId(String role) {
    final r = role.toLowerCase().replaceAll(' ', '').replaceAll('_', '');
    if (r.contains('founder')) return 'circleFounder';
    if (r.contains('chair')) return 'circleChair';
    if (r.contains('director')) return 'countryDirector';
    if (r.contains('admin')) return 'superAdmin';
    return role;
  }

  static IconData _getRoleIcon(String role) {
    final r = role.toLowerCase();
    if (r.contains('founder')) return const IconData(0xe5f9, fontFamily: 'MaterialIcons'); // star
    if (r.contains('chair')) return const IconData(0xe165, fontFamily: 'MaterialIcons'); // chair
    if (r.contains('director')) return const IconData(0xe11b, fontFamily: 'MaterialIcons'); // business_center
    if (r.contains('admin')) return const IconData(0xe08f, fontFamily: 'MaterialIcons'); // admin_panel_settings
    return const IconData(0xf0621, fontFamily: 'MaterialIcons'); // workspace_premium
  }
}

/// DTO for updating commission rates (Super Admin Only)
class UpdateCommissionRateDto {
  final String roleId;
  final String roleName;
  final double directReferralCutPercentage;
  final double appJoinCutPercentage;
  final double? renewalCutPercentage;

  const UpdateCommissionRateDto({
    required this.roleId,
    required this.roleName,
    required this.directReferralCutPercentage,
    required this.appJoinCutPercentage,
    this.renewalCutPercentage,
  });

  Map<String, dynamic> toJson() => {
        'role_id': roleId,
        'role_name': roleName,
        'direct_referral_cut_percentage': directReferralCutPercentage,
        'app_join_cut_percentage': appJoinCutPercentage,
        if (renewalCutPercentage != null)
          'renewal_cut_percentage': renewalCutPercentage,
      };
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

    final commRates = <CommissionRateModel>[];
    if (json['commission_rates'] is List) {
      for (final item in json['commission_rates']) {
        if (item is Map<String, dynamic>) {
          commRates.add(CommissionRateModel(
            label: item['label']?.toString() ?? '',
            rate: item['rate']?.toString() ?? '',
            description: item['description']?.toString() ?? '',
            status: item['status']?.toString() ?? 'Active',
          ));
        }
      }
    }

    final commStruct = <CommissionStructureItemModel>[];
    if (json['commission_structure'] is List) {
      for (final item in json['commission_structure']) {
        if (item is Map<String, dynamic>) {
          commStruct.add(CommissionStructureItemModel.fromJson(item));
        } else if (item is Map) {
          commStruct.add(
            CommissionStructureItemModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
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
      commissionRates: commRates,
      commissionStructure: commStruct,
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
