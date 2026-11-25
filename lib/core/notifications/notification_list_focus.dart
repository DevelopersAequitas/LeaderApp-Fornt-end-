import 'package:flutter/material.dart';

/// Describes a notification's exact target inside a feature screen or paginated list.
@immutable
class NotificationListFocusRequest {
  final String targetId;
  final String targetType;
  final String? targetFilter;
  final String? targetStatus;
  final int? targetTab;
  final String? circleId;

  const NotificationListFocusRequest({
    required this.targetId,
    required this.targetType,
    this.targetFilter,
    this.targetStatus,
    this.targetTab,
    this.circleId,
  });
}

/// Reusable, feature-independent controller that locates an exact item across
/// paginated/filtered lists, scrolls it into view, and triggers a single
/// 3-pulse highlight sequence.
class NotificationListFocusController extends ChangeNotifier {
  NotificationListFocusController({this.maxPaginationPages = 15});

  final int maxPaginationPages;

  NotificationListFocusRequest? _pendingRequest;
  String? _highlightedId;
  bool _isResolving = false;
  bool _notFound = false;
  String? _statusMessage;
  int _pagesFetched = 0;
  final Set<String> _completedFocusKeys = <String>{};

  NotificationListFocusRequest? get pendingRequest => _pendingRequest;
  String? get highlightedId => _highlightedId;
  bool get isResolving => _isResolving;
  bool get notFound => _notFound;
  String? get statusMessage => _statusMessage;

  void setTarget(NotificationListFocusRequest request) {
    if (request.targetId.trim().isEmpty) return;
    final key = '${request.targetType}:${request.targetId}';
    if (_completedFocusKeys.contains(key)) return;
    _pendingRequest = request;
    _highlightedId = null;
    _notFound = false;
    _statusMessage = null;
    _pagesFetched = 0;
    notifyListeners();
  }

  /// Attempts to locate [targetId] in [items]. If not present and [hasMore] is true,
  /// invokes [loadMore] up to [maxPaginationPages] times.
  Future<bool> resolveTarget<T>({
    required List<T> items,
    required String Function(T item) idOf,
    required bool Function() hasMore,
    required Future<void> Function() loadMore,
    GlobalKey? Function(String id)? keyLookup,
  }) async {
    final req = _pendingRequest;
    if (req == null || _isResolving) return false;

    final key = '${req.targetType}:${req.targetId}';
    if (_completedFocusKeys.contains(key)) return false;

    _isResolving = true;
    try {
      var found = items.any((item) => idOf(item) == req.targetId);

      while (!found && hasMore() && _pagesFetched < maxPaginationPages) {
        _pagesFetched++;
        await loadMore();
        found = items.any((item) => idOf(item) == req.targetId);
      }

      if (found) {
        _highlightedId = req.targetId;
        _notFound = false;
        _statusMessage = null;
        notifyListeners();

        // Scroll rendered widget into view when GlobalKey context is mounted.
        final targetKey = keyLookup?.call(req.targetId);
        final ctx = targetKey?.currentContext;
        if (ctx != null && ctx.mounted) {
          await Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: 0.25,
          );
        }
        return true;
      }

      if (!hasMore() || _pagesFetched >= maxPaginationPages) {
        _notFound = true;
        _highlightedId = null;
        _statusMessage =
            'The target record is no longer available or outside your current scope.';
        _completedFocusKeys.add(key);
        _pendingRequest = null;
        notifyListeners();
      }
      return false;
    } finally {
      _isResolving = false;
    }
  }

  /// Called by [NotificationHighlightWrapper] once all 3 pulses finish.
  void markHighlightCompleted(String id) {
    final req = _pendingRequest;
    if (req != null && req.targetId == id) {
      _completedFocusKeys.add('${req.targetType}:${req.targetId}');
      _pendingRequest = null;
    }
    if (_highlightedId == id) {
      _highlightedId = null;
      notifyListeners();
    }
  }
}
