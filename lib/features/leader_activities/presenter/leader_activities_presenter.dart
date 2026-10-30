import '../../peers/model/peer_model.dart';
import '../model/leader_activity_item_model.dart';

/// Presenter responsible for filtering and ranking activity-specific peers & activity items top to bottom.
class LeaderActivitiesPresenter {
  const LeaderActivitiesPresenter();

  List<LeaderRankedPeerModel> filterPeers(
    List<LeaderRankedPeerModel> peers,
    String query,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return peers;

    return peers.where((row) {
      final p = row.peer;
      return p.name.toLowerCase().contains(cleanQuery) ||
          p.company.toLowerCase().contains(cleanQuery) ||
          p.location.toLowerCase().contains(cleanQuery) ||
          (p.designation?.toLowerCase().contains(cleanQuery) ?? false) ||
          (p.level4Category?.toLowerCase().contains(cleanQuery) ?? false) ||
          p.tags.toLowerCase().contains(cleanQuery);
    }).toList();
  }

  List<LeaderActivityItemModel> filterItems(
    List<LeaderActivityItemModel> items,
    String query,
  ) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return items;

    return items.where((item) {
      return item.title.toLowerCase().contains(cleanQuery) ||
          item.subtitle.toLowerCase().contains(cleanQuery) ||
          item.description.toLowerCase().contains(cleanQuery) ||
          item.peerName.toLowerCase().contains(cleanQuery) ||
          item.company.toLowerCase().contains(cleanQuery) ||
          item.city.toLowerCase().contains(cleanQuery) ||
          (item.badgeLabel?.toLowerCase().contains(cleanQuery) ?? false);
    }).toList();
  }

  /// Filters pre-ranked backend peers so activity-specific screens only show peers
  /// who actually have activity (`metricCount > 0` or non-zero `metricDisplay`),
  /// while the general `'peers'` directory screen shows all peers.
  List<LeaderRankedPeerModel> filterActivitySpecificPeers({
    required String type,
    required List<LeaderRankedPeerModel> peers,
  }) {
    final config = LeaderActivityCategoryConfig.fromType(type);
    if (config.type == 'peers') {
      return peers;
    }

    final activeOnly = peers.where((row) {
      // Discard backend `default:` fallback peers that return 'Impacts' for non-impact sections
      if (config.type != 'impacts' &&
          row.metricLabel.trim().toLowerCase() == 'impacts') {
        return false;
      }
      if (row.metricCount > 0) return true;
      final disp = row.metricDisplay.trim();
      return disp.isNotEmpty &&
          disp != '0' &&
          disp != '₹0' &&
          disp != '₹0.0' &&
          disp != '₹0.0L';
    }).toList();

    return [
      for (var i = 0; i < activeOnly.length; i++)
        activeOnly[i].copyWith(rank: i + 1),
    ];
  }

  /// Builds a top-to-bottom ranked peers list containing ONLY the peers who have
  /// activity in the requested section (except when `type == 'peers'`, which shows all peers).
  List<LeaderRankedPeerModel> buildRankedPeersFallback({
    required String type,
    required List<PeerModel> basePeers,
    required List<LeaderActivityItemModel> activityItems,
  }) {
    final config = LeaderActivityCategoryConfig.fromType(type);
    final normalized = config.type;

    final countsByPeerId = <String, int>{};
    final countsByPeerName = <String, int>{};
    final amountsByPeerId = <String, String>{};
    final amountsByPeerName = <String, String>{};

    for (final item in activityItems) {
      final id = item.peerId.trim();
      final nameKey = item.peerName.trim().toLowerCase();

      if (id.isNotEmpty) {
        countsByPeerId[id] = (countsByPeerId[id] ?? 0) + 1;
        if (item.amount != null &&
            item.amount!.trim().isNotEmpty &&
            item.amount != '₹0') {
          amountsByPeerId.putIfAbsent(id, () => item.amount!.trim());
        }
      }
      if (nameKey.isNotEmpty) {
        countsByPeerName[nameKey] = (countsByPeerName[nameKey] ?? 0) + 1;
        if (item.amount != null &&
            item.amount!.trim().isNotEmpty &&
            item.amount != '₹0') {
          amountsByPeerName.putIfAbsent(nameKey, () => item.amount!.trim());
        }
      }
    }

    final peerById = <String, PeerModel>{};
    final peerByName = <String, PeerModel>{};
    for (final p in basePeers) {
      if (p.id.trim().isNotEmpty) {
        peerById[p.id.trim()] = p;
      }
      final nKey = p.name.trim().toLowerCase();
      if (nKey.isNotEmpty) {
        peerByName[nKey] = p;
      }
    }

    final peerMap = <String, PeerModel>{};
    if (normalized == 'peers' ||
        normalized == 'impacts' ||
        normalized == 'coins' ||
        normalized == 'top-contributors' ||
        normalized == 'highest-givers') {
      for (final p in basePeers) {
        final key = p.id.isNotEmpty ? p.id : p.name.trim().toLowerCase();
        if (key.isNotEmpty) {
          peerMap[key] = p;
        }
      }
    }

    for (final item in activityItems) {
      final itemPeerId = item.peerId.trim();
      final itemNameKey = item.peerName.trim().toLowerCase();
      final matchedPeer = (itemPeerId.isNotEmpty ? peerById[itemPeerId] : null) ??
          (itemNameKey.isNotEmpty ? peerByName[itemNameKey] : null);
      final p = matchedPeer ?? item.toPeerModel();
      final key = p.id.isNotEmpty ? p.id : p.name.trim().toLowerCase();
      if (key.isNotEmpty) {
        peerMap.putIfAbsent(key, () => p);
      }
    }

    final rows = <LeaderRankedPeerModel>[];
    for (final p in peerMap.values) {
      final nameKey = p.name.trim().toLowerCase();
      final tallied = countsByPeerId[p.id] ?? countsByPeerName[nameKey] ?? 0;
      int metricCount = tallied;
      String metricDisplay = '$tallied';

      if (normalized == 'peers') {
        metricCount = p.impactCount > tallied ? p.impactCount : tallied;
        metricDisplay = '$metricCount';
      } else if (normalized == 'impacts' || normalized == 'top-contributors') {
        metricCount = p.impactCount > tallied
            ? p.impactCount
            : (tallied > 0 ? tallied : p.coins);
        metricDisplay = '$metricCount';
      } else if (normalized == 'coins') {
        metricCount = p.coins > tallied ? p.coins : tallied;
        metricDisplay = '$metricCount';
      } else if (normalized == 'highest-givers') {
        metricCount = tallied > 0
            ? tallied
            : (p.impactCount > 0 ? p.impactCount : p.coins);
        metricDisplay = '$metricCount';
      } else if (normalized == 'business-deals') {
        metricCount = tallied;
        final itemAmt = amountsByPeerId[p.id] ?? amountsByPeerName[nameKey];
        if (itemAmt != null && itemAmt.isNotEmpty) {
          metricDisplay = itemAmt;
        } else if (p.dealsFormatted.isNotEmpty &&
            p.dealsFormatted != '₹0' &&
            p.dealsFormatted != '₹0.0' &&
            p.dealsFormatted != '₹0.0L') {
          metricDisplay = p.dealsFormatted;
          if (metricCount == 0) metricCount = 1;
        } else {
          metricDisplay = '$metricCount';
        }
      }

      // Only include peers who actually have this specific activity (unless viewing general 'peers')
      if (normalized != 'peers' && metricCount <= 0) {
        continue;
      }

      rows.add(
        LeaderRankedPeerModel(
          rank: 0,
          peer: p,
          metricCount: metricCount,
          metricLabel: config.unitLabel,
          metricDisplay: metricDisplay,
        ),
      );
    }

    rows.sort((a, b) {
      final cntCmp = b.metricCount.compareTo(a.metricCount);
      if (cntCmp != 0) return cntCmp;
      final impCmp = b.peer.impactCount.compareTo(a.peer.impactCount);
      if (impCmp != 0) return impCmp;
      final coinCmp = b.peer.coins.compareTo(a.peer.coins);
      if (coinCmp != 0) return coinCmp;
      return a.peer.name.toLowerCase().compareTo(b.peer.name.toLowerCase());
    });

    return [
      for (var i = 0; i < rows.length; i++) rows[i].copyWith(rank: i + 1),
    ];
  }
}
