import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
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

  Widget _buildSummaryBox({
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, int? rating) {
    final isSelected = _selectedFilter == rating;
    return GestureDetector(
      onTap: () => _presenter.filterByRating(rating),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade500,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
        ),
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
        border: Border.all(color: const Color(0xFFEDEFF3)),
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
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF162D4A),
                child: Text(
                  testimonial.fromInitials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
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
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    Icons.star_rounded,
                    color: index < testimonial.rating
                        ? const Color(0xFFC7923E)
                        : Colors.grey.shade300,
                    size: 16,
                  );
                }),
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
          backgroundColor: const Color(0xFFF9FAFC),
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Peer Testimonials',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Mumbai Tech Sunrise - 3 endorsements',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: Colors.white),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
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
                        border: Border.all(color: const Color(0xFFEDEFF3)),
                      ),
                      child: Row(
                        children: [
                          _buildSummaryBox(
                            value: '3',
                            label: 'endorsements',
                            color: const Color(0xFF00796B),
                          ),
                          Container(width: 1, height: 32, color: Colors.grey.shade200),
                          _buildSummaryBox(
                            value: '5★',
                            label: 'avg rating',
                            color: const Color(0xFFC7923E),
                          ),
                          Container(width: 1, height: 32, color: Colors.grey.shade200),
                          _buildSummaryBox(
                            value: '3',
                            label: '5-star',
                            color: const Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Rating Filter pills row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _buildFilterPill('All', null),
                          _buildFilterPill('5', 5),
                          _buildFilterPill('4', 4),
                          _buildFilterPill('3', 3),
                        ],
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
