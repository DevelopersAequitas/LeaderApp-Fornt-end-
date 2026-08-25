import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/finance_repository.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../model/finance_model.dart';
import 'finance_event.dart';
import 'finance_state.dart';

/// Business Logic Component for managing Finance analytics and permissions via Clean Architecture.
class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final FinanceRepository _financeRepository;

  FinanceBloc({FinanceRepository? financeRepository})
      : _financeRepository = financeRepository ?? FinanceRepositoryImpl(),
        super(const FinanceState()) {
    on<LoadFinanceData>(_onLoadFinanceData);
  }

  Future<void> _onLoadFinanceData(LoadFinanceData event, Emitter<FinanceState> emit) async {
    if (state.metrics == null) {
      emit(state.copyWith(isLoading: true, errorMessage: ''));
    }

    final session = SessionManager().currentSession;
    final permissions = SessionManager().permissions;
    final isRestricted = !permissions.canAccessFinanceTab && session.role == UserRole.circleChair;

    final permissionModel = FinancePermissionModel(
      role: session.customRoleLabel ?? session.role.label,
      isRestricted: isRestricted,
      requiredCapabilities: const [
        'Access Financial Analytics',
        'View Transaction Summaries',
      ],
    );

    if (isRestricted) {
      emit(
        state.copyWith(
          isLoading: false,
          permission: permissionModel,
        ),
      );
      return;
    }

    final activeCircle = event.selectedCircle ?? state.selectedCircle ?? '';

    try {
      final metricsResponse = await _financeRepository.getFinanceMetrics(circleId: activeCircle);

      emit(
        state.copyWith(
          isLoading: false,
          permission: permissionModel,
          metrics: metricsResponse.data,
          selectedCircle: activeCircle,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
    }
  }
}
