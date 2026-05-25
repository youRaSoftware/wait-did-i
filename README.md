# wait_did_i

A calm home checklist app that helps you remember if you locked the door, turned off the stove, and closed the windows — with optional photo proof.

**JIRA Project:** WDIDI

## Table of Contents

- [Architecture](#architecture)
- [Supported Flavors](#supported-flavors)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Setup](#setup)
- [Development](#development)
- [Code Generation](#code-generation)
- [Assets & Localization](#assets--localization)
- [Build & Run](#build--run)
- [Code Style](#code-style)

## Architecture

**Clean Architecture + BLoC Pattern**

- **Dependency Injection**: GetIt
- **Domain Layer**: Models, repositories (interfaces), services
- **Data Layer**: DTOs, mappers from DTOs to domain models, repository implementations, providers
- **Presentation Layer (Features)**: Screens + BLoC/Cubit

## Supported Flavors

- **Dev** - Development environment
- **Staging** - Staging environment
- **Prod** - Production environment

Set flavor via environment variable: `--dart-define=environment=[flavor]`

## Project Structure

The project uses **Flutter workspace** with multiple packages:

```
root/
├── core/                      # Core module
│   ├── lib/
│   │   ├── localization/      # Localization
│   │   ├── di/                # Dependency injection
│   │   ├── config/            # App configuration
│   │   ├── service/           # Platform services
│   │   └── utils/             # Utility functions
│   └── resources/
│       ├── fonts/             # Font files
│       ├── icons/             # Icons (SVG/PNG)
│       └── translations/      # Translation files
│
├── core_ui/                   # UI components
│   └── lib/
│       ├── theme/             # App theme, design tokens
│       └── widgets/            # Reusable UI widgets
│
├── data/                      # Data layer
│   └── lib/
│       ├── dto/               # Data Transfer Objects
│       ├── mappers/           # DTO to Model mappers
│       ├── providers/          # Data providers (API, local storage)
│       └── repositories/      # Repository implementations
│
├── domain/                    # Domain layer
│   └── lib/
│       ├── models/            # Domain models (Freezed)
│       ├── repositories/      # Repository interfaces
│       └── service/           # Business logic services
│
├── features/                  # Feature modules (presentation layer)
│   └── lib/
│       └── [feature_name]/    # Feature modules
│           ├── cubit/         # State management
│           ├── screen/        # Screens and forms
│           └── widgets/       # Feature-specific widgets
│
├── navigation/                # Navigation
│   └── lib/
│       └── src/
│           ├── app_router/    # Router configuration
│           └── services/      # Navigation services
│
├── lib/                       # Main application directory
│   ├── main.dart             # Entry point
│   ├── main_common.dart     # Common initialization
│   └── app.dart             # App configuration
│
├── scripts/                   # Build and utility scripts
│   ├── gen_locale.sh         # Generate localization keys
│   ├── gen_proto.sh          # Generate protobuf files (if used)
│   └── [other_scripts].sh
│
├── analysis_options.yaml     # Linter settings
├── pubspec.yaml             # Main dependencies file
└── README.md                # This file
```

**Modules**: `core`, `core_ui`, `navigation`, `data`, `domain`, `features`

For presentation layer, every feature (screen) is organized as a separate module within `features/`.

## Prerequisites

- Flutter SDK >= 3.32.0
- Dart SDK >= 3.8.0
- IDE (VS Code / Android Studio / IntelliJ)
- For iOS: XCode, CocoaPods
- For Android: Android Studio, Android SDK

### ⚠️ Note: FVM Compatibility

**This project uses Flutter Workspace** which is currently not supported by FVM. Please use the regular Flutter SDK directly:

```bash
flutter --version  # Ensure you have Flutter >= 3.32.0
flutter run --dart-define=environment=dev
flutter pub get
```

If you need to manage multiple Flutter versions, consider using alternatives like:
- `asdf` with flutter plugin
- Manual Flutter SDK switching
- Wait for FVM to add workspace support

## Setup

### Manual Setup

1. Install Flutter SDK (>=3.32.0) + Dart SDK (>=3.8.0)
2. Install Android Studio or VSCode
3. Install XCode (only for MacOS)
4. Install CocoaPods (only for MacOS)
5. Install Flutter and Dart plugins for IDE
6. Install XCode command line tools
7. Run `flutter doctor` and fix all issues
8. Install dependencies:
```bash
flutter pub get
```
9. Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
10. Run project:
```bash
flutter run --dart-define=environment=dev
```

## Development

### Code Development Rules

- Lint rules described in `analysis_options.yaml`
- All types must be explicit (no `var`, no implicit types)
- All fields in classes must be named parameters
- Models use Freezed with `*Model` suffix
- DTOs use `json_annotation` with `*Dto` suffix
- States are non-nullable (simple types with defaults, complex models `required`)

### Pre-commit Hook (Recommended)

Configure pre-commit hook:

1. Create file `pre-commit` (without extension) with content:
```bash
#!/bin/sh
dart format --line-length=120 --set-exit-if-changed core core_ui data domain features lib navigation
flutter analyze
```

2. Place it in `.git/hooks/` directory of the project
3. Make file executable:
```bash
chmod +x .git/hooks/pre-commit
```

## Code Generation

Run code generation after making changes to:
- Freezed models
- JSON serializable DTOs
- AutoRoute routes

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

For watch mode (during development):
```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Assets & Localization

### Assets

Assets are managed using `flutter_gen` package.

**Generate assets**:
```bash
# Install flutter_gen globally
dart pub global activate flutter_gen

# Generate assets
fluttergen
```

Assets are stored in `core/resources/` and accessed via generated `AppAssets` class.

### Localization

Localization is implemented using `EasyLocalization` service.

**Generate localization keys**:
```bash
cd core && dart run easy_localization:generate \
  -f keys \
  -o locale_keys.g.dart \
  -O lib/localization \
  -S resources/translations
```

Or use script:
```bash
./scripts/gen_locale.sh
```

Localization files are stored in `core/resources/translations/` as JSON files:
- Format: `{languageCode}-{countryCode}.json` (e.g., `ru-RU.json`, `en-US.json`)

**Usage**:
```dart
context.tr(LocaleKeys.common_next)
// or
LocaleKeys.common_next.tr()
```

### Design System

If using Figma token system:

**Generate UI tokens**:
```bash
dart pub global activate figma2flutter
figma2flutter --input core_ui/lib/theme/generate/tokens --output core_ui/lib/theme/generate/
```

Colors and frequently used constants are stored in `core_ui` module.

## Build & Run

### Development Build

```bash
# With flavor
flutter run --dart-define=environment=dev
```

### Production Build

```bash
# Android APK
flutter build apk --dart-define=environment=prod

# Android App Bundle
flutter build appbundle --dart-define=environment=prod

# iOS
flutter build ios --dart-define=environment=prod
```

## Code Style

### Formatting

- Line length: 120 characters
- Run: `dart format .`

### Linting

- Configuration: `analysis_options.yaml`
- Run: `flutter analyze`

### Key Rules

1. **All types explicit** - NO `var`, NO implicit types
2. **All fields named parameters** - In all classes
3. **Models use Freezed** - `*Model` suffix, immutable
4. **DTOs use @Default** - `*Dto` suffix, all fields non-nullable
5. **States non-nullable** - Simple types with defaults, complex models `required`
6. **One file = one widget** - For UI components
7. **Screen vs Form pattern** - Separate BlocProvider and UI

## Architecture Details

### Abstractions for Data Sources

- **Providers**: Responsible for specific services (e.g., HTTP provider, local provider)
  - Use data layer DTOs
  - Do not have abstract base classes
- **Repositories**: Responsible for gathering data from providers and mapping to domain models
  - Have abstract base classes in domain layer
  - Implementations in data layer

### Presentation Layer Abstractions

- Base and frequently used widgets are stored in `core_ui` module
- Base widget for screens: `AppScaffold` (if used)
- **Screen vs Form Pattern**: `CustomScreen` → `CustomForm`
  - Screen widget contains BlocProviders
  - Layout implementation is located in Form
- Navigation is implemented using AutoRoute
- Navigation on BLoC event is done from the BLoC object itself without BuildContext
- Router is stored in DI container and injected in BLoC via constructor

### Approach for Working with UI

- **One file = one widget**
- Screen widget contains BlocProviders
- Layout implementation is located in Form

### Asynchrony Support

Flutter Async (Future, Stream, async/await)

## Supported Platforms

- **Mobile**: iOS and Android

## Troubleshooting

### Code Generation Issues

```bash
# Clean and regenerate
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Issues

```bash
# Clean and reinstall
flutter clean
flutter pub get
cd core && flutter pub get
cd ../core_ui && flutter pub get
# ... repeat for all packages
```

### Build Issues

```bash
# Clean build
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter build [platform]
```

## Additional Resources

- **Architecture Rules**: See `.cursorrules` in project root
- **Setup Guide**: See `.cursor/reference/setup-guide.md`
- **Package Structure**: See `.cursor/reference/structure.md`
- **Templates**: See `.cursor/templates/` for configuration templates

## License

[Your License Here]
