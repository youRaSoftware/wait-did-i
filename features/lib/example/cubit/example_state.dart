part of 'example_cubit.dart';

class ExampleState extends Equatable {
  const ExampleState({
    this.isLoading = false,
    this.errorMessage = '',
    required this.example,
  });

  final bool isLoading;
  final String errorMessage;
  final ExampleModel example;

  ExampleState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    ExampleModel? example,
  }) {
    return ExampleState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? '' : (errorMessage ?? this.errorMessage),
      example: example ?? this.example,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, errorMessage, example];
}
