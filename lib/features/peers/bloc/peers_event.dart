import 'package:flutter/material.dart';

@immutable
abstract class PeersEvent {
  const PeersEvent();
}

/// Triggers loading of peers and celebrations list.
class LoadPeersData extends PeersEvent {
  final String? selectedCircle;
  const LoadPeersData({this.selectedCircle});
}

/// Dispatched when search string changes.
class SearchQueryChanged extends PeersEvent {
  final String query;
  const SearchQueryChanged(this.query);
}

/// Dispatched when status filter changes (e.g. All, Active, At Risk).
class StatusFilterChanged extends PeersEvent {
  final String status;
  const StatusFilterChanged(this.status);
}

/// Dispatched when metric sort category changes (e.g. Impact, Deals, Coins, Attendance).
class MetricSortChanged extends PeersEvent {
  final String metric;
  const MetricSortChanged(this.metric);
}

/// Dispatched when sub-tab changes (0: Peers segment, 1: Celebrations segment).
class ToggleSubTab extends PeersEvent {
  final int tabIndex;
  const ToggleSubTab(this.tabIndex);
}

/// Dispatched when user wishes a peer.
class SendWish extends PeersEvent {
  final String peerName;
  final String type;
  const SendWish(this.peerName, this.type);
}

/// Dispatched to load the next page of peers.
class LoadMorePeersData extends PeersEvent {
  const LoadMorePeersData();
}
