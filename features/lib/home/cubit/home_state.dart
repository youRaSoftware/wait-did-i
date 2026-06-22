part of 'home_cubit.dart';

class HomeState extends Equatable {
  final bool isLoading;
  final List<ChecklistModel> lists;
  final int activeIndex;

  /// True for the brief "all clear" celebration after the last item is checked.
  final bool allDoneFlash;

  const HomeState({
    this.isLoading = true,
    this.lists = const <ChecklistModel>[],
    this.activeIndex = 0,
    this.allDoneFlash = false,
  });

  bool get isEmpty => lists.isEmpty;

  ChecklistModel? get activeList {
    if (lists.isEmpty) return null;
    return lists[activeIndex.clamp(0, lists.length - 1)];
  }

  HomeState copyWith({
    bool? isLoading,
    List<ChecklistModel>? lists,
    int? activeIndex,
    bool? allDoneFlash,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      lists: lists ?? this.lists,
      activeIndex: activeIndex ?? this.activeIndex,
      allDoneFlash: allDoneFlash ?? this.allDoneFlash,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, lists, activeIndex, allDoneFlash];
}
