import 'package:flutter/material.dart';
import '../model/finance_model.dart';

@immutable
class FinanceState {
  final bool isLoading;
  final FinancePermissionModel? permission;
  final String errorMessage;
  final FinanceMetricsModel? metrics;
  final String? selectedCircle;

  const FinanceState({
    this.isLoading = false,
    this.permission,
    this.errorMessage = '',
    this.metrics,
    this.selectedCircle,
  });

  FinanceState copyWith({
    bool? isLoading,
    FinancePermissionModel? permission,
    String? errorMessage,
    FinanceMetricsModel? metrics,
    String? selectedCircle,
  }) {
    return FinanceState(
      isLoading: isLoading ?? this.isLoading,
      permission: permission ?? this.permission,
      errorMessage: errorMessage ?? this.errorMessage,
      metrics: metrics ?? this.metrics,
      selectedCircle: selectedCircle ?? this.selectedCircle,
    );
  }
}
