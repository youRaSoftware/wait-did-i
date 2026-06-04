import 'package:core/core.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  void onBackPressed() {
    appLocator<AppRouter>().router.pop();
  }
}
