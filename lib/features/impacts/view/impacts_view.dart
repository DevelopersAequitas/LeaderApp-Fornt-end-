import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/impacts_bloc.dart';
import '../bloc/impacts_event.dart';
import '../bloc/impacts_state.dart';
import 'widgets/impact_card.dart';

class ImpactsView extends StatelessWidget {
  final String? circleId;

  const ImpactsView({super.key, this.circleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ImpactsBloc>(
      create: (context) =>
          ImpactsBloc()..add(LoadImpacts(circleId: circleId)),
      child: _ImpactsContent(circleId: circleId),
    );
  }
}

class _ImpactsContent extends StatelessWidget {
  final String? circleId;

  const _ImpactsContent({this.circleId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ImpactsBloc>();

    return BlocListener<ImpactsBloc, ImpactsState>(
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
      child: BlocBuilder<ImpactsBloc, ImpactsState>(
        builder: (context, state) {
          final impacts = state.impacts;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Life Impacts',
              subtitle: '${impacts.length} impact stories',
              showBackButton: true,
              // actions: [
              //   IconButton(
              //     icon: const Icon(
              //       Icons.add_circle_outline_rounded,
              //       color: AppColors.primary,
              //     ),
              //     onPressed: () => _openCreateSheet(context),
              //     tooltip: 'Record Impact',
              //   ),
              // ],
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && impacts.isEmpty
                  ? const CenteredLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadImpacts(circleId: circleId));
                      },
                      child: impacts.isEmpty
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
                                          Icons.volunteer_activism_outlined,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No life impacts recorded yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Recorded mentorship and assistance will appear here.',
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
                              itemCount: impacts.length,
                              itemBuilder: (context, index) {
                                return ImpactCard(impact: impacts[index]);
                              },
                            ),
                    ),
            ),
            // floatingActionButton: FloatingActionButton.extended(
            //   onPressed: () => _openCreateSheet(context),
            //   backgroundColor: AppColors.primary,
            //   icon: const Icon(Icons.add_rounded, color: Colors.white),
            //   label: const Text(
            //     'Record Impact',
            //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            //   ),
            // ),
          );
        },
      ),
    );
  }
}
