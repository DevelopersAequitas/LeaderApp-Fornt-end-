import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/role_management_bloc.dart';
import '../bloc/role_management_state.dart';
import '../model/role_permission_model.dart';
import '../presenter/role_management_presenter.dart';

/// The View component of the Role Management feature.
/// Allows Super Admin to configure capability rules, add, rename, or delete roles.
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
  List<RolePermissionModel> _rolesPermissions = const [];
  final List<AppCapability> _capabilities = AppCapability.defaultCapabilities;

  // Track expanded card in detailed list view
  String? _expandedRoleId;

  @override
  void initState() {
    super.initState();
    _bloc = RoleManagementBloc();
    _presenter = RoleManagementPresenter(view: this, bloc: _bloc);
    _presenter.load();
    _expandedRoleId = 'circleChair'; // Default expand first system role
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- RoleManagementViewContract Implementations ---

  @override
  void onRoleManagementLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  @override
  void onRoleManagementLoaded() {
    setState(() {
      _isLoading = false;
      _rolesPermissions = _bloc.state.rolesPermissions;
    });
  }

  @override
  void onRoleManagementSaving() {
    setState(() {
      _isSaving = true;
    });
  }

  @override
  void onRoleManagementSaved() {
    setState(() {
      _isSaving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Role capabilities updated successfully!'),
          ],
        ),
        backgroundColor: Colors.green,
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
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  // --- Dialog Helpers for Adding, Editing, and Deleting Roles ---

  void _showAddRoleDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Add Custom Role',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Role Name',
              hintText: 'e.g., Regional Manager',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  _presenter.addRole(name);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditRoleDialog(RoleModel role) {
    final controller = TextEditingController(text: role.label);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Rename Role',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'New Role Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  _presenter.editRole(role.id, newName);
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteRoleDialog(RoleModel role) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Role?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Text(
            'Are you sure you want to delete the "${role.label}" role? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _presenter.deleteRole(role.id);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --- UI Widget Helpers ---

  Widget _buildDetailedRoleList() {
    if (_rolesPermissions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60.0, horizontal: 20),
          child: Column(
            children: [
              Icon(Icons.shield_outlined, color: Colors.grey.shade300, size: 64),
              const SizedBox(height: 16),
              Text(
                'No active roles found',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add a custom role using the button above to begin configuring privileges.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _rolesPermissions.length,
      itemBuilder: (context, index) {
        final rp = _rolesPermissions[index];
        final isExpanded = _expandedRoleId == rp.role.id;

        // Group capabilities by category
        final categories = <String, List<AppCapability>>{};
        for (final cap in _capabilities) {
          categories.putIfAbsent(cap.category, () => []).add(cap);
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isExpanded ? AppColors.primary : AppColors.border,
              width: isExpanded ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card Row
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedRoleId = isExpanded ? null : rp.role.id;
                  });
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: rp.role.isSystemRole
                              ? AppColors.selectionBg
                              : AppColors.successBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          rp.role.isSystemRole
                              ? Icons.security_rounded
                              : Icons.tune_rounded,
                          color: rp.role.isSystemRole
                              ? AppColors.primary
                              : AppColors.success,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    rp.role.label,
                                    style: const TextStyle(
                                      color: AppColors.text,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (rp.role.isSystemRole)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300, width: 0.8),
                                    ),
                                    child: Text(
                                      'SYSTEM',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${rp.enabledCapabilityIds.length} of ${_capabilities.length} capabilities enabled',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit/Delete options for all roles
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20, color: Colors.blueAccent),
                        onPressed: () => _showEditRoleDialog(rp.role),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Colors.redAccent),
                        onPressed: () => _showDeleteRoleDialog(rp.role),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1, color: AppColors.border),
                ...categories.entries.map((categoryGroup) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Category Title
                      Container(
                        color: AppColors.background,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text(
                          categoryGroup.key.toUpperCase(),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Capabilities within this category
                      ...categoryGroup.value.map((cap) {
                        final isEnabled =
                            rp.enabledCapabilityIds.contains(cap.id);
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          title: Text(
                            cap.name,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              cap.description,
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                          trailing: Switch(
                            value: isEnabled,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor:
                                AppColors.primary.withValues(alpha: 0.15),
                            inactiveThumbColor: Colors.grey.shade400,
                            inactiveTrackColor: Colors.grey.shade200,
                            onChanged: (val) {
                              _presenter.toggleCapability(rp.role.id, cap.id);
                            },
                          ),
                        );
                      }),
                    ],
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSaveBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: _isSaving ? 'Saving Configurations...' : 'Save Matrix Settings',
          onPressed: () => _presenter.saveChanges(),
          isLoading: _isSaving,
          leadingIcon: Icons.save_rounded,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RoleManagementBloc>.value(
      value: _bloc,
      child: BlocListener<RoleManagementBloc, RoleManagementState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: CustomAppBar(
            title: 'Role Settings',
            subtitle: 'Manage capabilities & edit custom roles',
            showBackButton: true,
            actions: [
              TextButton(
                onPressed: _showAddRoleDialog,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.selectionBg,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Add Role',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          body: _isLoading
              ? const CenteredLoadingIndicator()
              : SingleChildScrollView(
                  child: _buildDetailedRoleList(),
                ),
          bottomNavigationBar: _buildSaveBar(),
        ),
      ),
    );
  }
}
