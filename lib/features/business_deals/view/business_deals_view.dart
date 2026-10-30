import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/business_deals_bloc.dart';
import '../bloc/business_deals_event.dart';
import '../bloc/business_deals_state.dart';
import 'widgets/business_deal_card.dart';

class BusinessDealsView extends StatelessWidget {
  final String? circleId;

  const BusinessDealsView({super.key, this.circleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BusinessDealsBloc>(
      create: (context) =>
          BusinessDealsBloc()..add(LoadBusinessDeals(circleId: circleId)),
      child: _BusinessDealsContent(circleId: circleId),
    );
  }
}

class _BusinessDealsContent extends StatefulWidget {
  final String? circleId;

  const _BusinessDealsContent({this.circleId});

  @override
  State<_BusinessDealsContent> createState() => _BusinessDealsContentState();
}

class _BusinessDealsContentState extends State<_BusinessDealsContent> {
  String _searchQuery = '';

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
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 80),
                              itemCount: deals.length,
                              itemBuilder: (context, index) {
                                return BusinessDealCard(deal: deals[index]);
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
