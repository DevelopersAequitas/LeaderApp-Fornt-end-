import 'package:flutter_bloc/flutter_bloc.dart';
import '../model/splash_model.dart';
import 'splash_event.dart';
import 'splash_state.dart';

/// Business Logic Component for managing the Splash Screen lifecycle.
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  SplashBloc() : super(const SplashInitial()) {
    on<InitializeSplash>(_onInitializeSplash);
  }

  Future<void> _onInitializeSplash(
    InitializeSplash event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());
    try {
      // Smooth splash duration for animated intro without blocking user.
      await Future.delayed(const Duration(milliseconds: 3400));

      const model = SplashModel(
        appVersion: '1.0.0',
        brandingText: 'PEERS GLOBAL',
        minDurationMs: 3400,
      );

      emit(const SplashLoadSuccess(model));
    } catch (e) {
      emit(SplashLoadFailure(e.toString()));
    }
  }
}
