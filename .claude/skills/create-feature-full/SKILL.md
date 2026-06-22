---
name: create-feature-full
description: "RVACH Flutter project skill for creating a complete feature with BOTH data layer (Firestore / Cloud Functions) AND UI screens together. Triggers when user asks to: create a full feature with data and screens, сделать полную фичу, создать фичу с данными и экранами, фичу от и до, фичу целиком, build a feature end to end — AND names real data (Firestore collections, Cloud Functions, document fields) AND mentions screens/UI. Creates: domain model, repository interface, DTO with fromFirestore, mapper, repository impl (cloud_firestore + http→Cloud Functions), DI registration, domain service singleton, state, cubit, screen, form, go_router route. Do NOT trigger when user only needs UI with mock data / backend not ready (use create-feature-ui), asks for a reusable widget (use create-widget), or only needs the data layer because screens already exist (follow this skill's Data Layer section manually, don't run the full pipeline)."
argument-hint: "[feature_name] [firestore_collections | cloud_functions] [screens]"
---

# Create Full Feature (Data Layer + UI)

Use when: both the data layer (Firestore collections / Cloud Functions) and UI screens need to be created together.

## REQUIRED READING — do this BEFORE generating any UI code

Read **`.claude/shared/ui_reference.md`** in full. It contains the design system (colors, typography, spacing, icons), composition rules, localization API, and code style — all of which apply to every screen, form, and widget in this feature. Do not skip this step. Do not paraphrase from memory. The file is the source of truth and may have been updated since this skill was last loaded.

## Template

```
Create full feature: {feature_name}
Data: {Firestore collections + fields | Cloud Function endpoints}
Screens: {list of screens}

Follow RVACH full feature patterns.
```

## How RVACH talks to the backend (read before writing data code)

There is **no client-side REST API layer** in this app. `DioConfig` is a registered placeholder pointing at `example.com` — do not build on it. The real chain:

```
football-data.org v4 → Cloud Functions (functions/src/index.ts: axios, onSchedule sync jobs, Firestore triggers) → Firestore
→ [app] RepositoryImpl (cloud_firestore snapshots/get/set, or package:http → onRequest Cloud Function)
→ DTO.fromFirestore (sanitizeFirestoreNumbers + @TimestampConverter) → Mapper.toModel → freezed Domain Model
→ Domain Service singleton (ValueNotifier cache) → Cubit (_safeEmit, stream subs) → Equatable State
→ Screen (BlocProvider) → Form (BlocBuilder)
```

Two remote channels from the app:

1. **Direct Firestore** (`cloud_firestore`) — the default for all app data. Reads, writes, and real-time `snapshots()` streams. Existing collections: `matches`, `predictions`, `users`, `leagues` (doubles as both football competition docs and user tournament leagues — there is no separate `competitions` collection), `seasons`, `teams`, `achievements`, `globalLeaderboards/{competitionId}/entries`, etc.
2. **HTTP Cloud Functions via `package:http`** — for on-demand server work (hydration, account actions). Base URL `https://europe-west1-rvach-app.cloudfunctions.net`, plain `http.get/post` (no `cloud_functions` package). See `data/lib/repositories/match_repository_impl.dart` → `fetchMatchDetails`.

The football API (`football-data.org v4`) is **server-side only** — the Flutter app never calls it. If the feature needs new football data, it must first land in Firestore via a Cloud Function (sync job in `functions/src/index.ts`), then the app reads Firestore.

Local storage (`hive_ce`) is used **only for pre-auth prefs** (onboarding done, favorite team) via `data/lib/providers/hive/`. New features almost never need a Hive provider — all live data is Firestore streams.

## Creation Order

1. Domain model (`domain/lib/models/{feature}/{name}_model.dart`) + export from `domain/lib/models/models.dart`
2. Domain repository interface (`domain/lib/repositories/{name}_repository.dart`) + export from `repositories.dart`
3. DTO (`data/lib/dto/{feature}/{name}_dto.dart`) + export from `data/lib/dto/dto.dart`
4. Mapper (`data/lib/mappers/{name}_mapper.dart` — flat folder) + export from `data/lib/mappers/mappers.dart`
5. Repository implementation (`data/lib/repositories/{name}_repository_impl.dart`) + export from `repositories.dart`
6. DI registration (`data/lib/di/data_di.dart` → `_initRepositories()`)
7. Service (`domain/lib/service/{name}_service.dart`) + export from `domain/lib/service/services.dart` + DI registration
8. State (`features/lib/{feature}/cubit/{feature}_state.dart` — `part of`)
9. Cubit (`features/lib/{feature}/cubit/{feature}_cubit.dart`)
10. Screen (`features/lib/{feature}/screen/{feature}_screen.dart`)
11. Form (`features/lib/{feature}/screen/{feature}_form.dart`)
12. Barrel export (`features/lib/features.dart` — screen + cubit)
13. Route (`navigation/lib/src/app_router/router_constants.dart` + `app_router.dart`)
14. If a NEW Firestore collection is introduced: security rules in `firestore.rules`, composite indexes in `firestore.indexes.json`

---

## Data Layer

### Domain Model (`domain/lib/models/{feature}/`)

Freezed model with `fromJson`. Add `const Model._();` only when the model needs instance methods / getters (business logic lives here — see `PredictionModel.calculatePoints` in `domain/lib/models/prediction/prediction_model.dart`).

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_model.freezed.dart';

part 'feature_model.g.dart';

@freezed
abstract class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    required String id,
    required String userId,
    required String name,
    @Default(0) int points,
    DateTime? createdAt,
  }) = _FeatureModel;

  const FeatureModel._();

  factory FeatureModel.fromJson(Map<String, dynamic> json) => _$FeatureModelFromJson(json);

  bool get hasPoints => points > 0;
}
```

Export from `domain/lib/models/models.dart` (keep the alphabetical/commented grouping).

### Domain Repository Interface (`domain/lib/repositories/`)

Plain abstract class. Firestore features expose BOTH one-shot `Future` reads AND real-time `Stream watch...` methods — screens are live streams in RVACH.

```dart
import '../models/feature/feature_model.dart';

abstract class FeatureRepository {
  Future<FeatureModel?> getItem(String id);

  Future<List<FeatureModel>> getUserItems(String userId);

  Future<void> saveItem(FeatureModel item);

  Future<void> deleteItem(String id);

  Stream<List<FeatureModel>> watchUserItems(String userId);
}
```

### DTO (`data/lib/dto/{feature}/`)

DTOs are organised **per feature** (`data/lib/dto/prediction/`, `data/lib/dto/match/`, ...), one folder per feature, no direction subfolders. Freezed + json_serializable with TWO factories: `fromJson` and `fromFirestore`. Firestore docs carry `Timestamp` values and occasionally non-finite numbers, so:

- every `DateTime` field gets `@TimestampConverter()` (`data/lib/dto/converters/timestamp_converter.dart`);
- `fromFirestore` always pipes through `sanitizeFirestoreNumbers(...)` (`data/lib/dto/converters/firestore_sanitizer.dart`) and injects `doc.id` as `id`.

Real example — `data/lib/dto/prediction/prediction_dto.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../converters/firestore_sanitizer.dart';
import '../converters/timestamp_converter.dart';

part 'feature_dto.freezed.dart';

part 'feature_dto.g.dart';

@freezed
abstract class FeatureDto with _$FeatureDto {
  const factory FeatureDto({
    required String id,
    required String userId,
    required String name,
    @Default(0) int points,
    @TimestampConverter() DateTime? createdAt,
  }) = _FeatureDto;

  factory FeatureDto.fromJson(Map<String, dynamic> json) => _$FeatureDtoFromJson(json);

  factory FeatureDto.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final Map<String, dynamic> data = doc.data()!;
    return FeatureDto.fromJson(
      sanitizeFirestoreNumbers(<String, dynamic>{
        'id': doc.id,
        ...data,
      }),
    );
  }
}
```

- `@Default(...)` only for **non-nullable** fields (safe fallback when the document omits the field). Don't add `@Default(null)` for nullable fields.
- Firestore field names are camelCase in this project — no `FieldRename.snake`, no `@JsonKey(name:)` unless a document field genuinely diverges from the Dart name.
- Enum-valued fields are stored as **plain `String`** in the DTO (`@Default('scheduled') String status`) — parsing to a domain enum happens in the mapper, not the DTO. See `data/lib/dto/match/match_dto.dart`.
- Export the DTO from `data/lib/dto/dto.dart`.

### Mapper (`data/lib/mappers/{name}_mapper.dart`)

Mappers live in a **flat folder** — `data/lib/mappers/prediction_mapper.dart`, `match_mapper.dart`, etc. Abstract class, static methods only. Three directions: `toModel`, `toDto`, `toFirestore` (drop `id` — it's the document id, not a field).

Real example — `data/lib/mappers/prediction_mapper.dart`:

```dart
import 'package:domain/domain.dart';

import '../dto/feature/feature_dto.dart';

abstract class FeatureMapper {
  static FeatureModel toModel(FeatureDto dto) {
    return FeatureModel(
      id: dto.id,
      userId: dto.userId,
      name: dto.name,
      points: dto.points,
      createdAt: dto.createdAt,
    );
  }

  static FeatureDto toDto(FeatureModel model) {
    return FeatureDto(
      id: model.id,
      userId: model.userId,
      name: model.name,
      points: model.points,
      createdAt: model.createdAt,
    );
  }

  static Map<String, dynamic> toFirestore(FeatureModel model) {
    return toDto(model).toJson()..remove('id');
  }
}
```

Enum parsing lives in the mapper (pattern from `data/lib/mappers/match_mapper.dart`):

```dart
static MatchStatus _parseMatchStatus(String status) {
  return MatchStatus.values.firstWhere(
    (MatchStatus e) => e.name == status,
    orElse: () => MatchStatus.scheduled,
  );
}
// writing back: status: model.status.name
```

Export from `data/lib/mappers/mappers.dart`.

### Repository Implementation (`data/lib/repositories/`)

Constructor takes an **optional** `FirebaseFirestore?` (defaults to `FirebaseFirestore.instance`) so DI can register with `.new` and tests can inject a fake. No `appLocator` inside repos.

**Channel 1 — direct Firestore** (real example: `data/lib/repositories/prediction_repository_impl.dart`):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:domain/domain.dart';

import '../dto/feature/feature_dto.dart';
import '../mappers/feature_mapper.dart';

class FeatureRepositoryImpl implements FeatureRepository {
  final FirebaseFirestore _firestore;

  FeatureRepositoryImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _itemsCollection => _firestore.collection('featureItems');

  @override
  Future<FeatureModel?> getItem(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _itemsCollection.doc(id).get();

    if (!doc.exists || doc.data() == null) return null;

    return FeatureMapper.toModel(FeatureDto.fromFirestore(doc));
  }

  @override
  Future<void> saveItem(FeatureModel item) async {
    await _itemsCollection.doc(item.id).set(
          FeatureMapper.toFirestore(item),
          SetOptions(merge: true),
        );
  }

  @override
  Stream<List<FeatureModel>> watchUserItems(String userId) {
    return _itemsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
              .map(
                (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                    FeatureMapper.toModel(FeatureDto.fromFirestore(doc)),
              )
              .toList(),
        );
  }
}
```

**Channel 2 — HTTP Cloud Function** (real example: `data/lib/repositories/match_repository_impl.dart` → `fetchMatchDetails`):

```dart
import 'dart:convert';

import 'package:http/http.dart' as http;

class FeatureRepositoryImpl implements FeatureRepository {
  final String _functionsBaseUrl;

  FeatureRepositoryImpl({
    String? functionsBaseUrl,
  }) : _functionsBaseUrl = functionsBaseUrl ?? 'https://europe-west1-rvach-app.cloudfunctions.net';

  Future<void> hydrateItem(String id) async {
    final Uri url = Uri.parse('$_functionsBaseUrl/getFeatureItem?id=$id');
    final http.Response response = await http.get(url);

    if (response.statusCode != 200) {
      throw AppException('Failed to fetch item: ${response.statusCode}');
    }

    final Map<String, dynamic> data = json.decode(response.body) as Map<String, dynamic>;

    if (data['success'] != true) {
      throw AppException(data['error']?.toString() ?? 'Item not found');
    }
    // Cloud Functions write the canonical doc into Firestore — re-read via
    // the Firestore channel instead of parsing the function response.
  }
}
```

Error contract: repos throw `AppException` (`domain/lib/error_handler/app_exception.dart` — `const AppException(this.message, {this.code})`). For one-shot Firestore reads that must survive flaky networks, wrap in `retryOnTransientFirestoreError(() => ..., debugLabel: '...')` from `data/lib/services/firestore_retry.dart` (exponential backoff on `unavailable` / `deadline-exceeded` / `internal` / `aborted` / `cancelled`; see usage in `user_repository_impl.dart`).

Export the impl from `data/lib/repositories/repositories.dart`.

### DI Registration (`data/lib/di/data_di.dart`)

Two scope functions exist:
- `preLoginScope()` — runs from `setupUnAuthScope()` before authentication: `_configureFirestore()`, `_initHive()`, `_initProviders()`, `_initRepositories()`. **All current repositories and services are registered here.**
- `postLoginScope()` — runs from `goToAuthScope()` after login; currently empty, use it only for deps that genuinely require an authenticated session.

Add to `_initRepositories()` (keep the commented grouping):

```dart
// Feature
appLocator.registerLazySingleton<FeatureRepository>(
  FeatureRepositoryImpl.new,
);

// ...and with the domain services at the bottom of _initRepositories():
appLocator.registerLazySingleton<FeatureService>(() => FeatureService.instance);
```

### Service (`domain/lib/service/`)

Mandatory whenever a cubit needs data. Cubits never touch repositories directly — they call services via `Service.instance`. The service holds the repository (`appLocator<FeatureRepository>()`) and is the place for cross-cubit shared state: a `ValueNotifier` cache fanned out from the watch stream (pattern from `domain/lib/service/prediction_service.dart`).

```dart
import 'package:core/core.dart';
import 'package:flutter/foundation.dart';

import '../domain.dart';

class FeatureService {
  final FeatureRepository _repository = appLocator<FeatureRepository>();

  FeatureService._internal();

  static FeatureService get instance => _instance;
  static final FeatureService _instance = FeatureService._internal();

  /// `itemId → FeatureModel` cache for the signed-in user.
  final ValueNotifier<Map<String, FeatureModel>> userItems = ValueNotifier<Map<String, FeatureModel>>(
    <String, FeatureModel>{},
  );

  Future<List<FeatureModel>> getUserItems(String userId) => _repository.getUserItems(userId);

  Future<void> saveItem(FeatureModel item) async {
    await _repository.saveItem(item);
    userItems.value = <String, FeatureModel>{
      ...userItems.value,
      item.id: item,
    };
  }

  /// Re-emits the Firestore stream and fans values out to [userItems]
  /// so non-stream readers see the latest map synchronously.
  Stream<List<FeatureModel>> watchUserItems(String userId) {
    return _repository.watchUserItems(userId).map((List<FeatureModel> list) {
      userItems.value = <String, FeatureModel>{
        for (final FeatureModel item in list) item.id: item,
      };
      return list;
    });
  }

  void clear() {
    userItems.value = <String, FeatureModel>{};
  }
}
```

Lifecycle:
- per-user warm-up / cleanup hooks run through `AuthBootstrap` (`features/lib/services/auth_bootstrap.dart`), wired in `lib/main_common.dart` via `AuthService.onPostLogin` / `AuthService.onLogout`;
- `clear()` is the logout reset — call it from `AuthBootstrap.onLogout` if the service caches user data.

Reference existing services in `domain/lib/service/` — `AuthService`, `PredictionService`, `MatchService`, `CompetitionService`, `LeagueService`, `SeasonsService`, etc. Export from `domain/lib/service/services.dart`.

### Enums

Two homes, both real:

- **Domain data enums** (values stored in Firestore docs) → `domain/lib/models/enums/{name}.dart`, exported from `domain/lib/models/enums/enums.dart`. Plain Dart enums with bool getters; the DTO keeps the raw `String`, the mapper parses via `firstWhere(..., orElse: ...)` on `e.name`:

```dart
enum FeatureStatus {
  active,
  archived;

  bool get isActive => this == FeatureStatus.active;
}
```

(Real examples: `MatchStatus`, `MatchStage`, `LeagueStatus`, `AuthErrorCode`.)

- **UI / tab enums** (no persistence) → `domain/lib/enums/{name}.dart`, exported from `domain/lib/enums/enums.dart` (real examples: `TournamentTabType`, `AvatarPermissionType`). Both barrels are re-exported by `domain/lib/domain.dart` / `models.dart` — no codegen needed for enums.

---

## Presentation Layer

### State (`features/lib/{feature}/cubit/{feature}_state.dart`)

State is a **separate file** that's `part of '{feature}_cubit.dart'`. Extends `Equatable`, non-nullable collections with `const` defaults, manual `copyWith`, `ValueGetter<T?>?` for nullable fields, all fields in `props`. Boolean flags (`isLoading`, `isSaving`) + `String? errorMessage` — no status enums, no sealed states.

```dart
part of 'feature_cubit.dart';

class FeatureState extends Equatable {
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;
  final List<FeatureModel> items;

  const FeatureState({
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.items = const <FeatureModel>[],
  });

  FeatureState copyWith({
    bool? isLoading,
    bool? isSaving,
    ValueGetter<String?>? errorMessage,
    List<FeatureModel>? items,
  }) {
    return FeatureState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => <Object?>[isLoading, isSaving, errorMessage, items];
}
```

### Cubit (`features/lib/{feature}/cubit/{feature}_cubit.dart`)

#### Rule: No dependencies in the constructor except route params

Cubits grab services as **final field initializers** via `Service.instance` and the router via `appLocator<AppRouter>()` inline. The constructor declares ONLY route params (`required this.matchId`) — no router injection, no repository injection, no service injection.

❌ **Wrong** — repository or service injected:

```dart
FeatureCubit({required FeatureRepository repository}) : _repository = repository, super(const FeatureState());
```

✅ **Right** — services via `.instance`, only route params in the constructor (real example: `MatchDetailCubit({required this.matchId})`):

```dart
final FeatureService _featureService = FeatureService.instance;
final AuthService _authService = AuthService.instance;
final String itemId;

FeatureCubit({required this.itemId}) : super(const FeatureState());
```

#### Rule: `_safeEmit` guard

Every cubit defines and uses a guard instead of raw `emit` — Firestore streams keep delivering after `close()`:

```dart
void _safeEmit(FeatureState next) {
  if (isClosed) return;
  super.emit(next);
}
```

#### Rule: register Firestore streams with `FirestoreLifecycleManager`

Any cubit that holds `snapshots()` subscriptions registers pause/resume callbacks in `init()` and disposes them in `close()` (real pattern: `PredictionsCubit`, `CreateTournamentCubit`). On app pause all listeners are cancelled before Firestore `terminate()`; on resume they re-subscribe.

#### Rule: double-catch error handling

`on AppException catch (e)` → `errorMessage: () => e.message`; then `catch (e)` → `errorMessage: e.toString`. Stream `onError` callbacks set `errorMessage` too. When a method sets `isSaving`/`isLoading` around an awaited call, the reset lives in `finally`.

#### Rule: toasts for action feedback

`ToastService` (`core/lib/service/toast_service.dart`, fluttertoast) needs a `BuildContext`, so cubit methods that show toasts take `BuildContext` as a parameter (real example: `CreateTournamentCubit.copyCode`):

```dart
ToastService().init(context).showToast(
      message: successMessage,
      toastType: ToastType.success, // success | error | warning; default error
    );
```

Load/save errors that aren't tied to a user action go into `state.errorMessage` and render as `MascotMessage` in the form instead.

#### Rule: navigation via DI-injected go_router

```dart
void onBack() {
  appLocator<AppRouter>().router.pop();
}

// elsewhere:
appLocator<AppRouter>().router.go(RouterConstants.authRoute);
appLocator<AppRouter>().router.push('/user/$userId');
```

#### Full template

```dart
import 'dart:async';

import 'package:core/core.dart';
import 'package:data/data.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';

part 'feature_state.dart';

class FeatureCubit extends Cubit<FeatureState> {
  final FeatureService _featureService = FeatureService.instance;
  final AuthService _authService = AuthService.instance;

  StreamSubscription<List<FeatureModel>>? _itemsSubscription;

  void Function()? _disposeLifecycle;

  FeatureCubit() : super(const FeatureState());

  void _safeEmit(FeatureState next) {
    if (isClosed) return;
    super.emit(next);
  }

  Future<void> init() async {
    _safeEmit(state.copyWith(isLoading: true));

    _disposeLifecycle = FirestoreLifecycleManager.instance.register(
      onPause: _pauseStreams,
      onResume: _resumeStreams,
    );

    _subscribeToFirestore();
  }

  void _subscribeToFirestore() {
    if (_itemsSubscription != null) return;
    final String? userId = _authService.currentUserId;
    if (userId == null) return;

    _itemsSubscription = _featureService.watchUserItems(userId).listen(
      (List<FeatureModel> items) {
        _safeEmit(state.copyWith(items: items, isLoading: false));
      },
      onError: (Object error) {
        _safeEmit(state.copyWith(isLoading: false, errorMessage: () => error.toString()));
      },
    );
  }

  void _pauseStreams() {
    _itemsSubscription?.cancel();
    _itemsSubscription = null;
  }

  void _resumeStreams() {
    _subscribeToFirestore();
  }

  Future<void> onSave(FeatureModel item) async {
    _safeEmit(state.copyWith(isSaving: true, errorMessage: () => null));
    try {
      await _featureService.saveItem(item);
    } on AppException catch (e) {
      _safeEmit(state.copyWith(errorMessage: () => e.message));
    } catch (e) {
      _safeEmit(state.copyWith(errorMessage: e.toString));
    } finally {
      _safeEmit(state.copyWith(isSaving: false));
    }
  }

  void onBack() {
    appLocator<AppRouter>().router.pop();
  }

  @override
  Future<void> close() {
    _disposeLifecycle?.call();
    _itemsSubscription?.cancel();
    return super.close();
  }
}
```

### Screen (`features/lib/{feature}/screen/{feature}_screen.dart`)

Plain `StatelessWidget` — **no route annotations, no codegen**. Thin `BlocProvider` shell with `..init()`; layout lives in the Form.

```dart
import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'feature_form.dart';

class FeatureScreen extends StatelessWidget {
  const FeatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeatureCubit>(
      create: (BuildContext context) => FeatureCubit()..init(),
      child: const FeatureForm(),
    );
  }
}
```

If the screen takes route params, declare them as public final fields and forward into the cubit constructor (real example: `features/lib/match_detail/screen/match_detail_screen.dart`):

```dart
class FeatureDetailScreen extends StatelessWidget {
  final String itemId;

  const FeatureDetailScreen({
    required this.itemId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FeatureDetailCubit>(
      create: (BuildContext context) => FeatureDetailCubit(itemId: itemId)..init(),
      child: const FeatureDetailForm(),
    );
  }
}
```

Export both screen and cubit from `features/lib/features.dart` — `app_router.dart` resolves screens through that barrel.

### Form (`features/lib/{feature}/screen/{feature}_form.dart`)

Loading / empty / error / content states. Pull tokens at the top of `build`. Pushed screens use `AppScaffold`; tab-root forms may use plain `Scaffold` + `SafeArea` with bg `colors.grey1a` (see `predictions_form.dart`). Loading = `AppLoader` or a feature skeleton built from `ShimmerBox`; empty/error = `MascotMessage` (sad mascot + retry `AppButton`). Real reference: `features/lib/statistics/screen/statistics_form.dart`.

```dart
import 'package:core/core.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

class FeatureForm extends StatelessWidget {
  const FeatureForm({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorTokens colors = context.currentTokens.color;
    final TextStyleTokens textStyles = context.currentTokens.textStyle;

    return AppScaffold(
      title: Text(
        context.tr(LocaleKeys.featureName_title),
        style: textStyles.headings18pxBlack.copyWith(color: colors.whiteWhite),
      ),
      applyTopPadding: true,
      onBack: context.read<FeatureCubit>().onBack,
      body: BlocBuilder<FeatureCubit, FeatureState>(
        builder: (BuildContext context, FeatureState state) {
          if (state.isLoading) {
            return const AppLoader();
          }

          if (state.errorMessage != null) {
            return MascotMessage(
              mascotAsset: AppAssets.coreResourcesIconsWebpRvachMascotSad,
              message: context.tr(LocaleKeys.featureName_error),
              primaryAction: AppButton(
                onPressed: context.read<FeatureCubit>().init,
                text: context.tr(LocaleKeys.common_retry),
              ),
            );
          }

          if (state.items.isEmpty) {
            return MascotMessage(
              mascotAsset: AppAssets.coreResourcesIconsWebpRvachMascotNoTournaments,
              message: context.tr(LocaleKeys.featureName_empty),
            );
          }

          return ListView.separated(
            padding: EdgeInsets.all(AppDimens.size16),
            itemCount: state.items.length,
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(height: AppDimens.size12);
            },
            itemBuilder: (BuildContext context, int index) {
              final FeatureModel item = state.items[index];
              return Text(
                item.name,
                style: textStyles.texts16pxMedium.copyWith(color: colors.whiteWhite),
              );
            },
          );
        },
      ),
    );
  }
}
```

Note: there is **no pull-to-refresh** in RVACH — screens are live Firestore streams, and keep the loading skeleton up until data lands to avoid empty-state flashes.

### Child widgets accessing cubit

Child widgets in `widgets/` use `context.read<FeatureCubit>()` / `context.watch<FeatureCubit>().state` inside their own `build()`, NOT as constructor parameters. Pass only deps that aren't in the BLoC tree (e.g. a `TextEditingController` owned by the parent form).

### Tabs

When a screen has tabs, use the existing tab widgets from `core_ui/lib/widgets/tabs/`: `SegmentedTabBar` (equal-width segments), `HorizontalChipTabs` (scrollable chips), `StickyChipTabsHeader` (pinned chips in a sliver layout), `AppLineTabBar` (underline tabs). Tab index lives in the cubit state (`selectedTabIndex`); a `StatefulWidget` form with `TickerProviderStateMixin` (multi-ticker, required because the form disposes and recreates its `TabController` when the tab count changes) syncs its `TabController` to `state.selectedTabIndex` — see `features/lib/predictions/screen/predictions_form.dart`.

### Dialogs & bottom sheets

`AppRouter` extensions over `navigatorKey.currentContext` (`navigation/lib/src/app_router/dialog.dart`, `bottom_sheet.dart`) — callable straight from cubits, no BuildContext needed:

```dart
final bool? confirmed = await appLocator<AppRouter>().showFullScreenDialog<bool>(
  widget: const ConfirmDialog(),
);

await appLocator<AppRouter>().showBottomSheet(contentWidget: const FeatureOptionsSheet());
```

Dialog widgets compose `BaseDialogWidget`; sheet content widgets wrap themselves in `BaseBottomSheet` (see `features/lib/profile/widgets/language_bottom_sheet.dart`).

### Route (`navigation/lib/src/app_router/`)

go_router, **no codegen**. Two edits:

1. Add the path constant to `RouterConstants` (`router_constants.dart`):

```dart
static const String featureRoute = '/feature';
static const String featureDetailRoute = '/feature/:itemId';
```

2. Add a `GoRoute` in `app_router.dart` — top-level for full-screen pushes, or nested inside the right `StatefulShellBranch` (Predictions / Leaderboard / QuickPredictions / Leagues / Profile) for tab-scoped screens:

```dart
GoRoute(
  path: RouterConstants.featureDetailRoute,
  name: RouterConstants.featureDetailRoute,
  builder: (BuildContext context, GoRouterState state) {
    final String itemId = state.pathParameters['itemId']!;
    final String? title = state.uri.queryParameters['title'];
    return FeatureDetailScreen(itemId: itemId, title: title);
  },
),
```

Nested branch routes use **relative** paths (`path: 'create'` under `/leagues` — see the Leagues branch).

---

## Mock Data (when backend is not ready)

When the Firestore collection or Cloud Function isn't available yet, scaffold the UI with mocks and clearly mark the substitution (or use **create-feature-ui** if the whole data layer is out of scope).

### Model mocks

Add `static const List<Model> mocks` to the domain model (requires the `const Model._();` private constructor):

```dart
static const List<FeatureModel> mocks = <FeatureModel>[
  FeatureModel(id: '1', userId: 'u1', name: 'Mock A'),
  FeatureModel(id: '2', userId: 'u1', name: 'Mock B'),
];
```

### Cubit mock markers

```dart
// --- REAL: uncomment when Firestore collection is ready ---
// final FeatureService _featureService = FeatureService.instance;
// --- END REAL ---
```

```dart
// --- REAL: replace mock block below ---
// _itemsSubscription = _featureService.watchUserItems(userId).listen(...);
// --- END REAL ---

// --- MOCK: remove when backend is ready ---
_safeEmit(state.copyWith(items: FeatureModel.mocks, isLoading: false));
// --- END MOCK ---
```

Rules:
- `--- REAL: ... --- END REAL ---` — commented-out real code, ready to uncomment.
- `--- MOCK: ... --- END MOCK ---` — mock code to delete when the real collection/function lands.
- Keep the commented real code in sync with current architecture (update if signatures change).
- Mock save flows with `await Future<void>.delayed(...)` to simulate network latency.

---

## After Creation

Run code generation in the affected modules (freezed/json_serializable live in `domain` and `data`; features/navigation have no generated code). **No FVM** — the project is a Dart workspace, plain `flutter`/`dart` only:

```bash
cd domain && dart run build_runner build --delete-conflicting-outputs
cd data && dart run build_runner build --delete-conflicting-outputs
```

(or run `script/prebuild_script.sh`, which does pub get across all packages + build_runner in every package except features + locale keys; note it starts with `cd ../`, so invoke it from inside the `script/` directory).

If new locale keys were added (to BOTH `core/resources/translations/ru-RU.json` and `en-US.json`):

```bash
cd core && dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations
```

If a NEW Firestore collection was introduced: add rules to `firestore.rules`, composite indexes (for `where` + `orderBy` queries) to `firestore.indexes.json`, and deploy with `firebase deploy --only firestore`.

Then analyze + format the new feature folder (page width 120 comes from `analysis_options.yaml`):

```bash
flutter analyze features/lib/{feature_name}/
dart format features/lib/{feature_name}/
```

## Design System

See `.claude/shared/ui_reference.md` § 1 — Design System (colors, typography, spacing, icons & images). All UI in this feature MUST consume tokens via `context.currentTokens.*` and `AppDimens.sizeN`. NEVER use `SvgPicture.asset()` or `Image.asset()` directly — always wrap in `AppImage` (asset constants from `AppAssets`).

## Composition Rules

See `.claude/shared/ui_reference.md` § 2 — Composition Rules. In particular:
- **NO private widget classes** (`_SomeButton extends StatelessWidget`) — anywhere, regardless of size. The only `_State` allowed is the one backing a `StatefulWidget`.
- **NO widget-returning functions/methods** (`Widget _buildHeader()`, `List<Widget> _buildItems()`, `Widget _resolveContent()`).
- Two valid options for any sub-tree: **inline it inside `build()`**, or **extract it to a public widget in its own file** under `features/lib/{feature}/widgets/`. The latter only when reused in 2+ places, OR the parent file would otherwise exceed ~400 lines, OR a Form has 3+ logical sections each >50 lines.
- Child widgets read cubit/state via `context.read` / `context.watch` — do NOT pass cubit or state as constructor params.

## Localization

See `.claude/shared/ui_reference.md` § 3 — Localization. Use the feature's name as the locale namespace (e.g. `featureName_title`, or the actual name like `statistics_title`). Add keys to BOTH `ru-RU.json` and `en-US.json` (RU is the primary/fallback locale).

## Code Style

See `.claude/shared/ui_reference.md` § 4 — Code Style.
