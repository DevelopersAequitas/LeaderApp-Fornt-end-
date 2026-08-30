import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/helpers/session_manager.dart';
import '../../../core/services/app_config_service.dart';
import 'maintenance_event.dart';
import 'maintenance_state.dart';

class MaintenanceBloc extends Bloc<MaintenanceEvent, MaintenanceState> {
  final AppConfigService _configService;
  final SessionManager _sessionManager;

  MaintenanceBloc({
    AppConfigService? configService,
    SessionManager? sessionManager,
  })  : _configService = configService ?? AppConfigService(),
        _sessionManager = sessionManager ?? SessionManager(),
        super(const MaintenanceState()) {
    on<CheckMaintenanceStatus>(_onCheckMaintenanceStatus);
    on<BypassMaintenanceEvent>(_onBypassMaintenance);
  }

  bool _computeCanBypass() {
    final config = _configService.config;
    final currentRole = _sessionManager.currentRole;
    final isSuperAdmin = currentRole == UserRole.superAdmin;
    return isSuperAdmin ||
        config.allowedBypassRoles.any(
          (r) => r.toLowerCase().replaceAll('_', '') == currentRole.name.toLowerCase().replaceAll('_', ''),
        );
  }

  Future<void> _onCheckMaintenanceStatus(
    CheckMaintenanceStatus event,
    Emitter<MaintenanceState> emit,
  ) async {
    emit(state.copyWith(isChecking: true, errorMessage: ''));

    try {
      final config = await _configService.fetchAppConfig();
      final canBypass = _computeCanBypass();

      if (!config.isMaintenanceMode) {
        emit(
          state.copyWith(
            isChecking: false,
            isMaintenanceActive: false,
            isCleared: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isChecking: false,
            isMaintenanceActive: true,
            maintenanceTitle: config.maintenanceTitle.isNotEmpty
                ? config.maintenanceTitle
                : state.maintenanceTitle,
            maintenanceMessage: config.maintenanceMessage.isNotEmpty
                ? config.maintenanceMessage
                : state.maintenanceMessage,
            canBypass: canBypass,
            isCleared: false,
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          isChecking: false,
          errorMessage: 'Unable to verify server status: $e',
        ),
      );
    }
  }

  void _onBypassMaintenance(
    BypassMaintenanceEvent event,
    Emitter<MaintenanceState> emit,
  ) {
    if (state.canBypass || _computeCanBypass()) {
      emit(state.copyWith(isBypassed: true));
    }
  }
}
