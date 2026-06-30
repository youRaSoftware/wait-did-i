import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cubit/splash_cubit.dart';
import '../widgets/splash_background_glow.dart';
import '../widgets/splash_colors.dart';
import '../widgets/splash_wordmark.dart';

/// Dark launch splash: "WAIT, DID I..?" assembles, holds, then scatters for a
/// few seconds, after which the cubit routes onward.
class SplashForm extends StatefulWidget {
  const SplashForm({super.key});

  @override
  State<SplashForm> createState() => _SplashFormState();
}

class _SplashFormState extends State<SplashForm> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 3000),
        )..addStatusListener((AnimationStatus status) {
          if (status == AnimationStatus.completed) {
            context.read<SplashCubit>().proceed();
          }
        });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: SplashColors.bg,
        body: BlocBuilder<SplashCubit, SplashState>(
          builder: (BuildContext context, SplashState state) {
            return Stack(
              children: <Widget>[
                const SplashBackgroundGlow(),
                Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (BuildContext context, Widget? child) {
                      return SplashWordmark(progress: _controller.value);
                    },
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
