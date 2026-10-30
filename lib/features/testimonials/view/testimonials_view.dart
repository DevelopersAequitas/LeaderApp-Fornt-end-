// ==============================================================================
// File: lib/features/testimonials/view/testimonials_view.dart
// Description: Peer Testimonials & Recommendations Feed
// Framework: Flutter | Architecture: MVP View Layer
// ==============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/testimonials_bloc.dart';
import '../bloc/testimonials_event.dart';
import '../bloc/testimonials_state.dart';
import 'widgets/testimonial_card.dart';

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

class _TestimonialsContent extends StatefulWidget {
  const _TestimonialsContent();

  @override
  State<_TestimonialsContent> createState() => _TestimonialsContentState();
}

class _TestimonialsContentState extends State<_TestimonialsContent> {
  String _searchQuery = '';

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
          final q = _searchQuery.trim().toLowerCase();
          final testimonials = q.isEmpty
              ? state.filteredTestimonials
              : state.filteredTestimonials.where((t) {
                  return t.authorName.toLowerCase().contains(q) ||
                      t.targetPeerName.toLowerCase().contains(q) ||
                      t.content.toLowerCase().contains(q) ||
                      t.authorRole.toLowerCase().contains(q);
                }).toList();

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: CustomAppBar(
              title: 'Testimonials',
              showBackButton: true,
              showSearch: true,
              searchHint: 'Search testimonials...',
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onSearchClosed: () => setState(() => _searchQuery = ''),
            ),
            body: SafeArea(
              top: false,
              child: state.isLoading && state.filteredTestimonials.isEmpty
                  ? const ListShimmerSkeleton()
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
                                      fontWeight: FontWeight.w500,
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
            ),
          );
        },
      ),
    );
  }
}
