# domain Package

Business logic layer for Tintday - models, repository interfaces, and domain services.

---

## Overview

The `domain` package contains:
- **Models** - Immutable domain entities (Freezed)
- **Repository Interfaces** - Abstract data access contracts
- **Business Services** - Domain logic and orchestration

**Key Principle**: Domain has **NO** dependencies on `data` or `features`. It defines contracts that other layers implement.

---

## Structure

```
domain/
├── lib/
│   ├── domain.dart                    # Barrel export
│   ├── models/
│   │   ├── mood/
│   │   │   ├── mood_entry_model.dart
│   │   │   └── day_mood_model.dart
│   │   └── settings/
│   │       └── user_settings_model.dart
│   ├── repositories/
│   │   ├── mood_repository.dart
│   │   └── settings_repository.dart
│   └── service/
│       ├── mood_service.dart
│       └── streak_service.dart
└── pubspec.yaml
```

---

## Models

### Conventions

1. **Suffix**: All models end with `Model` (e.g., `MoodEntryModel`)
2. **Immutable**: Use Freezed with `@freezed` annotation
3. **Named Parameters**: All fields are named with `required`
4. **Empty Factory**: Always provide `.empty()` factory
5. **Private Constructor**: Add `const ModelName._();` for extensions

### Example: MoodEntryModel

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'mood_entry_model.freezed.dart';

@freezed
abstract class MoodEntryModel with _$MoodEntryModel {
  const factory MoodEntryModel({
    required int timestamp,      // Unix timestamp (milliseconds)
    required int color,          // ARGB color value
    required double brightness,  // 0.0-1.0 (HSL lightness)
  }) = _MoodEntryModel;

  const MoodEntryModel._();

  // Factory constructors
  factory MoodEntryModel.empty() => const MoodEntryModel(
    timestamp: 0,
    color: 0xFFFFFFFF,
    brightness: 1.0,
  );

  // Extension methods (optional)
  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(timestamp);

  Color get flutterColor => Color(color);
}
```

### Creating New Models

1. Create file in `lib/models/{feature}/{model_name}_model.dart`
2. Add Freezed annotation and part directive
3. Define factory with named parameters
4. Add private constructor: `const ModelName._();`
5. Add `.empty()` factory
6. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Repository Interfaces

### Conventions

1. **Abstract Classes**: Define contracts, no implementation
2. **Suffix**: End with `Repository` (e.g., `MoodRepository`)
3. **Return Types**: Use `Future<T>` for async operations
4. **Error Handling**: Let implementation decide (no try-catch here)

### Example: MoodRepository

```dart
abstract class MoodRepository {
  /// Get all mood entries for a specific date range
  ///
  /// [startDate] - Start date in YYYY-MM-DD format
  /// [endDate] - End date in YYYY-MM-DD format
  ///
  /// Returns list of [DayMoodModel] sorted by date descending
  Future<List<DayMoodModel>> getMoodsByDateRange({
    required String startDate,
    required String endDate,
  });

  /// Save a single mood entry for today
  ///
  /// [entry] - Mood entry to save
  ///
  /// Appends to existing entries for today if any
  Future<void> saveMoodEntry({required MoodEntryModel entry});

  /// Save complete day with multiple entries
  ///
  /// [dayMood] - Day mood with all entries and calculated gradient
  Future<void> saveDayMood({required DayMoodModel dayMood});

  /// Get today's mood entries
  ///
  /// Returns [DayMoodModel] for today or null if no entries
  Future<DayMoodModel?> getTodayMood();

  /// Clear all mood data (logout, reset)
  Future<void> clearAllMoods();
}
```

### Creating Repository Interfaces

1. Create file in `lib/repositories/{feature}_repository.dart`
2. Define abstract class with method signatures
3. Add clear doc comments (what, params, returns)
4. Implementation will be in `data` package

---

## Domain Services

### Entry Point Services (God Services)

**Purpose**: Manage scopes and initialize dependent services

**Characteristics**:
- Singleton with async `initialize` getter
- Called from `app_di.dart`
- Manages auth/unauth scopes
- Initializes other services

**Example**: AuthService, AppConfigService

### Regular Services

**Purpose**: Encapsulate business logic, orchestrate operations

**Characteristics**:
- Singleton with `init()` method
- NOT called from `app_di.dart`
- Initialized by entry point service
- Has `reset()` method for cleanup

**Example**: MoodService, StreakService

### Example: StreakService

```dart
import 'package:domain/domain.dart';

class StreakService {
  StreakService._();

  static final StreakService instance = StreakService._();

  late final MoodRepository _moodRepository;

  void init() {
    _moodRepository = appLocator<MoodRepository>();
  }

  /// Calculate current streak (consecutive days with entries)
  ///
  /// Returns number of consecutive days, starting from today
  Future<int> calculateStreak() async {
    final List<DayMoodModel> recentMoods = await _moodRepository.getMoodsByDateRange(
      startDate: _getDateString(DateTime.now().subtract(Duration(days: 365))),
      endDate: _getDateString(DateTime.now()),
    );

    if (recentMoods.isEmpty) return 0;

    // Sort by date descending (newest first)
    final List<DayMoodModel> sorted = [...recentMoods]
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? previousDate;

    for (final DayMoodModel entry in sorted) {
      final DateTime currentDate = DateTime.parse(entry.date);

      if (previousDate == null) {
        // First entry (today or most recent)
        final DateTime today = DateTime.now();
        if (currentDate.year == today.year &&
            currentDate.month == today.month &&
            currentDate.day == today.day) {
          streak = 1;
          previousDate = currentDate;
        } else if (today.difference(currentDate).inDays == 1) {
          // Yesterday counts as streak start
          streak = 1;
          previousDate = currentDate;
        } else {
          break;  // Streak broken
        }
      } else {
        // Check if consecutive
        if (previousDate.difference(currentDate).inDays == 1) {
          streak++;
          previousDate = currentDate;
        } else {
          break;  // Streak broken
        }
      }
    }

    return streak;
  }

  /// Get motivational message based on streak length
  String getStreakMessage(int streak) {
    if (streak == 0) return 'Start your journey today!';
    if (streak == 1) return 'Great start! Keep it up!';
    if (streak < 7) return 'You\'re building momentum! 🔥';
    if (streak < 30) return 'You\'re on fire! Keep going! 🔥';
    if (streak < 100) return 'Incredible dedication! 🔥🔥';
    return 'Legendary streak! 🔥🔥🔥';
  }

  void reset() {
    // Clean up if needed
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
```

---

## Business Rules (Domain Logic)

Document key business rules here:

### Mood Tracking

1. **Multiple Entries Per Day**: Users can add unlimited colors per day
2. **No Default Mood**: Empty days remain empty (no neutral color)
3. **HSL Color Space**: Colors stored as HSL for better UX and gradients
4. **Gradient Calculation**: Multiple colors → LinearGradient or average color

### Premium Features

1. **Free Limit**: 30 days history
2. **Premium**: Unlimited history access
3. **HD Exports**: Premium users get 3x pixel ratio

### Streaks

1. **Consecutive Days**: Streak counts days with at least one entry
2. **Break on Miss**: Missing a single day breaks streak
3. **Yesterday Counts**: If no entry today, yesterday counts as streak start

### Date Formatting

Always use `YYYY-MM-DD` format:
```dart
String formatDate(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
```

---

## Testing Domain Layer

Domain layer should be testable **without** Flutter dependencies:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:domain/domain.dart';
import 'package:mockito/mockito.dart';

class MockMoodRepository extends Mock implements MoodRepository {}

void main() {
  group('StreakService', () {
    late StreakService streakService;
    late MockMoodRepository mockRepository;

    setUp(() {
      streakService = StreakService.instance;
      mockRepository = MockMoodRepository();
      // Inject mock
    });

    test('calculateStreak returns 0 for no entries', () async {
      when(mockRepository.getMoodsByDateRange(
        startDate: any,
        endDate: any,
      )).thenAnswer((_) async => []);

      final int streak = await streakService.calculateStreak();

      expect(streak, 0);
    });

    test('calculateStreak returns 3 for 3 consecutive days', () async {
      final List<DayMoodModel> mockData = [
        DayMoodModel(date: '2026-01-29', entries: [...], gradientColor: 0xFF...),
        DayMoodModel(date: '2026-01-28', entries: [...], gradientColor: 0xFF...),
        DayMoodModel(date: '2026-01-27', entries: [...], gradientColor: 0xFF...),
      ];

      when(mockRepository.getMoodsByDateRange(
        startDate: any,
        endDate: any,
      )).thenAnswer((_) async => mockData);

      final int streak = await streakService.calculateStreak();

      expect(streak, 3);
    });
  });
}
```

---

## Dependencies

```yaml
dependencies:
  freezed_annotation: ^latest
  core:
    path: ../core

dev_dependencies:
  build_runner: ^latest
  freezed: ^latest
  flutter_test:
    sdk: flutter
  mockito: ^latest
```

---

## Best Practices

1. ✅ **Keep domain pure** - No Flutter UI dependencies
2. ✅ **Models are immutable** - Always use Freezed
3. ✅ **Repositories are contracts** - No implementation in domain
4. ✅ **Services orchestrate** - Combine repository calls, apply business rules
5. ✅ **Document business rules** - Clear comments on why, not what
6. ✅ **Test without UI** - Domain should be unit-testable
