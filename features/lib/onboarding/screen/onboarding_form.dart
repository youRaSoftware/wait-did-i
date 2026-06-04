import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/onboarding_cubit.dart';
import '../widgets/onboarding_dots.dart';
import '../widgets/onboarding_step_view.dart';

/// Static per-step content: a placeholder icon + localization keys.
const List<OnboardingStepData> _steps = <OnboardingStepData>[
  OnboardingStepData(
    icon: AppAssets.resourcesIconsOutlineBell,
    titleKey: LocaleKeys.onboarding_step1Title,
    subtitleKey: LocaleKeys.onboarding_step1Subtitle,
  ),
  OnboardingStepData(
    icon: AppAssets.resourcesIconsOutlineCheckCircle,
    titleKey: LocaleKeys.onboarding_step2Title,
    subtitleKey: LocaleKeys.onboarding_step2Subtitle,
  ),
  OnboardingStepData(
    icon: AppAssets.resourcesIconsOutlineHouse,
    titleKey: LocaleKeys.onboarding_step3Title,
    subtitleKey: LocaleKeys.onboarding_step3Subtitle,
  ),
];

class OnboardingForm extends StatefulWidget {
  const OnboardingForm({super.key});

  @override
  State<OnboardingForm> createState() => _OnboardingFormState();
}

class _OnboardingFormState extends State<OnboardingForm> {
  final PageController _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onNext(OnboardingState state) {
    if (state.isLast) {
      context.read<OnboardingCubit>().finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.padding24),
          child: BlocBuilder<OnboardingCubit, OnboardingState>(
            builder: (BuildContext context, OnboardingState state) {
              final OnboardingCubit cubit = context.read<OnboardingCubit>();

              return Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerRight,
                    child: Opacity(
                      opacity: state.isLast ? 0 : 1,
                      child: AppButton(
                        text: LocaleKeys.onboarding_skip.tr(),
                        style: AppButtonStyle.text,
                        isExpanded: false,
                        onPressed: state.isLast ? null : cubit.finish,
                      ),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _steps.length,
                      onPageChanged: cubit.onPageChanged,
                      itemBuilder: (BuildContext context, int i) => OnboardingStepView(step: _steps[i]),
                    ),
                  ),
                  OnboardingDots(
                    count: state.totalSteps,
                    currentIndex: state.currentIndex,
                  ),
                  const SizedBox(height: AppDimens.size24),
                  AppButton(
                    text: state.isLast ? LocaleKeys.onboarding_start.tr() : LocaleKeys.onboarding_next.tr(),
                    onPressed: () => _onNext(state),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
