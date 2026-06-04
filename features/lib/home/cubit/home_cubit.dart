import 'package:core/core.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> init() async {
    emit(state.copyWith(isLoading: true));
    // TODO: load lists from local storage once the model/repository exists.
    emit(state.copyWith(isLoading: false, lists: const <String>[]));
  }

  void onSettingsPressed() {
    appLocator<AppRouter>().router.push(RouterConstants.settingsRoute);
  }

  void onCreateListPressed() {
    // TODO: open the create-list flow.
  }
}
