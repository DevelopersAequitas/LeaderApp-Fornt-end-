// ==============================================================================
// File: lib/features/testimonials/view/testimonials_view.dart
// Description: Peer Testimonials, Member Endorsements & Rating Analytics
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - High-contrast rating overview banner (Average Rating, Total Endorsements)
//   - Star rating filter chips (All, 5★, 4★, 3★) with active pill styling
//   - Peer testimonial cards with avatar, rating stars, and verification badges
//   - Pure BLoC reactive state rendering
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/testimonials_bloc.dart';
import '../bloc/testimonials_event.dart';
import '../bloc/testimonials_state.dart';
import 'widgets/testimonial_card.dart';
import 'widgets/testimonials_filter_chips.dart';
import 'widgets/testimonials_metrics_overview.dart';

/// Screen component rendering peer testimonials and endorsements.
/// 100% Pure StatelessWidget powered by BLoC state machine.
class TestimonialsView extends StatelessWidget {
  const TestimonialsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TestimonialsBloc>(
      create: (context) =>
          TestimonialsBloc()..add(const LoadTestimonials()),
      child: const _TestimonialsContent(),
    );
  }
}

class _TestimonialsContent extends StatelessWidget {
  const _TestimonialsContent();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TestimonialsBloc>();

    return BlocListener<TestimonialsBloc, TestimonialsState>(
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
      child: BlocBuilder<TestimonialsBloc, TestimonialsState>(
        builder: (context, state) {
          final allList = state.allTestimonials;
          final testimonials = state.filteredTestimonials;
          final selectedFilter = state.selectedRatingFilter;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Peer Testimonials',
              subtitle: '${allList.length} endorsements',
              showBackButton: true,
            ),
            body: state.isLoading && allList.isEmpty
                ? const CenteredLoadingIndicator(height: 300)
                : RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(const LoadTestimonials());
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (allList.isNotEmpty) ...[
                          TestimonialsMetricsOverview(testimonials: allList),
                          TestimonialsFilterChips(
                            selectedFilter: selectedFilter,
                            onFilterSelected: (rating) =>
                                bloc.add(FilterTestimonials(rating)),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Expanded(
                          child: testimonials.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 56,
                                        height: 56,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.rate_review_outlined,
                                          color: AppColors.textSecondary,
                                          size: 26,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        selectedFilter == null
                                            ? 'No endorsements found'
                                            : 'No $selectedFilter★ endorsements found',
                                        style: const TextStyle(
                                          color: AppColors.text,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'P2P testimonials and member recommendations appear here.',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(
                                    top: 4,
                                    bottom: 24,
                                  ),
                                  itemCount: testimonials.length,
                                  itemBuilder: (context, index) {
                                    return TestimonialCard(
                                      testimonial: testimonials[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
          );
        },
      ),
    );
  }
}
