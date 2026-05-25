# Использование сгенерированных токенов

## Обзор

`figma2flutter` сгенерировал файлы с полным набором токенов:
- `tokens.g.dart` - основные классы токенов (LightTokens, DarkTokens)
- `tokens_extra.g.dart` - InheritedWidget для доступа к токенам

## Структура токенов

```dart
abstract class ITokens {
  ColorTokens get color;       // 53 цветовых токена
  TextStyleTokens get textStyle; // 10 текстовых стилей
  ShadowTokens get shadow;      // 3 тени
}

class LightTokens extends ITokens { ... }
class DarkTokens extends ITokens { ... }
```

## Использование в приложении

### 1. Обернуть приложение в Tokens widget

```dart
import 'package:core_ui/theme/generate/tokens.g.dart';

void main() {
  runApp(
    Tokens(
      tokens: LightTokens(), // или DarkTokens()
      child: MyApp(),
    ),
  );
}
```

### 2. Доступ к токенам через context

```dart
// Цвета
final coral = context.tokens.color.brandCoral;
final textPrimary = context.tokens.color.colorTextPrimary;
final background = context.tokens.color.colorBackgroundPrimary;

// Текстовые стили
final h1Style = context.tokens.textStyle.h1;
final bodyStyle = context.tokens.textStyle.bodyM;
final labelStyle = context.tokens.textStyle.label;

// Тени
final shadows = context.tokens.shadow.shadowBottomSheet;
final menuShadow = context.tokens.shadow.menuShadow;
```

### 3. Примеры использования

#### Текст с заголовком

```dart
Text(
  'Welcome to Tintday',
  style: context.tokens.textStyle.h1,
)
```

#### Карточка с цветами и тенью

```dart
Container(
  decoration: BoxDecoration(
    color: context.tokens.color.colorBackgroundSurface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: context.tokens.shadow.shadow2,
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text(
        'Your Mood Today',
        style: context.tokens.textStyle.h2,
      ),
      SizedBox(height: 8),
      Text(
        'How are you feeling?',
        style: context.tokens.textStyle.bodyS.copyWith(
          color: context.tokens.color.colorTextSecondary,
        ),
      ),
    ],
  ),
)
```

#### Кнопка с градиентом

```dart
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        context.tokens.color.brandCoral,
        context.tokens.color.brandPeach,
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: context.tokens.color.brandCoral.withValues(alpha: 0.3),
        blurRadius: 24,
        offset: Offset(0, 8),
      ),
    ],
  ),
  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  child: Text(
    'Select Color',
    style: context.tokens.textStyle.bodyM.copyWith(
      color: context.tokens.color.colorTextInverse,
      fontWeight: FontWeight.w600,
    ),
  ),
)
```

#### Glassmorphism Card

```dart
import 'dart:ui';

Container(
  decoration: BoxDecoration(
    color: context.tokens.color.colorGlassSurface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: context.tokens.color.colorGlassBorder,
      width: 1.5,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Stats',
              style: context.tokens.textStyle.h2b,
            ),
            SizedBox(height: 12),
            Text(
              'Your mood calendar',
              style: context.tokens.textStyle.bodyS,
            ),
          ],
        ),
      ),
    ),
  ),
)
```

### 4. Переключение темы

```dart
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ITokens _currentTokens = LightTokens();

  void _toggleTheme() {
    setState(() {
      _currentTokens = _currentTokens is LightTokens
        ? DarkTokens()
        : LightTokens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Tokens(
      tokens: _currentTokens,
      child: MaterialApp(
        theme: AppThemeData.createTheme(_currentTokens),
        home: HomeScreen(onToggleTheme: _toggleTheme),
      ),
    );
  }
}
```

### 5. Интеграция с существующим AppThemeProvider

В [app_theme.dart](../app_theme.dart:1) уже настроена интеграция:

```dart
class AppThemeData {
  static ThemeData createTheme(ITokens tokens) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(...),
      textTheme: TextTheme(
        displayLarge: tokens.textStyle.h1,
        bodyMedium: tokens.textStyle.bodyS,
        // ...
      ),
      scaffoldBackgroundColor: tokens.color.colorBackgroundPrimary,
      // ...
    );
  }
}
```

## Доступные токены

### Color Tokens (53)

#### Brand Colors
- `brandCoral` (#FF9A8B) - энергия, радость
- `brandCoralLight` (#FFB5A8)
- `brandPeach` (#FFD7A8) - тепло, комфорт
- `brandPeachLight` (#FFE5C4)
- `brandLavender` (#E8B4D1) - спокойствие
- `brandLavenderLight` (#F0C8DE)
- `brandMint` (#B8E6D4) - свежесть
- `brandMintLight` (#D0F0E6)
- `brandOcean` (#87CEEB) - баланс

#### Neutral Colors
- `neutralWhite` (#FFFFFF)
- `neutralWarmWhite` (#FFFBF8)
- `neutralSoftWhite` (#FFF5F0)
- `neutralSoftPeach` (#FFFAFA)
- `neutralDeepBrown` (#1A0F0F)
- `neutralDarkSlate` (#2D1B1B)
- `neutralWarmGray` (#5C4A4A)
- `neutralMuted` (#8B7575)
- `neutralLightGray` (#CCCCCC)
- `neutralBorderLight` (#E0E0E0)

#### Semantic Colors (Light Theme)
- Background: `colorBackgroundPrimary` (#FFFBF8), `colorBackgroundSecondary` (#FFF5F0)
- Surface: `colorBackgroundSurface` (#FFFFFF), `colorBackgroundElevated` (#FFFFFF)
- Text: `colorTextPrimary` (#1A0F0F), `colorTextSecondary` (#5C4A4A), `colorTextTertiary` (#8B7575)
- Border: `colorBorderDefault` (#E0E0E0), `colorBorderFocus` (#FF9A8B)
- Glass: `colorGlassSurface` (rgba 255,255,255,0.7), `colorGlassBorder` (rgba 255,255,255,0.3)

#### Semantic Colors (Dark Theme)
- Background: `colorBackgroundPrimary` (#0F0A0A), `colorBackgroundSecondary` (#1A1414)
- Surface: `colorBackgroundSurface` (#1E1515), `colorBackgroundElevated` (#252020)
- Text: `colorTextPrimary` (#FAF5F5), `colorTextSecondary` (#C4B5B5), `colorTextTertiary` (#7A6B6B)
- Glass: `colorGlassSurface` (rgba 30,21,21,0.8), `colorGlassBorder` (rgba 255,154,139,0.1)

#### State Colors
- `colorStateError` (#FF6B6B)
- `colorStateSuccess` (#20D371)
- `colorStateWarning` (#FFB626)
- `colorStateInfo` (#107BEC)

### TextStyle Tokens (10)

- `h1` - 24px, Bold, Inter (заголовок)
- `h2` - 20px, Medium, Inter (подзаголовок)
- `h2b` - 20px, Bold, Inter (подзаголовок жирный)
- `bodyL` - 18px, Medium, Inter (крупный текст)
- `bodyM` - 16px, Medium, Inter (средний текст)
- `bodyS` - 14px, Medium, Inter (мелкий текст)
- `label` - 12px, Regular, Inter (лейбл)
- `labelS` - 10px, Medium, Inter (мелкий лейбл)
- `widgetH1` - 24px, Medium, Inter (заголовок виджета)
- `tagLabel` - 12px, Medium, Inter (тег)

### Shadow Tokens (3)

- `shadowBottomSheet` - для bottom sheet (offset: 0, -6; blur: 12)
- `menuShadow` - для меню (offset: 0, -12; blur: 24)
- `shadow2` - базовая тень (offset: 0, 2; blur: 8)

## Следующие шаги

1. **Добавить spacing, radius константы** - эти токены не сгенерированы автоматически, используйте числа напрямую:
   ```dart
   EdgeInsets.all(16)  // spacing md
   BorderRadius.circular(12)  // radius medium
   ```

2. **Создать helper виджеты** для часто используемых паттернов:
   - GlassCard
   - GradientButton
   - ColorDot
   - MoodCalendar

3. **Добавить helper методы для градиентов**:
   ```dart
   // Создайте отдельный файл с градиентами
   extension TokenGradients on ITokens {
     LinearGradient get gradientSunrise => LinearGradient(
       colors: [color.brandCoral, color.brandPeach],
     );
   }
   ```

## Ссылки

- [tokens.json](tokens/) - исходные JSON токены
- [README.md](tokens/README.md) - полная документация токенов
- [app_theme.dart](../app_theme.dart) - интеграция с Material Theme
- [theme_provider.dart](../theme_provider.dart) - провайдер темы
