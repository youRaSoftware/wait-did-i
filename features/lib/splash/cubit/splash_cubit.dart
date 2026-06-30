import 'package:core/core.dart';

part 'splash_state.dart';

/// Drives the launch splash: once the wordmark intro finishes it routes onward
/// to onboarding (first launch) or home, mirroring the router's first-launch gate.
class SplashCubit extends Cubit<SplashState> {
  final OnboardingService _onboardingService;
  bool _navigated = false;

  SplashCubit({required OnboardingService onboardingService})
    : _onboardingService = onboardingService,
      super(const SplashState());

  /// Called once when the wordmark animation completes.
  void proceed() {
    if (_navigated) {
      return;
    }
    _navigated = true;
    final String target = _onboardingService.isCompleted ? RouterConstants.homeRoute : RouterConstants.onboardingRoute;
    appLocator<AppRouter>().router.go(target);
  }
}
