import 'package:flutter/material.dart';
import '../../../../core/notifications/notification_highlight_wrapper.dart';
import '../../../../core/notifications/notification_list_focus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/widgets.dart';
import '../../model/finance_model.dart';

/// Renders the Recent Transactions & Collections ledger on the Finance screen.
class FinanceTransactionsList extends StatefulWidget {
  final List<FinanceTransactionModel> transactions;
  final String? focusTransactionId;

  const FinanceTransactionsList({
    super.key,
    required this.transactions,
    this.focusTransactionId,
  });

  @override
  State<FinanceTransactionsList> createState() =>
      _FinanceTransactionsListState();
}

class _FinanceTransactionsListState extends State<FinanceTransactionsList> {
  final NotificationListFocusController _focusController =
      NotificationListFocusController();
  final Map<String, GlobalKey> _txnKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    final id = widget.focusTransactionId?.trim() ?? '';
    if (id.isNotEmpty) {
      _focusController.setTarget(
        NotificationListFocusRequest(targetId: id, targetType: 'finance'),
      );
    }
  }

  @override
  void didUpdateWidget(covariant FinanceTransactionsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusTransactionId != oldWidget.focusTransactionId) {
      final id = widget.focusTransactionId?.trim() ?? '';
      if (id.isNotEmpty) {
        _focusController.setTarget(
          NotificationListFocusRequest(targetId: id, targetType: 'finance'),
        );
      }
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) =>
      _txnKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final transactions = widget.transactions;
    if (transactions.isEmpty) return const SizedBox.shrink();

    if (_focusController.pendingRequest != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _focusController.resolveTarget<FinanceTransactionModel>(
          items: transactions,
          idOf: (t) => t.id,
          hasMore: () => false,
          loadMore: () async {},
          keyLookup: (id) => _txnKeys[id],
        );
        if (mounted &&
            _focusController.notFound &&
            _focusController.statusMessage != null) {
          ScaffoldMessenger.of(this.context).showSnackBar(
            SnackBar(content: Text(_focusController.statusMessage!)),
          );
        }
      });
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  '${transactions.length} records',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Membership dues & fee collections ledger',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: _focusController,
            builder: (context, _) {
              final activeId = _focusController.highlightedId;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 16,
                  thickness: 0.8,
                  color: AppColors.border,
                ),
                itemBuilder: (context, index) {
                  final txn = transactions[index];
                  return NotificationHighlightWrapper(
                    key: _keyFor(txn.id),
                    itemId: txn.id,
                    activeTargetId: activeId,
                    onHighlightCompleted: () =>
                        _focusController.markHighlightCompleted(txn.id),
                    borderRadius: BorderRadius.circular(10),
                    child: _buildTransactionItem(txn),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(FinanceTransactionModel txn) {
    final statusColor = _resolveStatusColor(txn.status);
    final statusBgColor = _resolveStatusBgColor(txn.status);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        InitialsAvatar(
          name: txn.peerName,
          radius: 18,
          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
          textColor: AppColors.primary,
          fontSize: 11,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                txn.peerName,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                txn.circleName.isNotEmpty
                    ? '${txn.circleName} • ${txn.date}'
                    : '${txn.type} • ${txn.date}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              txn.amount,
              style: const TextStyle(
                color: Color(0xFF16A34A),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusBgColor,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                txn.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _resolveStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'paid' || s == 'completed' || s == 'success') {
      return const Color(0xFF16A34A);
    }
    if (s == 'pending' || s == 'created') {
      return const Color(0xFFD97706);
    }
    if (s == 'overdue' || s == 'failed') {
      return AppColors.danger;
    }
    return AppColors.primary;
  }

  Color _resolveStatusBgColor(String status) {
    final s = status.toLowerCase();
    if (s == 'paid' || s == 'completed' || s == 'success') {
      return const Color(0xFFDCFCE7);
    }
    if (s == 'pending' || s == 'created') {
      return const Color(0xFFFEF3C7);
    }
    if (s == 'overdue' || s == 'failed') {
      return const Color(0xFFFEE2E2);
    }
    return const Color(0xFFEFF6FF);
  }
}
