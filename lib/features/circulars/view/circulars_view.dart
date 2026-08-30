import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/circulars_bloc.dart';
import '../bloc/circulars_event.dart';
import '../bloc/circulars_state.dart';
import 'widgets/circular_card.dart';
import 'widgets/publish_circular_bottom_sheet.dart';

/// Screen component rendering role-targeted official circulars and announcements.
/// Pure StatelessWidget powered 100% by BLoC state machine.
class CircularsView extends StatelessWidget {
  const CircularsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircularsBloc>(
      create: (context) => CircularsBloc()..add(const LoadCirculars()),
      child: const _CircularsContent(),
    );
  }
}

class _CircularsContent extends StatelessWidget {
  const _CircularsContent();

  bool get _canPublishCircular {
    final role = SessionManager().currentRole;
    return role == UserRole.superAdmin ||
        role == UserRole.countryDirector ||
        role == UserRole.districtExecDirector ||
        role == UserRole.industryDirector;
  }

  void _showPublishSheet(BuildContext context) {
    final bloc = context.read<CircularsBloc>();
    PublishCircularBottomSheet.show(
      context,
      onPublish: (newCircular) {
        bloc.add(PublishCircularEvent(newCircular));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CircularsBloc, CircularsState>(
      listenWhen: (prev, curr) =>
          (prev.errorMessage != curr.errorMessage && curr.errorMessage.isNotEmpty) ||
          (prev.successMessage != curr.successMessage && curr.successMessage != null),
      listener: (context, state) {
        if (state.errorMessage.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage),
              backgroundColor: AppColors.danger,
            ),
          );
        } else if (state.successMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.successMessage!),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Official Circulars',
          subtitle: 'Role-targeted updates & circulars',
          showBackButton: true,
          actions: [
            if (_canPublishCircular)
              IconButton(
                icon: const Icon(Icons.campaign_rounded, color: AppColors.primary),
                tooltip: 'Publish Circular',
                onPressed: () => _showPublishSheet(context),
              ),
          ],
        ),
        body: Column(
          children: [
            // Search & Filter Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Column(
                children: [
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.secondaryBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      onChanged: (q) => context.read<CircularsBloc>().add(SearchCircularsEvent(q)),
                      style: const TextStyle(fontSize: 13, color: AppColors.text),
                      decoration: const InputDecoration(
                        hintText: 'Search circulars & announcements...',
                        hintStyle: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        prefixIcon: Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  BlocBuilder<CircularsBloc, CircularsState>(
                    buildWhen: (prev, curr) => prev.selectedPriority != curr.selectedPriority,
                    builder: (context, state) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['All', 'Urgent', 'Important', 'General'].map((p) {
                            final isSel = state.selectedPriority == p;
                            final activeColor = p == 'Urgent'
                                ? AppColors.danger
                                : (p == 'Important' ? AppColors.warningDark : AppColors.primary);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => context
                                    .read<CircularsBloc>()
                                    .add(FilterCircularsByPriority(p)),
                                borderRadius: BorderRadius.circular(20),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  curve: Curves.easeInOut,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSel ? activeColor : AppColors.secondaryBg,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSel ? Colors.transparent : AppColors.border,
                                      width: 1,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: activeColor.withValues(alpha: 0.25),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            )
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isSel && p != 'All') ...[
                                        Icon(
                                          p == 'Urgent'
                                              ? Icons.error_outline_rounded
                                              : (p == 'Important'
                                                  ? Icons.warning_amber_rounded
                                                  : Icons.info_outline_rounded),
                                          size: 13,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                      Text(
                                        p,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w600,
                                          color: isSel ? Colors.white : AppColors.text,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Circulars List Section
            Expanded(
              child: BlocBuilder<CircularsBloc, CircularsState>(
                builder: (context, state) {
                  if (state.isLoading) {
                    return const CenteredLoadingIndicator();
                  }

                  if (state.filteredCirculars.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.mark_email_read_outlined,
                            size: 40,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'No active circulars found.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () => context
                                .read<CircularsBloc>()
                                .add(const LoadCirculars(isRefresh: true)),
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => context
                        .read<CircularsBloc>()
                        .add(const LoadCirculars(isRefresh: true)),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: state.filteredCirculars.length,
                      itemBuilder: (ctx, i) => CircularCard(circular: state.filteredCirculars[i]),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
