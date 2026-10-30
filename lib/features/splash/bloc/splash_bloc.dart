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
      // Smooth splash duration matching splash.json animation (~2.7s).
      await Future.delayed(const Duration(milliseconds: 2700));

      const model = SplashModel(
        appVersion: '1.0.0',
        brandingText: 'PEERS LEADERS',
        minDurationMs: 2700,
      );

      emit(const SplashLoadSuccess(model));
    } catch (e) {
      emit(SplashLoadFailure(e.toString()));
    }
  }
}
