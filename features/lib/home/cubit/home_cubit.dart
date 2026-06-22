import 'dart:async';

import 'package:core/core.dart';
import 'package:domain/domain.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required ChecklistRepository repository}) : _repository = repository, super(const HomeState());

  final ChecklistRepository _repository;

  /// Holds the brief "all clear" greeting for ~3s after the last item is checked.
  Timer? _allDoneTimer;

  Future<void> load() async {
    _safeEmit(state.copyWith(isLoading: true));
    await _repository.seedDefaultsIfNeeded();
    final List<ChecklistModel> lists = await _repository.loadLists();
    _safeEmit(state.copyWith(isLoading: false, lists: lists));
  }

  void onTabSelected(int index) {
    if (index == state.activeIndex) return;
    _allDoneTimer?.cancel();
    _safeEmit(state.copyWith(activeIndex: index, allDoneFlash: false));
  }

  Future<void> onItemTapped(String itemId) async {
    final ChecklistModel? list = state.activeList;
    if (list == null) return;
    unawaited(HapticService.lightImpact());

    final ChecklistModel updated = await _repository.toggleItem(listId: list.id, itemId: itemId);
    final List<ChecklistModel> lists = List<ChecklistModel>.of(state.lists);
    final int index = lists.indexWhere((ChecklistModel l) => l.id == updated.id);
    if (index != -1) lists[index] = updated;

    final bool nowAllDone = updated.allDone;
    _safeEmit(state.copyWith(lists: lists, allDoneFlash: nowAllDone));

    _allDoneTimer?.cancel();
    if (nowAllDone) {
      _allDoneTimer = Timer(
        const Duration(seconds: 3),
        () => _safeEmit(state.copyWith(allDoneFlash: false)),
      );
    }
  }

  void onSettingsPressed() => appLocator<AppRouter>().router.push(RouterConstants.settingsRoute);

  void _safeEmit(HomeState next) {
    if (!isClosed) emit(next);
  }

  @override
  Future<void> close() {
    _allDoneTimer?.cancel();
    return super.close();
  }
}
