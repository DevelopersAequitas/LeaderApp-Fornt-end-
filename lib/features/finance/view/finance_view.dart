import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/widgets/widgets.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_state.dart';
import '../model/finance_model.dart';
import '../presenter/finance_presenter.dart';
import 'widgets/commission_settings_bottom_sheet.dart';
// import 'widgets/finance_action_buttons.dart';
import 'widgets/finance_chart_section.dart';
import 'widgets/finance_commission_rates.dart';
import 'widgets/finance_commission_structure.dart';
import 'widgets/finance_metrics_grid.dart';
import 'widgets/finance_restricted_view.dart';
import 'widgets/record_payment_bottom_sheet.dart';

/// The View component of the Finance tab feature.
class FinanceView extends StatefulWidget {
  final String? selectedCircle;
  const FinanceView({super.key, this.selectedCircle});

  @override
  State<FinanceView> createState() => _FinanceViewState();
}

class _FinanceViewState extends State<FinanceView>
    implements FinanceViewContract {
  late final FinanceBloc _bloc;
  late final FinancePresenter _presenter;

  bool _isLoading = false;
  FinancePermissionModel? _permission;
  FinanceMetricsModel? _metrics;

  @override
  void initState() {
    super.initState();
    _bloc = FinanceBloc();
    _presenter = FinancePresenter(view: this, bloc: _bloc);
    _presenter.load(selectedCircle: widget.selectedCircle);
  }

  @override
  void didUpdateWidget(covariant FinanceView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCircle != oldWidget.selectedCircle) {
      _presenter.load(selectedCircle: widget.selectedCircle);
    }
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  // --- FinanceViewContract Implementations ---

  @override
  void onFinanceLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void onFinanceLoaded() {
    setState(() {
      _isLoading = false;
      _permission = _bloc.state.permission;
      _metrics = _bloc.state.metrics;
    });
  }

  @override
  void onFinanceError(String error) {
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error), backgroundColor: Colors.redAccent),
    );
  }

  void _showRecordOfflinePaymentModal() {
    RecordPaymentBottomSheet.show(
      context,
      selectedCircle: widget.selectedCircle,
      onPaymentRecorded: () {
        _presenter.load(selectedCircle: widget.selectedCircle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Offline payment recorded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: onFinanceError,
    );
  }

  void _showCommissionSettingsModal() {
    CommissionSettingsBottomSheet.show(
      context,
      onRatesUpdated: () {
        _presenter.load(selectedCircle: widget.selectedCircle);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Commission rates updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      onError: onFinanceError,
    );
  }

  Widget _buildFounderFinanceView() {
    final role = SessionManager().currentRole;
    final hideCommissionRates =
        role == UserRole.industryDirector ||
        role == UserRole.countryDirector ||
        role == UserRole.superAdmin;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // FinanceActionButtons(
        //   onRecordPaymentTap: _showRecordOfflinePaymentModal,
        //   onCommissionSetupTap: _showCommissionSettingsModal,
        // ),
        if (_metrics != null) ...[
          FinanceMetricsGrid(metrics: _metrics!),
          FinanceChartSection(metrics: _metrics!),
          if (!hideCommissionRates)
            FinanceCommissionRates(rates: _metrics!.commissionRates),
          FinanceCommissionStructure(structure: _metrics!.commissionStructure),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceBloc>.value(
      value: _bloc,
      child: BlocListener<FinanceBloc, FinanceState>(
        listener: (context, state) {
          _presenter.handleStateChange(state);
        },
        child: _isLoading || _permission == null
            ? const CenteredLoadingIndicator(height: 300)
            : _permission!.isRestricted
            ? FinanceRestrictedView(permission: _permission!)
            : _buildFounderFinanceView(),
      ),
    );
  }
}
