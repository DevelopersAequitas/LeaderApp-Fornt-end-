import 'package:equatable/equatable.dart';

class MaintenanceState extends Equatable {
  final bool isChecking;
  final bool isMaintenanceActive;
  final String maintenanceTitle;
  final String maintenanceMessage;
  final bool canBypass;
  final bool isBypassed;
  final bool isCleared;
  final String errorMessage;

  const MaintenanceState({
    this.isChecking = false,
    this.isMaintenanceActive = true,
    this.maintenanceTitle = 'Under Scheduled Maintenance',
    this.maintenanceMessage =
        'We are currently performing scheduled system upgrades to serve you better. Please check back shortly.',
    this.canBypass = false,
    this.isBypassed = false,
    this.isCleared = false,
    this.errorMessage = '',
  });

  MaintenanceState copyWith({
    bool? isChecking,
    bool? isMaintenanceActive,
    String? maintenanceTitle,
    String? maintenanceMessage,
    bool? canBypass,
    bool? isBypassed,
    bool? isCleared,
    String? errorMessage,
  }) {
    return MaintenanceState(
      isChecking: isChecking ?? this.isChecking,
      isMaintenanceActive: isMaintenanceActive ?? this.isMaintenanceActive,
      maintenanceTitle: maintenanceTitle ?? this.maintenanceTitle,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
      canBypass: canBypass ?? this.canBypass,
      isBypassed: isBypassed ?? this.isBypassed,
      isCleared: isCleared ?? this.isCleared,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        isChecking,
        isMaintenanceActive,
        maintenanceTitle,
        maintenanceMessage,
        canBypass,
        isBypassed,
        isCleared,
        errorMessage,
      ];
}
