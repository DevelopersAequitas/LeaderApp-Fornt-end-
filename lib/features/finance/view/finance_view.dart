// ==============================================================================
// File: lib/features/finance/view/finance_view.dart
// Description: Executive Finance & Revenue Management Analytics Portal
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Revenue metrics grid (Total Revenue, Monthly Yield, Founder Overrides, Net Earnings)
//   - Monthly revenue analytics chart with trend projections
//   - Commission tier rates & structure matrices (Circle Founder, Circle Chair, Area Director)
//   - Role-based security gating with restricted placeholder for non-finance roles
//   - Generous bottom scroll clearance for bottom navigation bar
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../model/finance_model.dart';
import 'widgets/finance_chart_section.dart';
import 'widgets/finance_commission_rates.dart';
import 'widgets/finance_commission_structure.dart';
import 'widgets/finance_metrics_grid.dart';
import 'widgets/finance_restricted_view.dart';

/// The View component of the Finance tab feature.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class FinanceView extends StatelessWidget {
  final String? selectedCircle;

  const FinanceView({super.key, this.selectedCircle});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceBloc>(
      key: ValueKey(selectedCircle),
      create: (context) =>
          FinanceBloc()..add(LoadFinanceData(selectedCircle: selectedCircle)),
      child: _FinanceContent(selectedCircle: selectedCircle),
    );
  }
}

class _FinanceContent extends StatelessWidget {
  final String? selectedCircle;

  const _FinanceContent({this.selectedCircle});

  Widget _buildFounderFinanceView(FinanceMetricsModel metrics) {
    final role = SessionManager().currentRole;
    final hideCommissionRates = role == UserRole.industryDirector ||
        role == UserRole.countryDirector ||
        role == UserRole.superAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceMetricsGrid(metrics: metrics),
        FinanceChartSection(metrics: metrics),
        if (!hideCommissionRates)
          FinanceCommissionRates(rates: metrics.commissionRates),
        FinanceCommissionStructure(structure: metrics.commissionStructure),
        const SizedBox(height: 48), // Generous bottom spacing for navigation bar clearance
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<FinanceBloc>();

    return BlocListener<FinanceBloc, FinanceState>(
      listenWhen: (prev, curr) =>
          prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage),
            backgroundColor: AppColors.danger,
          ),
        );
      },
      child: BlocBuilder<FinanceBloc, FinanceState>(
        builder: (context, state) {
          if (state.isLoading || state.permission == null) {
            return const CenteredLoadingIndicator(height: 300);
          }

          return RefreshIndicator(
            onRefresh: () async {
              bloc.add(LoadFinanceData(selectedCircle: selectedCircle));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 96),
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: state.permission!.isRestricted
                  ? FinanceRestrictedView(permission: state.permission!)
                  : (state.metrics != null
                      ? _buildFounderFinanceView(state.metrics!)
                      : const SizedBox()),
            ),
          );
        },
      ),
    );
  }
}
