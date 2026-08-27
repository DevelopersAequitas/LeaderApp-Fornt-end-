import 'package:flutter/material.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../model/circular_model.dart';
import 'widgets/circular_card.dart';
import 'widgets/publish_circular_bottom_sheet.dart';

/// Screen component rendering role-targeted official circulars and announcements.
class CircularsView extends StatefulWidget {
  const CircularsView({super.key});

  @override
  State<CircularsView> createState() => _CircularsViewState();
}

class _CircularsViewState extends State<CircularsView> {
  bool _isLoading = false;
  List<CircularModel> _circulars = [];
  String _searchQuery = '';
  String _selectedPriority = 'All';

  @override
  void initState() {
    super.initState();
    _loadCirculars();
  }

  Future<void> _loadCirculars() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiClient().get<List<CircularModel>>(
        ApiEndpoints.circulars,
        fromJsonT: (json) {
          if (json is List) {
            return json.map((item) => CircularModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return <CircularModel>[];
        },
      );
      if (response.data != null) {
        _circulars = response.data!;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<CircularModel> get _filteredCirculars {
    return _circulars.where((c) {
      // Priority matching
      final matchesPriority =
          _selectedPriority == 'All' || c.priority.toLowerCase() == _selectedPriority.toLowerCase();

      // Search matching
      final q = _searchQuery.trim().toLowerCase();
      final matchesSearch = q.isEmpty ||
          c.title.toLowerCase().contains(q) ||
          c.content.toLowerCase().contains(q) ||
          c.authorName.toLowerCase().contains(q);

      return matchesPriority && matchesSearch;
    }).toList();
  }

  bool get _canPublishCircular {
    final role = SessionManager().currentRole;
    return role == UserRole.superAdmin ||
        role == UserRole.countryDirector ||
        role == UserRole.districtExecDirector ||
        role == UserRole.industryDirector;
  }

  void _showPublishSheet() {
    PublishCircularBottomSheet.show(
      context,
      onPublish: (newCircular) async {
        setState(() => _circulars.insert(0, newCircular));
        try {
          await ApiClient().post(ApiEndpoints.circularPublish, body: newCircular.toJson());
        } catch (_) {}
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Circular broadcasted successfully!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCirculars;

    return Scaffold(
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
              onPressed: _showPublishSheet,
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
                    onChanged: (q) => setState(() => _searchQuery = q),
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
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Urgent', 'Important', 'General'].map((p) {
                      final isSel = _selectedPriority == p;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(
                            p,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              color: isSel ? Colors.white : AppColors.text,
                            ),
                          ),
                          selected: isSel,
                          selectedColor: p == 'Urgent' ? AppColors.danger : AppColors.primary,
                          onSelected: (_) => setState(() => _selectedPriority = p),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Circular List
          Expanded(
            child: _isLoading
                ? const CenteredLoadingIndicator()
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.textSecondary),
                            const SizedBox(height: 10),
                            const Text(
                              'No active circulars for your role.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _loadCirculars,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Refresh'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCirculars,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => CircularCard(circular: filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
