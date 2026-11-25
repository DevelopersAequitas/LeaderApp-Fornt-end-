import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../peers/model/peer_model.dart';

/// MD3 modal bottom sheet for assigning Circle officers and committee leaders
/// (Chair, Vice Chair, Secretary, Committee Leader).
class AssignCircleRoleBottomSheet extends StatefulWidget {
  final List<PeerModel> peers;
  final void Function({
    required String userId,
    required String role,
    String? committeeName,
  })
  onSubmit;

  const AssignCircleRoleBottomSheet({
    super.key,
    required this.peers,
    required this.onSubmit,
  });

  static Future<void> show(
    BuildContext context, {
    required List<PeerModel> peers,
    required void Function({
      required String userId,
      required String role,
      String? committeeName,
    })
    onSubmit,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          AssignCircleRoleBottomSheet(peers: peers, onSubmit: onSubmit),
    );
  }

  @override
  State<AssignCircleRoleBottomSheet> createState() =>
      _AssignCircleRoleBottomSheetState();
}

class _AssignCircleRoleBottomSheetState
    extends State<AssignCircleRoleBottomSheet> {
  static const List<MapEntry<String, String>> _roleOptions = [
    MapEntry('chair', 'Circle Chair'),
    MapEntry('chair_business_growth_committee', 'Chair - Business Growth'),
    MapEntry('chair_membership_growth_committee', 'Chair - Membership Growth'),
    MapEntry('chair_events_impacts_committee', 'Chair - Events & Impacts'),
    MapEntry('vice_chair', 'Vice Chair'),
    MapEntry('secretary', 'Secretary'),
    MapEntry('committee_leader', 'Committee Leader'),
  ];

  String? _selectedPeerId;
  String _selectedRole = 'chair';
  final TextEditingController _committeeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.peers.isNotEmpty) {
      _selectedPeerId = widget.peers.first.id;
    }
  }

  @override
  void dispose() {
    _committeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Assign Circle Officer / Role',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 14),
              if (widget.peers.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'No active circle peers loaded yet. Pull to refresh peers first.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedPeerId,
                  decoration: const InputDecoration(
                    labelText: 'Eligible Circle Peer',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.peers
                      .map(
                        (p) => DropdownMenuItem<String>(
                          value: p.id,
                          child: Text(
                            p.name.isNotEmpty ? p.name : p.company,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedPeerId = val),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Leadership Role',
                    border: OutlineInputBorder(),
                  ),
                  items: _roleOptions
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e.key,
                          child: Text(e.value),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                if (_selectedRole == 'committee_leader') ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _committeeController,
                    decoration: const InputDecoration(
                      labelText: 'Committee Name (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                ElevatedButton(
                  onPressed: _selectedPeerId == null
                      ? null
                      : () {
                          widget.onSubmit(
                            userId: _selectedPeerId!,
                            role: _selectedRole,
                            committeeName: _committeeController.text.trim(),
                          );
                          Navigator.of(context).pop();
                        },
                  child: const Text('Assign Role'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
