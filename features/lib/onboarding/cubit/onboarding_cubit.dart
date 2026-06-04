import 'package:core/core.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final OnboardingService _onboardingService;

  OnboardingCubit({required OnboardingService onboardingService})
    : _onboardingService = onboardingService,
      super(const OnboardingState());

  void onPageChanged(int index) {
    emit(state.copyWith(currentIndex: index));
  }

  /// Marks onboarding done and goes to home (used by both "Начать" and "Пропустить").
  Future<void> finish() async {
    await _onboardingService.complete();
    appLocator<AppRouter>().router.go(RouterConstants.homeRoute);
  }
}
