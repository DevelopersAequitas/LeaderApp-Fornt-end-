import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/notifications/notification_highlight_wrapper.dart';
import '../../../core/notifications/notification_list_focus.dart';
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
  final String? focusCircularId;

  const CircularsView({super.key, this.focusCircularId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircularsBloc>(
      create: (context) => CircularsBloc()..add(const LoadCirculars()),
      child: _CircularsContent(focusCircularId: focusCircularId),
    );
  }
}

class _CircularsContent extends StatefulWidget {
  final String? focusCircularId;

  const _CircularsContent({this.focusCircularId});

  @override
  State<_CircularsContent> createState() => _CircularsContentState();
}

class _CircularsContentState extends State<_CircularsContent> {
  final NotificationListFocusController _focusController =
      NotificationListFocusController();
  final Map<String, GlobalKey> _itemKeys = <String, GlobalKey>{};

  @override
  void initState() {
    super.initState();
    final id = widget.focusCircularId?.trim() ?? '';
    if (id.isNotEmpty) {
      _focusController.setTarget(
        NotificationListFocusRequest(targetId: id, targetType: 'circular'),
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
    return MultiBlocListener(
      listeners: [
        BlocListener<CircularsBloc, CircularsState>(
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
        ),
        BlocListener<CircularsBloc, CircularsState>(
          listenWhen: (prev, curr) =>
              !curr.isLoading && curr.filteredCirculars.isNotEmpty,
          listener: (context, state) {
            final req = _focusController.pendingRequest;
            if (req == null) return;
            final inFiltered =
                state.filteredCirculars.any((c) => c.id == req.targetId);
            if (!inFiltered && state.selectedPriority != 'All') {
              context
                  .read<CircularsBloc>()
                  .add(const FilterCircularsByPriority('All'));
              return;
            }
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (!mounted) return;
              await _focusController.resolveTarget(
                items: state.filteredCirculars,
                idOf: (c) => c.id,
                hasMore: () => false,
                loadMore: () async {},
                keyLookup: (id) => _itemKeys[id],
              );
              if (mounted &&
                  _focusController.notFound &&
                  _focusController.statusMessage != null) {
                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(content: Text(_focusController.statusMessage!)),
                );
              }
            });
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Official Circulars',
          subtitle: 'Role-targeted updates & circulars',
          showBackButton: true,
          actions: [
            if (_canPublishCircular)
              IconButton(
                icon: const GradientIcon(
                  icon: Icons.campaign_rounded,
                  size: 24,
                  gradient: AppColors.brandGradient,
                ),
                tooltip: 'Publish Circular',
                onPressed: () => _showPublishSheet(context),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Column(
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
                          prefixIcon: GradientIcon(
                            icon: Icons.search_rounded,
                            size: 18,
                            gradient: AppColors.brandGradient,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    BlocBuilder<CircularsBloc, CircularsState>(
                      builder: (context, state) {
                        final priorities = ['All', 'Urgent', 'Important', 'Routine'];
                        return SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: priorities.map((p) {
                              final isSel = state.selectedPriority == p;
                              final isSpecialColor = p == 'Urgent' || p == 'Important';
                              final Color? solidBg = !isSel
                                  ? AppColors.secondaryBg
                                  : (p == 'Urgent'
                                      ? AppColors.danger
                                      : (p == 'Important' ? AppColors.warning : null));
                              final Gradient? gradientBg = (isSel && !isSpecialColor)
                                  ? AppColors.brandGradient
                                  : null;

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => context
                                      .read<CircularsBloc>()
                                      .add(FilterCircularsByPriority(p)),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: solidBg,
                                      gradient: gradientBg,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: isSel
                                          ? [
                                              BoxShadow(
                                                color: (p == 'Urgent'
                                                        ? AppColors.danger
                                                        : (p == 'Important'
                                                            ? AppColors.warning
                                                            : AppColors.primaryBlue))
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
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
                                            fontWeight: isSel ? FontWeight.w500 : FontWeight.w400,
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
                      return const ListShimmerSkeleton();
                    }

                    if (state.filteredCirculars.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const GradientIcon(
                              icon: Icons.mark_email_read_outlined,
                              size: 40,
                              gradient: AppColors.brandGradient,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'No active circulars found.',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
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
                      child: ListenableBuilder(
                        listenable: _focusController,
                        builder: (context, _) {
                          final activeId = _focusController.highlightedId;
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: state.filteredCirculars.length,
                            itemBuilder: (ctx, i) {
                              final circular = state.filteredCirculars[i];
                              return NotificationHighlightWrapper(
                                key: _keyFor(circular.id),
                                itemId: circular.id,
                                activeTargetId: activeId,
                                onHighlightCompleted: () =>
                                    _focusController.markHighlightCompleted(circular.id),
                                child: CircularCard(circular: circular),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
