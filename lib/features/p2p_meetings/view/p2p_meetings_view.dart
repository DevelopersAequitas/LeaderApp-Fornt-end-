import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/p2p_meetings_bloc.dart';
import '../bloc/p2p_meetings_event.dart';
import '../bloc/p2p_meetings_state.dart';
import 'widgets/p2p_meeting_card.dart';

class P2PMeetingsView extends StatelessWidget {
  final String? circleId;

  const P2PMeetingsView({super.key, this.circleId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<P2PMeetingsBloc>(
      create: (context) =>
          P2PMeetingsBloc()..add(LoadP2PMeetings(circleId: circleId)),
      child: _P2PMeetingsContent(circleId: circleId),
    );
  }
}

class _P2PMeetingsContent extends StatefulWidget {
  final String? circleId;

  const _P2PMeetingsContent({this.circleId});

  @override
  State<_P2PMeetingsContent> createState() => _P2PMeetingsContentState();
}

class _P2PMeetingsContentState extends State<_P2PMeetingsContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<P2PMeetingsBloc>();

    return BlocListener<P2PMeetingsBloc, P2PMeetingsState>(
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
      child: BlocBuilder<P2PMeetingsBloc, P2PMeetingsState>(
        builder: (context, state) {
          final q = _searchQuery.trim().toLowerCase();
          final meetings = q.isEmpty
              ? state.meetings
              : state.meetings.where((m) {
                  return m.peerName.toLowerCase().contains(q) ||
                      m.businessName.toLowerCase().contains(q) ||
                      m.location.toLowerCase().contains(q) ||
                      m.notes.toLowerCase().contains(q) ||
                      m.city.toLowerCase().contains(q);
                }).toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'P2P Meetings',
              showBackButton: true,
              showSearch: true,
              searchHint: 'Search P2P meetings...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchClosed: () => setState(() => _searchQuery = ''),
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && state.meetings.isEmpty
                  ? const ListShimmerSkeleton()
                  : RefreshIndicator(
                      onRefresh: () async {
                        bloc.add(LoadP2PMeetings(circleId: widget.circleId));
                      },
                      child: meetings.isEmpty
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
                                          Icons.handshake_outlined,
                                          size: 48,
                                          color: AppColors.textSecondary,
                                        ),
                                        SizedBox(height: 12),
                                        Text(
                                          'No P2P meetings scheduled yet',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15,
                                            color: AppColors.text,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          'Schedule 1-on-1 collaborative meetings with your peers.',
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
                              itemCount: meetings.length,
                              itemBuilder: (context, index) {
                                return P2PMeetingCard(meeting: meetings[index]);
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
