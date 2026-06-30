import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../cubit/splash_cubit.dart';
import 'splash_form.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>(
      create: (BuildContext context) => SplashCubit(
        onboardingService: appLocator<OnboardingService>(),
      ),
      child: const SplashForm(),
    );
  }
}
