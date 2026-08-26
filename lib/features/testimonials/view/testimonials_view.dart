import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/testimonials_bloc.dart';
import '../bloc/testimonials_state.dart';
import '../model/testimonial_model.dart';
import '../presenter/testimonials_presenter.dart';
import 'widgets/testimonial_card.dart';
import 'widgets/testimonials_filter_chips.dart';
import 'widgets/testimonials_metrics_overview.dart';

/// Screen component rendering peer testimonials and endorsements with clean Material 3 design.
class TestimonialsView extends StatefulWidget {
  const TestimonialsView({super.key});

  @override
  State<TestimonialsView> createState() => _TestimonialsViewState();
}

class _TestimonialsViewState extends State<TestimonialsView>
    implements TestimonialsViewContract {
  late final TestimonialsBloc _bloc;
  late final TestimonialsPresenter _presenter;

  bool _isLoading = false;
  List<TestimonialModel> _testimonials = const [];
  int? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _bloc = TestimonialsBloc();
    _presenter = TestimonialsPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- TestimonialsViewContract Implementations ---

  @override
  void onTestimonialsLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onTestimonialsLoaded() {
    setState(() {
      _isLoading = false;
      _testimonials = _bloc.state.filteredTestimonials;
      _selectedFilter = _bloc.state.selectedRatingFilter;
    });
  }

  @override
  void onTestimonialsError(String message) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allList = _bloc.state.allTestimonials;

    return BlocProvider<TestimonialsBloc>.value(
      value: _bloc,
      child: BlocListener<TestimonialsBloc, TestimonialsState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Peer Testimonials',
            subtitle: '${allList.length} endorsements',
            showBackButton: true,
          ),
          body: _isLoading && allList.isEmpty
              ? const CenteredLoadingIndicator(height: 300)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (allList.isNotEmpty) ...[
                      TestimonialsMetricsOverview(testimonials: allList),
                      TestimonialsFilterChips(
                        selectedFilter: _selectedFilter,
                        onFilterSelected: (rating) =>
                            _presenter.filterByRating(rating),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Expanded(
                      child: _testimonials.isEmpty
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
                                      Icons.rate_review_outlined,
                                      color: AppColors.textSecondary,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _selectedFilter == null
                                        ? 'No endorsements found'
                                        : 'No $_selectedFilter★ endorsements found',
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
                              padding:
                                  const EdgeInsets.only(top: 4, bottom: 24),
                              itemCount: _testimonials.length,
                              itemBuilder: (context, index) {
                                return TestimonialCard(
                                  testimonial: _testimonials[index],
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
