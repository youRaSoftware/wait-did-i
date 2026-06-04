part of 'onboarding_cubit.dart';

class OnboardingState extends Equatable {
  final int currentIndex;
  final int totalSteps;

  const OnboardingState({
    this.currentIndex = 0,
    this.totalSteps = 3,
  });

  bool get isLast => currentIndex == totalSteps - 1;

  OnboardingState copyWith({
    int? currentIndex,
    int? totalSteps,
  }) {
    return OnboardingState(
      currentIndex: currentIndex ?? this.currentIndex,
      totalSteps: totalSteps ?? this.totalSteps,
    );
  }

  @override
  List<Object?> get props => <Object?>[currentIndex, totalSteps];
}
