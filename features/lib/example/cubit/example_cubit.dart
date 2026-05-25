import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:navigation/navigation.dart';

part 'example_state.dart';

class ExampleCubit extends Cubit<ExampleState> {
  final ExampleService exampleService = ExampleService.instance;

  ExampleCubit() : super(ExampleState(example: ExampleModel.empty())) {
    onInit();
  }

  // Example navigation method:
  // void navigateToDetails() {
  //   appLocator<AppRouter>().router.push(RouterConstants.detailsRoute);
  // }

  Future<void> onInit() async {
    await loadExample();
  }

  Future<void> loadExample() async {
    try {
      emit(state.copyWith(isLoading: true, clearErrorMessage: true));
      final ExampleModel example = await exampleService.getExample();
      emit(
        state.copyWith(
          isLoading: false,
          example: example,
        ),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error loading example', e, stackTrace);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
