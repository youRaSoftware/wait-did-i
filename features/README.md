# features Package

Presentation layer for Tintday - screens, forms, cubits, and feature-specific widgets.

---

## Overview

The `features` package contains all UI screens and state management for the application.

**Key Pattern**: Clean Architecture presentation layer with BLoC/Cubit for state management.

---

## Structure

```
features/
├── lib/
│   ├── features.dart                   # Barrel export + AutoRoute config
│   ├── mood_picker/
│   │   ├── cubit/
│   │   │   ├── mood_picker_cubit.dart
│   │   │   └── mood_picker_state.dart
│   │   ├── screen/
│   │   │   ├── mood_picker_screen.dart      # BlocProvider wrapper
│   │   │   └── mood_picker_form.dart        # Pure UI
│   │   └── widgets/
│   │       ├── color_wheel_painter.dart
│   │       └── brightness_slider.dart
│   ├── stats/
│   │   ├── cubit/
│   │   ├── screen/
│   │   └── widgets/
│   └── settings/
│       ├── cubit/
│       ├── screen/
│       └── widgets/
└── pubspec.yaml
```

---

## Feature Structure

Each feature follows this structure:

### 1. Cubit (State Management)

**File**: `{feature}/cubit/{feature}_cubit.dart`

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:domain/domain.dart';
import '{feature}_state.dart';

class MoodPickerCubit extends Cubit<MoodPickerState> {
  MoodPickerCubit({
    required MoodRepository moodRepository,
  })  : _moodRepository = moodRepository,
        super(MoodPickerState(
          todayMood: DayMoodModel.empty(),
        ));

  final MoodRepository _moodRepository;

  /// Load today's mood entries
  Future<void> loadTodayMood() async {
    emit(state.copyWith(isLoading: true));

    try {
      final DayMoodModel? todayMood = await _moodRepository.getTodayMood();
      emit(state.copyWith(
        isLoading: false,
        todayMood: todayMood ?? DayMoodModel.empty(),
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  /// Add color to today's palette (not saved yet)
  void addColor(Color color, double brightness) {
    final MoodEntryModel newEntry = MoodEntryModel(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      color: color.value,
      brightness: brightness,
    );

    final List<MoodEntryModel> updatedEntries = [
      ...state.todayMood.entries,
      newEntry,
    ];

    emit(state.copyWith(
      todayMood: state.todayMood.copyWith(entries: updatedEntries),
    ));
  }

  /// Save all today's colors
  Future<void> saveTodayMood() async {
    if (state.todayMood.entries.isEmpty) return;

    emit(state.copyWith(isSaving: true));

    try {
      // Calculate gradient color (average for storage)
      final int gradientColor = _calculateGradientColor(
        state.todayMood.entries,
      );

      final DayMoodModel updatedDay = state.todayMood.copyWith(
        date: _getTodayDateString(),
        gradientColor: gradientColor,
      );

      await _moodRepository.saveDayMood(dayMood: updatedDay);

      emit(state.copyWith(
        isSaving: false,
        isSaved: true,
        todayMood: DayMoodModel.empty(),  // Clear after save
      ));

      // Reset saved flag after animation
      await Future.delayed(Duration(seconds: 2));
      emit(state.copyWith(isSaved: false));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        error: e.toString(),
      ));
    }
  }

  int _calculateGradientColor(List<MoodEntryModel> entries) {
    // RGB averaging
    int totalR = 0, totalG = 0, totalB = 0;

    for (final MoodEntryModel entry in entries) {
      final Color color = Color(entry.color);
      totalR += color.red;
      totalG += color.green;
      totalB += color.blue;
    }

    final int avgR = totalR ~/ entries.length;
    final int avgG = totalG ~/ entries.length;
    final int avgB = totalB ~/ entries.length;

    return Color.fromARGB(255, avgR, avgG, avgB).value;
  }

  String _getTodayDateString() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
```

### 2. State (Data Class)

**File**: `{feature}/cubit/{feature}_state.dart`

```dart
import 'package:equatable/equatable.dart';
import 'package:domain/domain.dart';

class MoodPickerState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final bool isSaved;
  final String error;
  final DayMoodModel todayMood;  // Complex model: required, init with .empty()

  const MoodPickerState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSaved = false,
    this.error = '',
    required this.todayMood,  // Must be provided, never nullable
  });

  MoodPickerState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSaved,
    String? error,
    DayMoodModel? todayMood,
  }) {
    return MoodPickerState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSaved: isSaved ?? this.isSaved,
      error: error ?? this.error,
      todayMood: todayMood ?? this.todayMood,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isSaving,
        isSaved,
        error,
        todayMood,
      ];
}
```

**State Rules**:
1. ✅ All fields non-nullable
2. ✅ Simple types (bool, String, int) use default values
3. ✅ Complex models (DayMoodModel) are `required` and initialized with `.empty()`
4. ✅ Extends `Equatable` with all fields in `props`
5. ✅ Implement `copyWith` for immutability

### 3. Screen (BlocProvider Wrapper)

**File**: `{feature}/screen/{feature}_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:domain/domain.dart';
import 'package:auto_route/auto_route.dart';
import '../cubit/mood_picker_cubit.dart';
import 'mood_picker_form.dart';

@RoutePage()
class MoodPickerScreen extends StatelessWidget {
  const MoodPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MoodPickerCubit(
        moodRepository: appLocator<MoodRepository>(),
      )..loadTodayMood(),
      child: const MoodPickerForm(),
    );
  }
}
```

**Screen Responsibilities**:
- Create and provide Cubit
- Inject dependencies via DI
- Initialize Cubit (call initial load method)
- Delegate UI to Form widget

### 4. Form (Pure UI)

**File**: `{feature}/screen/{feature}_form.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core_ui/core_ui.dart';
import '../cubit/mood_picker_cubit.dart';
import '../cubit/mood_picker_state.dart';
import '../widgets/color_wheel_painter.dart';

class MoodPickerForm extends StatelessWidget {
  const MoodPickerForm({super.key});

  @override
  Widget build(BuildContext context) {
    final MoodPickerCubit cubit = context.read<MoodPickerCubit>();
    final MoodPickerState state = context.watch<MoodPickerCubit>().state;

    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return Scaffold(
      backgroundColor: color.colorBackgroundPrimary,
      body: BlocConsumer<MoodPickerCubit, MoodPickerState>(
        listener: (context, state) {
          if (state.error.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }

          if (state.isSaved) {
            // Show success animation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Mood saved! 🎨')),
            );
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: Column(
              children: [
                _buildNavBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildColorWheel(context),
                        SizedBox(height: 24),
                        _buildBrightnessSlider(context),
                        SizedBox(height: 24),
                        _buildTodayPalette(context),
                        SizedBox(height: 24),
                        _buildAddButton(context),
                        if (state.todayMood.entries.isNotEmpty) ...[
                          SizedBox(height: 16),
                          _buildSaveButton(context),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildColorWheel(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final MoodPickerCubit cubit = context.read<MoodPickerCubit>();

    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.brandCoral.withValues(alpha: 0.4),
            blurRadius: 40,
            spreadRadius: 10,
          ),
        ],
      ),
      child: ColorWheelPicker(
        onColorChanged: (selectedColor) {
          cubit.addColor(selectedColor, 1.0);
        },
      ),
    );
  }

  // ... other build methods
}
```

**Form Responsibilities**:
- Pure UI rendering
- Listen to state changes (BlocConsumer)
- Show snackbars, dialogs (listener)
- Call Cubit methods on user interaction
- Use design tokens for all styling

### 5. Feature Widgets

**File**: `{feature}/widgets/{widget_name}.dart`

Custom widgets specific to this feature (e.g., ColorWheelPicker, BrightnessSlider).

---

## Routing

### Adding Routes

1. Add `@RoutePage()` annotation to screen:
```dart
@RoutePage()
class MoodPickerScreen extends StatelessWidget {
  // ...
}
```

2. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

3. Add route to `features.dart`:
```dart
@AutoRouterConfig()
class FeaturesModule extends $FeaturesModule {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: MoodPickerRoute.page, path: '/mood-picker'),
        AutoRoute(page: StatsRoute.page, path: '/stats'),
        // ...
      ];
}
```

### Navigation

```dart
// Push route
context.router.push(MoodPickerRoute());

// Pop
context.router.pop();

// Replace
context.router.replace(StatsRoute());
```

---

## State Management Guidelines

### Accessing Cubit and State

**Always declare at the start of build method**:

```dart
@override
Widget build(BuildContext context) {
  // Access cubit for triggering actions (doesn't rebuild on state changes)
  final MyCubit cubit = context.read<MyCubit>();

  // Access state for UI (rebuilds on state changes)
  final MyState state = context.watch<MyCubit>().state;

  // Access tokens
  final ColorTokens color = context.currentTokens.color;
  final TextStyleTokens textStyle = context.currentTokens.textStyle;

  // Now build UI using state and trigger actions via cubit
  return Column(
    children: [
      Text('Data: ${state.data}', style: textStyle.body),
      ElevatedButton(
        onPressed: () {
          cubit.loadData();  // Trigger action via cubit
        },
        child: Text('Load'),
      ),
    ],
  );
}
```

**Key Points**:
- `context.read<MyCubit>()` - Get cubit, doesn't rebuild widget
- `context.watch<MyCubit>().state` - Get state, rebuilds when state changes
- Declare both at the start of build method for clarity

### When to Use Cubit vs Bloc

**Use Cubit** (simpler):
- Most screens in Tintday
- Simple state transitions
- No complex event handling

**Use Bloc** (more complex):
- Advanced event handling
- Transformation of events (debounce, throttle)
- Complex async workflows

### State Update Pattern

```dart
// ❌ Wrong - mutating state
state.todayMood.entries.add(newEntry);
emit(state);

// ✅ Correct - copying state
emit(state.copyWith(
  todayMood: state.todayMood.copyWith(
    entries: [...state.todayMood.entries, newEntry],
  ),
));
```

### Loading States

```dart
Future<void> loadData() async {
  emit(state.copyWith(isLoading: true));  // Start loading

  try {
    final data = await repository.getData();
    emit(state.copyWith(isLoading: false, data: data));  // Success
  } catch (e) {
    emit(state.copyWith(isLoading: false, error: e.toString()));  // Error
  }
}
```

---

## Testing Features

### Testing Cubits

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:features/mood_picker/cubit/mood_picker_cubit.dart';

class MockMoodRepository extends Mock implements MoodRepository {}

void main() {
  group('MoodPickerCubit', () {
    late MoodPickerCubit cubit;
    late MockMoodRepository mockRepository;

    setUp(() {
      mockRepository = MockMoodRepository();
      cubit = MoodPickerCubit(moodRepository: mockRepository);
    });

    tearDown(() {
      cubit.close();
    });

    blocTest<MoodPickerCubit, MoodPickerState>(
      'loadTodayMood emits loading then success',
      build: () => cubit,
      act: (cubit) async {
        when(mockRepository.getTodayMood()).thenAnswer(
          (_) async => DayMoodModel.empty(),
        );
        await cubit.loadTodayMood();
      },
      expect: () => [
        MoodPickerState(isLoading: true, todayMood: DayMoodModel.empty()),
        MoodPickerState(isLoading: false, todayMood: DayMoodModel.empty()),
      ],
    );
  });
}
```

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^latest
  equatable: ^latest
  auto_route: ^latest
  core:
    path: ../core
  core_ui:
    path: ../core_ui
  domain:
    path: ../domain
  navigation:
    path: ../navigation

dev_dependencies:
  build_runner: ^latest
  auto_route_generator: ^latest
  bloc_test: ^latest
  mockito: ^latest
```

---

## Best Practices

1. ✅ **Screen/Form separation** - BlocProvider in screen, UI in form
2. ✅ **States non-nullable** - Use defaults or `.empty()` factories
3. ✅ **Immutable updates** - Always use `copyWith`
4. ✅ **Loading/error states** - Handle all async states
5. ✅ **Access tokens** - `context.currentTokens.color`, `context.currentTokens.textStyle`
6. ✅ **Access state** - `context.read<MyCubit>()` for actions, `context.watch<MyCubit>().state` for UI
7. ✅ **Named parameters** - All constructor parameters
8. ✅ **Explicit types** - NO `var`
9. ✅ **One widget per file** - For reusable components
