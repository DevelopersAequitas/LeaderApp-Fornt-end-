import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/requirements_bloc.dart';
import '../bloc/requirements_event.dart';
import '../bloc/requirements_state.dart';
import 'widgets/requirement_card.dart';

class RequirementsView extends StatelessWidget {
  final String? circleId;

  const RequirementsView({super.key, this.circleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RequirementsBloc>(
      create: (context) =>
          RequirementsBloc()..add(LoadRequirements(circleId: circleId)),
      child: _RequirementsContent(circleId: circleId),
    );
  }
}

class _RequirementsContent extends StatelessWidget {
  final String? circleId;

  const _RequirementsContent({this.circleId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<RequirementsBloc>();

    return BlocListener<RequirementsBloc, RequirementsState>(
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        }
      },
      child: BlocBuilder<RequirementsBloc, RequirementsState>(
        builder: (context, state) {
          final requirements = state.requirements;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Peer Requirements',
              subtitle: '${requirements.length} open requests',
              showBackButton: true,
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && requirements.isEmpty
                  ? const CenteredLoadingIndicator()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadRequirements(circleId: circleId));
                      },
                      child: requirements.isEmpty
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
                                          Icons.lightbulb_outline_rounded,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No peer requirements posted yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Business opportunities and assistance requests from peers will appear here.',
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
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              itemCount: requirements.length,
                              itemBuilder: (context, index) {
                                return RequirementCard(
                                  requirement: requirements[index],
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
