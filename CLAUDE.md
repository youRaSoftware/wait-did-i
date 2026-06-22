# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this
repository.

## Project Overview

iSales 3 Flutter application using Clean Architecture with BLoC pattern, modular workspace
structure, and multi-flavor support (Dev/Prod/Stage).

## Planning and Change Logging

### IMPORTANT: Always use planning and logging workflow

This project uses a structured approach for all development tasks:

#### Planning (PLAN.md)

- **When**: Use `EnterPlanMode` for any non-trivial implementation tasks (features, refactoring,
  multi-file changes)
- **Process**:
    1. Explore codebase to understand architecture and patterns
    2. Design implementation approach
    3. Write detailed plan to `PLAN.md`
    4. Get user approval before implementation
    5. Archive completed plans in PLAN.md with status and results
- **Benefits**: Ensures alignment, prevents wasted effort, maintains consistency with project
  architecture

#### Change Logging (CLAUDE_CHANGES.md)

- **When**: After completing each task
- **Format**: Task-based logging with all related changes
- **Required info**:
    - Task description and date
    - What was done (checkboxes: ✅ done, 🚧 in progress, ❌ cancelled)
    - All modified files with brief descriptions
    - Implementation details and architectural decisions
    - Related tasks/issues
- **Purpose**: Provides clear history of all Claude-made changes for code review and team awareness

#### Workflow

1. Receive task → Use `EnterPlanMode` (if non-trivial)
2. Explore and plan → Write to `PLAN.md`
3. Get approval → Implement changes
4. Complete task → Update `CLAUDE_CHANGES.md` with all changes
5. Archive plan in `PLAN.md` with results

## Flutter Version Management (FVM)

This project uses FVM to manage Flutter SDK versions. The configured version is **3.41.1**.

### Setup FVM

```bash
# Install FVM (if not installed)
brew tap leoafarias/fvm && brew install fvm
# OR
dart pub global activate fvm

# Install project's Flutter version
fvm install

# Use FVM Flutter for this project
fvm use 3.41.1
```

### Using FVM Commands

```bash
# Run with FVM
fvm flutter run --flavor=dev
fvm flutter pub get

# Or configure shell alias (add to ~/.zshrc or ~/.bashrc)
alias flutter="fvm flutter"
alias dart="fvm dart"

# IDE Configuration (VS Code)
# Set "dart.flutterSdkPath": ".fvm/flutter_sdk" in .vscode/settings.json

# IDE Configuration (Android Studio/IntelliJ)
# Set Flutter SDK path to: /path/to/project/.fvm/flutter_sdk
```

## Architecture

- **Clean Architecture + BLoC**: Domain, Data, and Presentation layers
- **Dependency Injection**: GetIt service locator
- **Modular Structure**: Workspace-based with separate modules for core, core_ui, navigation, data,
  domain, and features
- **Navigation**: Auto Route for declarative routing
- **State Management**: flutter_bloc with centralized router injection

## Key Development Commands

### Build and Run

```bash
flutter run --flavor=dev          # Run dev flavor
flutter run --flavor=prod         # Run prod flavor  
flutter run --flavor=stage        # Run stage flavor
```

### Code Generation and Assets

```bash
# Generate localization keys
make localization
# OR
cd core && dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations

# Generate assets (flutter_gen)
fluttergen

# Generate UI tokens from Figma
figma2flutter --input core_ui/lib/theme/generate/tokens --output core_ui/lib/theme/generate/

# Generate new feature module
make module    # Interactive prompt for module name
```

### Code Quality

```bash
# Format code (line length 120)
dart format --line-length=120 --set-exit-if-changed core core_ui data domain features lib navigation

# Analyze code
flutter analyze

# Build runner for code generation
dart run build_runner build
```

## Project Structure

### Core Modules

- **core/**: Business logic, services, DI, localization, utilities
- **core_ui/**: Reusable UI components, themes, design tokens
- **data/**: Data layer with entities, DTOs, providers, repositories
- **domain/**: Domain models, repository interfaces, services
- **navigation/**: Auto Route configuration and route observers
- **features/**: Feature modules (auth, camera, tabs) with screens and BLoCs

### Important Paths

- **Translations**: `core/resources/translations/` (en.json, ru.json)
- **Assets**: `core/resources/icons/` (SVG/PNG icons)
- **Fonts**: `core/resources/fonts/` (Montserrat font family)
- **Theme Tokens**: `core_ui/lib/theme/generate/tokens/`

## Development Guidelines

### Code Style

- **Formatter**: Line length 120, preserve trailing commas
- **Linting**: Comprehensive rules in analysis_options.yaml
- **Imports**: Prefer relative imports within modules
- **Types**: Always specify types (always_specify_types: true)
- **Constants**: Use const constructors and final fields

### Architecture Patterns

- **Screens**: Use AppScaffold base widget
- **Forms**: Separate screen widgets contain BlocProviders, layout in Form widgets
- **File Organization**: One widget per file
- **BLoC Navigation**: Router injected via DI, no BuildContext needed
- **Data Flow**: Providers → Repositories → Services → BLoCs

### Feature Folder Structure (REQUIRED)

Every feature under `features/lib/<feature>/` MUST follow this layout:

```
features/lib/<feature>/
  screen/
    <feature>_screen.dart   # StatelessWidget: BlocProvider<Cubit>(create: ... appLocator<Dep>()) → <Feature>Form
    <feature>_form.dart      # Layout: Scaffold/AppScaffold + BlocBuilder<Cubit, State>
  cubit/
    <feature>_cubit.dart     # Cubit<State>, deps via constructor, `part '<feature>_state.dart';`
    <feature>_state.dart      # `part of`, Equatable, fields + copyWith + props
  widgets/                    # ONLY if there are screen-specific widgets worth extracting
    <some_block>.dart
```

Rules:
- `*_screen.dart` only wires the BlocProvider + dependencies (from `appLocator`) and returns the Form. No layout.
- `*_form.dart` holds all layout inside a `BlocBuilder`/`BlocConsumer`. Reads cubit via `context.read<Cubit>()`.
- Cubit dependencies (repositories/services) are injected through the constructor; the screen resolves them from `appLocator`.
- Navigation lives in the cubit via `appLocator<AppRouter>().router` — never `BuildContext` navigation.
- Extract reusable per-screen pieces into `widgets/`; don't inline large blocks in the Form.
- Export each feature's `*_screen.dart` from `features/lib/features.dart` (alphabetical).

### Localization (REQUIRED)

- **No hardcoded user-facing strings.** Every visible string goes through
  `LocaleKeys.<key>.tr()` (from `package:core/core.dart`).
- Add the key to BOTH `core/resources/translations/en-US.json` and `ru-RU.json`
  (same key set), then regenerate keys:
  `cd core && dart run easy_localization:generate -f keys -o locale_keys.g.dart -O lib/localization -S resources/translations`
- Group keys by feature: `onboarding.*`, `home.*`, `settings.*`, shared in `common.*`.

### Key Conventions

- **Flavors**: Support dev/prod/stage environments
- **Localization**: EasyLocalization with generated keys in locale_keys.g.dart
- **Assets**: flutter_gen generates typed asset references
- **Error Handling**: Centralized error handling with custom exceptions

### Camera Feature

- Custom camera implementation with panorama and horizon level capabilities
- Grid position and metadata capture
- Photo metadata tracking with geolocation

### Pre-commit Hook

Create `.git/hooks/pre-commit`:

```bash
#!/bin/sh
dart format --line-length=100 --set-exit-if-changed core core_ui data domain features lib navigation
flutter analyze
```

## Dependencies

- **State Management**: flutter_bloc, equatable
- **Networking**: dio with custom interceptors
- **Database**: Hive (local storage)
- **Maps**: yandex_maps_mapkit_lite
- **Camera**: camera with sensors_plus for horizon level
- **Localization**: easy_localization
- **Navigation**: auto_route
- **UI**: flutter_screenutil for responsive design
