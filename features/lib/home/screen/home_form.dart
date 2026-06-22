import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../cubit/home_cubit.dart';
import '../widgets/add_fab.dart';
import '../widgets/bottom_hint.dart';
import '../widgets/checklist_view.dart';
import '../widgets/greeting_header.dart';
import '../widgets/home_background_glow.dart';
import '../widgets/home_empty_state.dart';
import '../widgets/list_switcher.dart';

/// The home screen: an active checklist with three organic states (empty / idle /
/// checking). Lists are paged with a [PageView] — swipe or tap a tab to switch,
/// with a smooth horizontal slide. Visuals mirror `.claude/specs/home/reference.html`;
/// colours come from theme tokens so it follows the app theme (dark by default).
class HomeForm extends StatefulWidget {
  const HomeForm({super.key});

  @override
  State<HomeForm> createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Tab tapped: update the highlight immediately, then glide the page over.
  void _selectTab(int index) {
    context.read<HomeCubit>().onTabSelected(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.isDarkTheme ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: color.colorBackgroundPrimary,
        body: BlocBuilder<HomeCubit, HomeState>(
          builder: (BuildContext context, HomeState state) {
            final HomeCubit cubit = context.read<HomeCubit>();
            if (state.isLoading) {
              return const Center(child: AppLoader());
            }

            final ChecklistModel? list = state.activeList;
            final bool checking = (list?.checkedCount ?? 0) > 0;

            return Stack(
              children: <Widget>[
                const HomeBackgroundGlow(),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(28, 10, 28, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        GreetingHeader(
                          list: list,
                          allDoneFlash: state.allDoneFlash,
                          onSettings: cubit.onSettingsPressed,
                        ),
                        if (!state.isEmpty && list != null) ...<Widget>[
                          if (state.lists.length > 1) ...<Widget>[
                            const SizedBox(height: 16),
                            ListSwitcher(
                              lists: state.lists,
                              activeIndex: state.activeIndex,
                              pageController: _pageController,
                              onTap: _selectTab,
                            ),
                          ],
                          Expanded(
                            child: PageView(
                              controller: _pageController,
                              onPageChanged: cubit.onTabSelected,
                              children: <Widget>[
                                for (final ChecklistModel item in state.lists)
                                  ChecklistView(
                                    key: ValueKey<String>(item.id),
                                    list: item,
                                    onItemTap: cubit.onItemTapped,
                                  ),
                              ],
                            ),
                          ),
                        ] else
                          Expanded(child: HomeEmptyState(onAdd: () => _addSoon(context))),
                      ],
                    ),
                  ),
                ),
                if (list != null)
                  Positioned(
                    bottom: 110,
                    left: 28,
                    right: 28,
                    child: IgnorePointer(
                      ignoring: !checking,
                      child: AnimatedSlide(
                        offset: checking ? Offset.zero : const Offset(0, 0.5),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        child: AnimatedOpacity(
                          opacity: checking ? 1 : 0,
                          duration: const Duration(milliseconds: 400),
                          child: BottomHint(checkedCount: list.checkedCount, total: list.total),
                        ),
                      ),
                    ),
                  ),
                if (!state.isEmpty)
                  Positioned(
                    bottom: 32,
                    right: 24,
                    child: AddFab(onTap: () => _addSoon(context)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _addSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(LocaleKeys.home_addListSoon.tr())),
    );
  }
}
