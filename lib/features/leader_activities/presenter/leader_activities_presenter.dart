import '../../peers/model/peer_model.dart';
import '../model/leader_activity_item_model.dart';

/// Presenter responsible for filtering, enriching, sorting, and ranking
/// activity-specific Peers and activity records for [LeaderActivitiesView].
class LeaderActivitiesPresenter {
  const LeaderActivitiesPresenter();

  /// Defensively parses activity date strings into [DateTime].
  DateTime? tryParseActivityDate(String? raw) {
    final str = raw?.trim() ?? '';
    if (str.isEmpty) return null;
    final iso = DateTime.tryParse(str);
    if (iso != null) return iso;
    return DateTime.tryParse(str.replaceAll('/', '-'));
  }

  /// Normalizes a single item's sub-type / category / status tokens into
  /// clean human-readable filter labels for the given [activityType].
  List<String> resolveItemFilterLabels(
    LeaderActivityItemModel item, {
    required String activityType,
  }) {
    final normalizedType =
        LeaderActivityCategoryConfig.fromType(activityType).type;
    final labels = <String>[];

    void addNormalized(String? raw) {
      final clean = raw?.trim() ?? '';
      if (clean.isEmpty) return;
      final lower = clean.toLowerCase();
      if (lower == 'null' ||
          lower == 'none' ||
          lower == 'activity record' ||
          lower == 'peer submission' ||
          lower == normalizedType) {
        return;
      }
      final formatted = _formatFilterLabel(clean, normalizedType: normalizedType);
      if (formatted.isNotEmpty && !labels.contains(formatted)) {
        labels.add(formatted);
      }
    }

    switch (normalizedType) {
      case 'p2p-meetings':
        addNormalized(item.subtitle);
        addNormalized(item.badgeLabel);
        addNormalized(item.status);
        break;
      case 'all-asks':
      case 'open-asks':
      case 'in-progress-asks':
      case 'fulfilled-asks':
      case 'requirements':
        addNormalized(item.type);
        addNormalized(item.requestCategory);
        addNormalized(item.subtitle);
        addNormalized(item.badgeLabel);
        addNormalized(item.status);
        break;
      case 'pending-requests':
        addNormalized(item.requestCategory);
        addNormalized(item.badgeLabel);
        break;
      case 'certifications':
      case 'entrepreneur-certifications':
      case 'leadership-certifications':
        addNormalized(item.subtitle);
        addNormalized(item.badgeLabel);
        addNormalized(item.status);
        break;
      case 'impacts':
        // For Life Impacts, the most useful filter dimension is status (Pending / Approved / Rejected).
        // Impact type (impactType) is stored in subtitle / badgeLabel; include it for secondary filtering.
        final rawStatus = item.status.trim().toLowerCase();
        final statusLabel = rawStatus.contains('pending') || rawStatus.contains('awaiting') || rawStatus.contains('submitted') || rawStatus.contains('review')
            ? 'Pending'
            : rawStatus.contains('reject') || rawStatus.contains('declin')
                ? 'Rejected'
                : rawStatus.contains('approv') || rawStatus.contains('published') || rawStatus.contains('active')
                    ? 'Approved'
                    : '';
        if (statusLabel.isNotEmpty) {
          labels.add(statusLabel);
        }
        addNormalized(item.badgeLabel);
        addNormalized(item.subtitle);
        break;
      default:
        addNormalized(item.badgeLabel);
        addNormalized(item.subtitle);
        addNormalized(item.requestCategory);
        addNormalized(item.status);
        break;
    }

    return labels;
  }

  static String _formatFilterLabel(
    String raw, {
    required String normalizedType,
  }) {
    final lower = raw.trim().toLowerCase();
    // Canonical ask flow labels
    if (lower.contains('collab')) return 'Collaboration';
    if (lower == 'referral-asks' || lower == 'referral_ask') return 'Referral';
    if (lower == 'help-asks' || lower == 'help_ask' || lower == 'need-help') {
      return 'Help';
    }
    if (lower == 'peer requirement') return '';

    // Canonical P2P modes
    if (normalizedType == 'p2p-meetings') {
      if (lower == 'online' || lower == 'virtual') return 'Online';
      if (lower == 'offline' ||
          lower == 'in-person' ||
          lower == 'in person' ||
          lower == 'physical') {
        return 'In-Person';
      }
    }

    // Canonical pending moderation categories
    switch (lower) {
      case 'coin_claims':
      case 'coin-claims':
        return 'Coin Claims';
      case 'visitor_registrations':
      case 'visitor-registrations':
        return 'Visitors';
      case 'event_joining_requests':
      case 'event-registrations':
        return 'Events';
      case 'certifications':
        return 'Certifications';
      case 'circle_peer_referrals':
      case 'peer-recommendations':
        return 'Recommendations';
      case 'introduction_requests':
      case 'introduced-peers':
        return 'Introductions';
      case 'pending_impacts':
      case 'impacts':
        return 'Impacts';
    }

    // Skip raw company names or numeric amounts accidentally placed in subtitle.
    if (lower.startsWith('₹') ||
        RegExp(r'^\d+$').hasMatch(lower) ||
        lower.length > 26) {
      return '';
    }

    final words = raw
        .trim()
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .split(RegExp(r'\s+'));
    return words
        .where((w) => w.isNotEmpty)
        .map(
          (w) => w.length == 1
              ? w.toUpperCase()
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  /// Cross-references [peers] with [items] so each Peer carries their latest
  /// recorded activity timestamp (`latestActivityAt`) and normalized subtype
  /// tags (`activityTags`) for client-side `Recent` sort and `Type` filters.
  List<LeaderRankedPeerModel> enrichPeersWithItems({
    required String type,
    required List<LeaderRankedPeerModel> peers,
    required List<LeaderActivityItemModel> items,
  }) {
    if (peers.isEmpty) return peers;

    final latestByPeerId = <String, DateTime>{};
    final latestByPeerName = <String, DateTime>{};
    final tagsByPeerId = <String, Set<String>>{};
    final tagsByPeerName = <String, Set<String>>{};

    for (final item in items) {
      final pid = item.peerId.trim();
      final pName = item.peerName.trim().toLowerCase();
      final dt = tryParseActivityDate(item.date);
      final itemTags = resolveItemFilterLabels(item, activityType: type);

      if (pid.isNotEmpty) {
        if (dt != null) {
          final existing = latestByPeerId[pid];
          if (existing == null || dt.isAfter(existing)) {
            latestByPeerId[pid] = dt;
          }
        }
        if (itemTags.isNotEmpty) {
          tagsByPeerId.putIfAbsent(pid, () => <String>{}).addAll(itemTags);
        }
      }
      if (pName.isNotEmpty) {
        if (dt != null) {
          final existing = latestByPeerName[pName];
          if (existing == null || dt.isAfter(existing)) {
            latestByPeerName[pName] = dt;
          }
        }
        if (itemTags.isNotEmpty) {
          tagsByPeerName.putIfAbsent(pName, () => <String>{}).addAll(itemTags);
        }
      }
    }

    return peers.map((rp) {
      final pid = rp.peer.id.trim();
      final pName = rp.peer.name.trim().toLowerCase();

      DateTime? resolvedDate = rp.latestActivityAt;
      final itemDate =
          (pid.isNotEmpty ? latestByPeerId[pid] : null) ??
          (pName.isNotEmpty ? latestByPeerName[pName] : null);
      if (itemDate != null &&
          (resolvedDate == null || itemDate.isAfter(resolvedDate))) {
        resolvedDate = itemDate;
      }

      final combinedTags = <String>{
        for (final rawTag in rp.activityTags)
          if (_formatFilterLabel(rawTag, normalizedType: type).isNotEmpty)
            _formatFilterLabel(rawTag, normalizedType: type),
        ...?tagsByPeerId[pid],
        ...?tagsByPeerName[pName],
      };

      return rp.copyWith(
        latestActivityAt: resolvedDate,
        activityTags: combinedTags.toList(),
      );
    }).toList();
  }

  /// Extracts deterministic, clean filter options from [items] and [peers]
  /// tailored to [type].
  List<String> extractFilterTypes({
    required String type,
    required List<LeaderActivityItemModel> items,
    required List<LeaderRankedPeerModel> peers,
  }) {
    final config = LeaderActivityCategoryConfig.fromType(type);
    if (!config.supportsListFilters) return const [];
    if (config.type == 'impacts') {
      return const ['Pending', 'Approved', 'Rejected'];
    }

    final counts = <String, int>{};
    void countTag(String tag) {
      if (tag.isEmpty) return;
      counts[tag] = (counts[tag] ?? 0) + 1;
    }

    for (final item in items) {
      for (final label in resolveItemFilterLabels(item, activityType: type)) {
        countTag(label);
      }
    }
    for (final rp in peers) {
      for (final tag in rp.activityTags) {
        final formatted = _formatFilterLabel(tag, normalizedType: type);
        countTag(formatted);
      }
    }

    // Remove generic singletons unless they coexist with at least one peer/item
    // or more than one distinct option makes filtering useful.
    if (counts.length <= 1) {
      return const [];
    }

    final sorted = counts.keys.toList()
      ..sort((a, b) => (counts[b] ?? 0).compareTo(counts[a] ?? 0));
    return sorted.take(6).toList();
  }

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

  /// Filters [peers] by search [query] and optional [selectedFilterType],
  /// and optionally sorts newest activity first when [sortByRecent] is true.
  List<LeaderRankedPeerModel> applyPeerFilters({
    required List<LeaderRankedPeerModel> peers,
    required String query,
    required bool sortByRecent,
    String? selectedFilterType,
  }) {
    var result = filterPeers(peers, query);

    final cleanType = selectedFilterType?.trim() ?? '';
    if (cleanType.isNotEmpty) {
      final targetLower = cleanType.toLowerCase();
      result = result
          .where(
            (rp) => rp.activityTags.any((t) => t.toLowerCase() == targetLower),
          )
          .toList();
    }

    if (sortByRecent) {
      result = List<LeaderRankedPeerModel>.from(result)
        ..sort((a, b) {
          final da = a.latestActivityAt;
          final db = b.latestActivityAt;
          if (da != null && db != null) {
            final cmp = db.compareTo(da);
            if (cmp != 0) return cmp;
          } else if (db != null) {
            return 1;
          } else if (da != null) {
            return -1;
          }
          return a.rank.compareTo(b.rank);
        });
    }

    return result;
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

  /// Filters and optionally sorts [items] by most recent timestamp descending.
  List<LeaderActivityItemModel> applyItemFilters({
    required String type,
    required List<LeaderActivityItemModel> items,
    required String query,
    required bool sortByRecent,
    String? selectedFilterType,
  }) {
    var result = filterItems(items, query);

    final cleanType = selectedFilterType?.trim() ?? '';
    if (cleanType.isNotEmpty) {
      final targetLower = cleanType.toLowerCase();
      result = result.where((item) {
        final labels = resolveItemFilterLabels(item, activityType: type);
        return labels.any((l) => l.toLowerCase() == targetLower);
      }).toList();
    }

    if (sortByRecent) {
      result = List<LeaderActivityItemModel>.from(result)
        ..sort((a, b) {
          final da = tryParseActivityDate(a.date);
          final db = tryParseActivityDate(b.date);
          if (da != null && db != null) {
            return db.compareTo(da);
          } else if (db != null) {
            return 1;
          } else if (da != null) {
            return -1;
          }
          return 0;
        });
    }

    return result;
  }

  /// Returns Top Contributors ranked highest-to-lowest by metric value/count.
  List<LeaderRankedPeerModel> buildTopContributors({
    required List<LeaderRankedPeerModel> peers,
    String query = '',
  }) {
    final searched = filterPeers(peers, query);
    final sorted = List<LeaderRankedPeerModel>.from(searched)
      ..sort((a, b) {
        final amtCmp = b.metricAmount.compareTo(a.metricAmount);
        if (amtCmp != 0) return amtCmp;
        final cntCmp = b.metricCount.compareTo(a.metricCount);
        if (cntCmp != 0) return cntCmp;
        final impCmp = b.peer.impactCount.compareTo(a.peer.impactCount);
        if (impCmp != 0) return impCmp;
        return a.peer.name.toLowerCase().compareTo(b.peer.name.toLowerCase());
      });

    return [
      for (var i = 0; i < sorted.length; i++) sorted[i].copyWith(rank: i + 1),
    ];
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
