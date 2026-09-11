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

class _BusinessDealsContent extends StatelessWidget {
  final String? circleId;

  const _BusinessDealsContent({this.circleId});

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
          final deals = state.deals;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Business Deals',
              subtitle: '${deals.length} deals closed',
              showBackButton: true,
              // actions: [
              //   IconButton(
              //     icon: const Icon(
              //       Icons.add_circle_outline_rounded,
              //       color: AppColors.primary,
              //     ),
              //     onPressed: () => _openCreateSheet(context),
              //     tooltip: 'Record Deal',
              //   ),
              // ],
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && deals.isEmpty
                  ? const CenteredLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadBusinessDeals(circleId: circleId));
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
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () => _openCreateSheet(context),
            //   backgroundColor: const Color(0xFF16A34A),
            //   icon: const Icon(Icons.add_rounded, color: Colors.white),
            //   label: const Text(
            //     'Record Deal',
            //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
