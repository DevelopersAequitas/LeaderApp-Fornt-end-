import 'package:flutter/material.dart';

@immutable
abstract class FinanceEvent {
  const FinanceEvent();
}

/// Triggers loading of finance permissions and metrics for selected circle.
class LoadFinanceData extends FinanceEvent {
  final String? selectedCircle;
  const LoadFinanceData({this.selectedCircle});
}
