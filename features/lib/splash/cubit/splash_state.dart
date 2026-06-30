part of 'splash_cubit.dart';

/// The splash has no mutable UI state — the animation runs on a local controller
/// and navigation is a one-shot side effect. Kept for the screen/form/cubit layout.
class SplashState extends Equatable {
  const SplashState();

  @override
  List<Object?> get props => <Object?>[];
}
