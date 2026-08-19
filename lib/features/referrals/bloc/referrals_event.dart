import 'package:flutter/material.dart';

@immutable
abstract class ReferralsEvent {
  const ReferralsEvent();
}

class LoadReferrals extends ReferralsEvent {
  const LoadReferrals();
}

class FilterReferrals extends ReferralsEvent {
  final String status; // 'All', 'Active', 'At Risk'
  const FilterReferrals(this.status);
}
