import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/notifications/notification_highlight_wrapper.dart';
import '../../../core/notifications/notification_list_focus.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/business_deals_bloc.dart';
import '../bloc/business_deals_event.dart';
import '../bloc/business_deals_state.dart';
import 'widgets/business_deal_card.dart';

class BusinessDealsView extends StatelessWidget {
  final String? circleId;
  final String? focusDealId;

  const BusinessDealsView({super.key, this.circleId, this.focusDealId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessDealsBloc>(
      create: (context) =>
          BusinessDealsBloc()..add(LoadBusinessDeals(circleId: circleId)),
      child: _BusinessDealsContent(circleId: circleId, focusDealId: focusDealId),
    );
  }
}

class _BusinessDealsContent extends StatefulWidget {
  final String? circleId;
  final String? focusDealId;

  const _BusinessDealsContent({this.circleId, this.focusDealId});

  @override
  State<_BusinessDealsContent> createState() => _BusinessDealsContentState();
}

class _BusinessDealsContentState extends State<_BusinessDealsContent> {
  String _searchQuery = '';
  final NotificationListFocusController _focusController =
      NotificationListFocusController();
  final Map<String, GlobalKey> _itemKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    final id = widget.focusDealId?.trim() ?? '';
    if (id.isNotEmpty) {
      _focusController.setTarget(
        NotificationListFocusRequest(targetId: id, targetType: 'deal'),
      );
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) =>
      _itemKeys.putIfAbsent(id, () => GlobalKey());

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BusinessDealsBloc>();

    return BlocListener<BusinessDealsBloc, BusinessDealsState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        if (state.successMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: BlocBuilder<BusinessDealsBloc, BusinessDealsState>(
        builder: (context, state) {
          final q = _searchQuery.trim().toLowerCase();
          final deals = q.isEmpty
              ? state.deals
              : state.deals.where((d) {
                  return d.peerName.toLowerCase().contains(q) ||
                      d.businessName.toLowerCase().contains(q) ||
                      d.notes.toLowerCase().contains(q) ||
                      d.city.toLowerCase().contains(q);
                }).toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Business Deals',
              showBackButton: true,
              showSearch: true,
              searchHint: 'Search business deals...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchClosed: () => setState(() => _searchQuery = ''),
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && state.deals.isEmpty
                  ? const ListShimmerSkeleton()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadBusinessDeals(circleId: widget.circleId));
                      },
                      child: deals.isEmpty
                          ? ListView(
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 32,
                                    vertical: 64,
                                  ),
                                  child: Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.monetization_on_outlined,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No business deals recorded yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Record closed deals and transactions with peers in your circle.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : ListenableBuilder(
                              listenable: _focusController,
                              builder: (context, _) {
                                if (_focusController.pendingRequest != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((_) async {
                                    if (!mounted) return;
                                    await _focusController.resolveTarget(
                                      items: deals,
                                      idOf: (d) => d.id,
                                      hasMore: () => false,
                                      loadMore: () async {},
                                      keyLookup: (id) => _itemKeys[id],
                                    );
                                    if (mounted &&
                                        _focusController.notFound &&
                                        _focusController.statusMessage != null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(_focusController.statusMessage!)),
                                      );
                                    }
                                  });
                                }
                                final activeId = _focusController.highlightedId;
                                return ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                                  itemCount: deals.length,
                                  itemBuilder: (context, index) {
                                    final deal = deals[index];
                                    return NotificationHighlightWrapper(
                                      key: _keyFor(deal.id),
                                      itemId: deal.id,
                                      activeTargetId: activeId,
                                      onHighlightCompleted: () =>
                                          _focusController.markHighlightCompleted(deal.id),
                                      child: BusinessDealCard(deal: deal),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
            ),
          );
        },
      ),
    );
  }
}
