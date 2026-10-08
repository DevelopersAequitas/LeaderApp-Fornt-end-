import 'package:flutter/material.dart';
import '../../../core/theme/app_color.dart';
import '../../../core/widgets/widgets.dart';
import '../../teams/model/teams_model.dart';
import 'widgets/circle_overview_section.dart';

/// Dedicated standalone screen for Circle Overview.
class CircleOverviewScreen extends StatelessWidget {
  final CircleTeamModel circle;

  const CircleOverviewScreen({super.key, required this.circle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Circle Overview',
        subtitle: circle.name,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 12),
              CircleOverviewSection(circle: circle),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
