import 'package:flutter/material.dart';

@immutable
abstract class PeersByCoinsEvent {
  const PeersByCoinsEvent();
}

class LoadPeersByCoins extends PeersByCoinsEvent {
  const LoadPeersByCoins();
}

class FilterPeersByCoins extends PeersByCoinsEvent {
  final String status; // 'All', 'Active', 'At Risk'
  const FilterPeersByCoins(this.status);
}
