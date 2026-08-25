import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/testimonials_bloc.dart';
import '../bloc/testimonials_state.dart';
import '../presenter/testimonials_presenter.dart';
import '../model/testimonial_model.dart';

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

  @override
  void onTestimonialsLoading() {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  Widget _buildTestimonialCard(TestimonialModel testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(
                name: testimonial.fromName,
                radius: 20,
                backgroundColor: AppColors.primary,
                fontSize: 13,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: AppColors.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        children: [
                          TextSpan(text: testimonial.fromName),
                          const TextSpan(
                            text: ' → ',
                            style: TextStyle(color: Colors.grey),
                          ),
                          TextSpan(text: testimonial.toName),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${testimonial.fromCompany} → ${testimonial.toCompany}',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StarRatingDisplay(
                rating: testimonial.rating,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '"${testimonial.content}"',
            style: TextStyle(
              color: AppColors.text.withOpacity(0.85),
              fontSize: 13,
              fontStyle: FontStyle.italic,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            testimonial.date,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            subtitle: 'Mumbai Tech Sunrise - 3 endorsements',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded),
                onPressed: () {},
              ),
            ],
          ),
          body: _isLoading
              ? const CenteredLoadingIndicator()
              : Column(
                  children: [
                    const SizedBox(height: 16),
                    // Summary metrics box
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              value: '3',
                              label: 'endorsements',
                              valueColor: AppColors.chartSecondary,
                              labelColor: Colors.grey.shade500,
                              valueFontSize: 18,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Container(width: 1, height: 32, color: Colors.grey.shade200),
                          Expanded(
                            child: StatCard(
                              value: '5★',
                              label: 'avg rating',
                              valueColor: AppColors.warning,
                              labelColor: Colors.grey.shade500,
                              valueFontSize: 18,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                          Container(width: 1, height: 32, color: Colors.grey.shade200),
                          Expanded(
                            child: StatCard(
                              value: '3',
                              label: '5-star',
                              valueColor: AppColors.success,
                              labelColor: Colors.grey.shade500,
                              valueFontSize: 18,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating Filter pills row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HorizontalSelectionChips(
                        options: const ['All', '5★', '4★', '3★'],
                        selectedOption: _selectedFilter == null
                            ? 'All'
                            : '${_selectedFilter}★',
                        onSelected: (option) {
                          final rating = option == 'All'
                              ? null
                              : int.parse(option.replaceAll('★', ''));
                          _presenter.filterByRating(rating);
                        },
                        unselectedTextColor: Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Testimonials List
                    Expanded(
                      child: _testimonials.isEmpty
                          ? Center(
                              child: Text(
                                'No endorsements matching filter',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _testimonials.length,
                              itemBuilder: (context, index) {
                                return _buildTestimonialCard(_testimonials[index]);
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
