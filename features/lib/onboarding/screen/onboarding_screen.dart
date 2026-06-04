import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../cubit/onboarding_cubit.dart';
import 'onboarding_form.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>(
      create: (BuildContext context) => OnboardingCubit(
        onboardingService: appLocator<OnboardingService>(),
      ),
      child: const OnboardingForm(),
    );
  }
}
