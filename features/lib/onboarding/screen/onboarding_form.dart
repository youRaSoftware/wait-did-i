import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cubit/onboarding_cubit.dart';
import '../slides/slide_falling_cards.dart';
import '../slides/slide_night_house.dart';
import '../slides/slide_polaroid.dart';
import '../widgets/onboarding_background_glow.dart';
import '../widgets/onboarding_colors.dart';
import '../widgets/onboarding_cta_button.dart';
import '../widgets/onboarding_motion.dart';
import '../widgets/onboarding_page_dots.dart';
import '../widgets/onboarding_progress_bar.dart';

/// Three animated dark slides; swipe or tap to advance. Visuals/timings mirror
/// `.claude/specs/onboarding/reference.html`; flow keeps our cubit + go_router + OnboardingService.
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

  void _onCta(OnboardingState state) {
    if (state.isLast) {
      context.read<OnboardingCubit>().finish();
      return;
    }
    _controller.nextPage(duration: OnboardingMotion.pageTransition, curve: OnboardingMotion.fadeCurve);
  }

  void _skip(OnboardingState state) {
    _controller.animateToPage(
      state.totalSteps - 1,
      duration: OnboardingMotion.pageTransition,
      curve: OnboardingMotion.fadeCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final OnboardingCubit cubit = context.read<OnboardingCubit>();
    final double topInset = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: OnboardingColors.bgPrimary,
        body: BlocBuilder<OnboardingCubit, OnboardingState>(
          builder: (BuildContext context, OnboardingState state) {
            final int current = state.currentIndex;
            return Stack(
              children: <Widget>[
                const OnboardingBackgroundGlow(),
                PageView(
                  controller: _controller,
                  onPageChanged: cubit.onPageChanged,
                  children: <Widget>[
                    SlideFallingCards(isActive: current == 0),
                    SlidePolaroid(isActive: current == 1),
                    SlideNightHouse(isActive: current == 2),
                  ],
                ),
                // Top: progress + skip.
                Positioned(
                  top: topInset + 16,
                  left: 28,
                  right: 28,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: OnboardingProgressBar(progress: (current + 1) / state.totalSteps),
                      ),
                      const SizedBox(width: 16),
                      AnimatedOpacity(
                        opacity: state.isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: state.isLast,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _skip(state),
                            child: Text(LocaleKeys.onboarding_skip.tr(), style: OnboardingText.skip),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Bottom: dots + CTA.
                Positioned(
                  bottom: 50,
                  left: 0,
                  right: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      OnboardingPageDots(current: current, total: state.totalSteps),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: OnboardingCtaButton(
                          label: state.isLast
                              ? LocaleKeys.onboarding_getStarted.tr()
                              : LocaleKeys.onboarding_continueLabel.tr(),
                          onTap: () => _onCta(state),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
