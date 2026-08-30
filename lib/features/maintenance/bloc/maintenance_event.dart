import 'package:equatable/equatable.dart';

abstract class MaintenanceEvent extends Equatable {
  const MaintenanceEvent();

  @override
  List<Object?> get props => [];
}

class CheckMaintenanceStatus extends MaintenanceEvent {
  const CheckMaintenanceStatus();
}

class BypassMaintenanceEvent extends MaintenanceEvent {
  const BypassMaintenanceEvent();
}
