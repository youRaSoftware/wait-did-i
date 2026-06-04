import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

import '../cubit/home_cubit.dart';
import '../widgets/home_empty_state.dart';

class HomeForm extends StatelessWidget {
  const HomeForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ITokens tokens = context.currentTokens;
    final ColorTokens color = tokens.color;
    final TextStyleTokens textStyle = tokens.textStyle;

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (BuildContext context, HomeState state) {
        final HomeCubit cubit = context.read<HomeCubit>();

        return AppScaffold(
          showBackButton: false,
          title: Text(
            LocaleKeys.home_greeting.tr(),
            style: textStyle.title.copyWith(color: color.colorTextPrimary),
          ),
          actions: <Widget>[
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: cubit.onSettingsPressed,
              child: AppImage(
                image: AppAssets.resourcesIconsOutlineGear,
                width: AppDimens.size24,
                height: AppDimens.size24,
                color: color.colorTextPrimary,
              ),
            ),
          ],
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: AppCircleButton(
            style: AppCircleButtonStyle.primary,
            icon: AppImage(
              image: AppAssets.resourcesIconsOutlinePlus,
              width: AppDimens.size28,
              height: AppDimens.size28,
              color: color.colorTextInverse,
            ),
            onPressed: () {
              cubit.onCreateListPressed();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocaleKeys.home_createSoon.tr())),
              );
            },
          ),
          body: _buildBody(state),
        );
      },
    );
  }

  Widget _buildBody(HomeState state) {
    if (state.isLoading) {
      return const Center(child: AppLoader());
    }
    if (!state.hasLists) {
      return const HomeEmptyState();
    }
    // TODO: render the list of checklist cards.
    return const SizedBox.shrink();
  }
}
