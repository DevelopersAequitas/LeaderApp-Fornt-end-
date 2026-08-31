// ==============================================================================
// File: lib/features/testimonials/view/testimonials_view.dart
// Description: Peer Testimonials & Recommendations Feed
// Framework: Flutter | Architecture: MVP View Layer (100% Pure StatelessWidget + BLoC)
// Features:
//   - Clean testimonial feed with Given By, Received By, Circle, and date
//   - Tapping or clicking "Read more" opens the Testimonial Detail Bottom Sheet
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

/// Screen component rendering peer testimonials.
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
          final testimonials = state.filteredTestimonials;

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Testimonials',
              subtitle: '${testimonials.length} testimonials',
              showBackButton: true,
            ),
            body: state.isLoading && testimonials.isEmpty
                ? const CenteredLoadingIndicator(height: 300)
                : RefreshIndicator(
                    onRefresh: () async {
                      bloc.add(const LoadTestimonials());
                    },
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
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.format_quote_rounded,
                                    color: AppColors.textSecondary,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'No testimonials found',
                                  style: TextStyle(
                                    color: AppColors.text,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Peer testimonials and recommendations appear here.',
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
                              top: 8,
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
          );
        },
      ),
    );
  }
}
