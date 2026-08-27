import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/role_management_bloc.dart';
import '../bloc/role_management_state.dart';
import '../model/role_permission_model.dart';
import '../presenter/role_management_presenter.dart';
import 'widgets/add_role_bottom_sheet.dart';
import 'widgets/capability_filter_bar.dart';
import 'widgets/role_category_section.dart';
import 'widgets/role_dialogs.dart';
import 'widgets/role_header_card.dart';
import 'widgets/role_save_bar.dart';
import 'widgets/role_selector_bar.dart';

/// The View component of the Role Management feature for Super Admin.
class RoleManagementView extends StatefulWidget {
  const RoleManagementView({super.key});

  @override
  State<RoleManagementView> createState() => _RoleManagementViewState();
}

class _RoleManagementViewState extends State<RoleManagementView>
    implements RoleManagementViewContract {
  late final RoleManagementBloc _bloc;
  late final RoleManagementPresenter _presenter;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;
  List<RolePermissionModel> _rolesPermissions = const [];
  List<AppCapability> _capabilities = const [];

  String _selectedRoleId = '';
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _bloc = RoleManagementBloc();
    _presenter = RoleManagementPresenter(view: this, bloc: _bloc);
    _presenter.load();
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- RoleManagementViewContract Implementations ---

  @override
  void onRoleManagementLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onRoleManagementLoaded() {
    setState(() {
      _isLoading = false;
      _rolesPermissions = _bloc.state.rolesPermissions;
      _capabilities = _bloc.state.capabilities;
      _hasUnsavedChanges = _bloc.state.hasUnsavedChanges;
      if (_rolesPermissions.isNotEmpty &&
          !_rolesPermissions.any((r) => r.role.id == _selectedRoleId)) {
        _selectedRoleId = _rolesPermissions.first.role.id;
      }
    });
  }

  @override
  void onRoleManagementSaving() {
    setState(() => _isSaving = true);
  }

  @override
  void onRoleManagementSaved() {
    setState(() {
      _isSaving = false;
      _hasUnsavedChanges = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Role matrix saved successfully!',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void onRoleManagementError(String error) {
    setState(() {
      _isLoading = false;
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error, style: const TextStyle(fontSize: 13)),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Actions ---

  void _showAddRole() {
    AddRoleBottomSheet.show(
      context,
      onAdd: (name) => _presenter.addRole(name),
    );
  }

  void _showEditRoleDialog(RoleModel role) {
    RoleDialogs.showEditRoleDialog(
      context,
      role: role,
      onSave: (newName) => _presenter.editRole(role.id, newName),
    );
  }

  void _showDeleteRoleDialog(RoleModel role) {
    RoleDialogs.showDeleteRoleDialog(
      context,
      role: role,
      onDelete: () {
        _presenter.deleteRole(role.id);
        if (_selectedRoleId == role.id) {
          final remaining = _rolesPermissions.where((r) => r.role.id != role.id).toList();
          if (remaining.isNotEmpty) {
            setState(() => _selectedRoleId = remaining.first.role.id);
          }
        }
      },
    );
  }

  // --- Filtering Helpers ---

  List<String> get _categories {
    final set = <String>{};
    for (final cap in _capabilities) {
      set.add(cap.category);
    }
    return set.toList();
  }

  List<AppCapability> _filterCapabilities(List<AppCapability> list) {
    return list.where((cap) {
      final matchesCat = _selectedCategory == 'All' || cap.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          cap.name.toLowerCase().contains(query) ||
          cap.description.toLowerCase().contains(query);
      return matchesCat && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoleModel = _rolesPermissions.firstWhere(
      (rp) => rp.role.id == _selectedRoleId,
      orElse: () => _rolesPermissions.isNotEmpty
          ? _rolesPermissions.first
          : const RolePermissionModel(
              role: RoleModel(id: '', label: ''),
              enabledCapabilityIds: [],
            ),
    );

    final groupedCategories = <String, List<AppCapability>>{};
    for (final cap in _filterCapabilities(_capabilities)) {
      groupedCategories.putIfAbsent(cap.category, () => []).add(cap);
    }

    return BlocProvider<RoleManagementBloc>.value(
      value: _bloc,
      child: BlocListener<RoleManagementBloc, RoleManagementState>(
        listener: (context, state) => _presenter.handleStateChange(state),
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Role Settings',
            subtitle: 'Configure permissions & manage roles',
            showBackButton: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
                tooltip: 'Add Custom Role',
                onPressed: _showAddRole,
              ),
            ],
          ),
          body: _isLoading
              ? const CenteredLoadingIndicator()
              : _rolesPermissions.isEmpty
                  ? const Center(
                      child: Text(
                        'No roles available from server',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : Column(
                      children: [
                        RoleSelectorBar(
                          rolesPermissions: _rolesPermissions,
                          selectedRoleId: _selectedRoleId.isNotEmpty
                              ? _selectedRoleId
                              : _rolesPermissions.first.role.id,
                          onSelectRole: (id) => setState(() => _selectedRoleId = id),
                          onAddRole: _showAddRole,
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                RoleHeaderCard(
                                  rolePermission: selectedRoleModel,
                                  totalCapabilities: _capabilities.length,
                                  onEdit: () => _showEditRoleDialog(selectedRoleModel.role),
                                  onDelete: () => _showDeleteRoleDialog(selectedRoleModel.role),
                                  onToggleAll: (enable) => _presenter.toggleAllCapabilities(
                                    selectedRoleModel.role.id,
                                    _capabilities.map((c) => c.id).toList(),
                                    enable,
                                  ),
                                ),
                                CapabilityFilterBar(
                                  searchQuery: _searchQuery,
                                  selectedCategory: _selectedCategory,
                                  categories: _categories,
                                  onSearchChanged: (q) => setState(() => _searchQuery = q),
                                  onCategorySelected: (cat) => setState(() => _selectedCategory = cat),
                                ),
                                if (groupedCategories.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 40.0),
                                    child: Center(
                                      child: Text(
                                        'No capabilities match the search filter.',
                                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                      ),
                                    ),
                                  )
                                else
                                  ...groupedCategories.entries.map((entry) {
                                    return RoleCategorySection(
                                      categoryName: entry.key,
                                      capabilities: entry.value,
                                      enabledCapabilityIds: selectedRoleModel.enabledCapabilityIds,
                                      onToggleCapability: (capId) => _presenter.toggleCapability(
                                        selectedRoleModel.role.id,
                                        capId,
                                      ),
                                      onToggleCategoryAll: (enable) => _presenter.toggleCategoryCapabilities(
                                        selectedRoleModel.role.id,
                                        entry.value.map((c) => c.id).toList(),
                                        enable,
                                      ),
                                    );
                                  }),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
          bottomNavigationBar: RoleSaveBar(
            isSaving: _isSaving,
            hasUnsavedChanges: _hasUnsavedChanges,
            onSave: () => _presenter.saveChanges(),
          ),
        ),
      ),
    );
  }
}
