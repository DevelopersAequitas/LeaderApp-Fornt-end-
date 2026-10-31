import 'package:flutter/material.dart';
import '../model/finance_model.dart';

@immutable
class FinanceState {
  final bool isLoading;
  final FinancePermissionModel? permission;
  final String errorMessage;
  final FinanceMetricsModel? metrics;
  final List<FinanceTransactionModel> transactions;
  final String? selectedCircle;

  const FinanceState({
    this.isLoading = false,
    this.permission,
    this.errorMessage = '',
    this.metrics,
    this.transactions = const [],
    this.selectedCircle,
  });

  FinanceState copyWith({
    bool? isLoading,
    FinancePermissionModel? permission,
    String? errorMessage,
    FinanceMetricsModel? metrics,
    List<FinanceTransactionModel>? transactions,
    String? selectedCircle,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      permission: permission ?? this.permission,
      errorMessage: errorMessage ?? this.errorMessage,
      metrics: metrics ?? this.metrics,
      transactions: transactions ?? this.transactions,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}
