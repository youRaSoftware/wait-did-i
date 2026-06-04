part of 'home_cubit.dart';

class HomeState extends Equatable {
  final bool isLoading;

  /// Placeholder until a checklist model/repository exists.
  final List<String> lists;

  const HomeState({
    this.isLoading = true,
    this.lists = const <String>[],
  });

  bool get hasLists => lists.isNotEmpty;

  HomeState copyWith({
    bool? isLoading,
    List<String>? lists,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      lists: lists ?? this.lists,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, lists];
}
