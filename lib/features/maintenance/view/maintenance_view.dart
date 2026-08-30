// ==============================================================================
// File: lib/features/maintenance/view/maintenance_view.dart
// Description: Scheduled Maintenance Lockdown, Live Status Check & System Recovery
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Elegant maintenance illustration with server health status banner
//   - Estimated system restoration countdown and detailed administrator announcement
//   - Interactive "Check Status" server retry probe dispatched to `MaintenanceBloc`
//   - Automated recovery routing to Home or Login once maintenance window concludes
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/maintenance_bloc.dart';
import '../bloc/maintenance_event.dart';
import '../bloc/maintenance_state.dart';
import 'widgets/maintenance_action_buttons.dart';
import 'widgets/maintenance_icon_card.dart';
import 'widgets/maintenance_message_card.dart';

/// Full-screen MD3 Maintenance screen with pure BLoC state management.
/// 100% StatelessWidget powered by Clean MVP + BLoC architecture.
class MaintenanceView extends StatelessWidget {
  const MaintenanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MaintenanceBloc>(
      create: (context) =>
          MaintenanceBloc()..add(const CheckMaintenanceStatus()),
      child: const _MaintenanceContent(),
    );
  }
}

class _MaintenanceContent extends StatelessWidget {
  const _MaintenanceContent();

  void _navigateToApp(BuildContext context) {
    if (SessionManager().isAuthenticated) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<MaintenanceBloc>();

    return BlocListener<MaintenanceBloc, MaintenanceState>(
      listener: (context, state) {
        if (!state.isMaintenanceActive && !state.isChecking) {
          _navigateToApp(context);
        }
      },
      child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
        builder: (context, state) {
          final isChecking = state.isChecking;
          final title = state.maintenanceTitle;
          final message = state.maintenanceMessage;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MaintenanceIconCard(),
                      const SizedBox(height: 24),
                      MaintenanceMessageCard(
                        title: title,
                        message: message,
                      ),
                      const SizedBox(height: 24),
                      MaintenanceActionButtons(
                        isChecking: isChecking,
                        canBypass: false,
                        onRetry: () =>
                            bloc.add(const CheckMaintenanceStatus()),
                        onBypass: () => _navigateToApp(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
