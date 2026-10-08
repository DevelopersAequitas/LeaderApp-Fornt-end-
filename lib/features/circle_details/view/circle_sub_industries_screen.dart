import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import '../bloc/circle_details_bloc.dart';
import '../bloc/circle_details_event.dart';
import '../bloc/circle_details_state.dart';
import 'widgets/circle_sub_industries_section.dart';

/// Dedicated standalone screen for Circle Sub-Industries.
class CircleSubIndustriesScreen extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleSubIndustriesScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsBloc>(
      create: (context) =>
          CircleDetailsBloc()..add(LoadCircleDetailsData(circleId: circle.id)),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Sub-Industries',
          subtitle: circle.name,
          showBackButton: true,
        ),
        body: SafeArea(
          child: BlocBuilder<CircleDetailsBloc, CircleDetailsState>(
            builder: (context, state) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    CircleSubIndustriesSection(
                      subIndustries: state.subIndustries,
                      isLoading: state.isLoadingSubIndustries,
                      categoryName: circle.category,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
