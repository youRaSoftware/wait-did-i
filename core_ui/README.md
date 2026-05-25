# core_ui Package

Reusable UI components, theme system, and design tokens for Tintday.

---

## Overview

`core_ui` provides:
- **Design tokens** (colors, typography, shadows, spacing)
- **Theme system** (light/dark themes)
- **Reusable widgets** (buttons, cards, etc.)
- **Design system implementation** ("Emotional Depth" philosophy)

---

## Structure

```
core_ui/
├── lib/
│   ├── core_ui.dart                    # Barrel export
│   ├── theme/
│   │   ├── app_theme.dart              # Theme configuration
│   │   └── generate/
│   │       ├── tokens.g.dart           # Generated design tokens
│   │       ├── tokens_extra.g.dart     # Token access (InheritedWidget)
│   │       └── tokens/                 # Token source files (JSON)
│   └── widgets/
│       └── widgets.dart                # Reusable widgets
└── pubspec.yaml
```

---

## Design Tokens

### Generated with figma2flutter

Tokens are generated from JSON files using `figma2flutter`:

```bash
figma2flutter --input core_ui/lib/theme/generate/tokens --output core_ui/lib/theme/generate/
```

### Accessing Tokens

```dart
import 'package:core_ui/core_ui.dart';

// Via context extensions
final ColorTokens color = context.currentTokens.color;
final TextStyleTokens textStyle = context.currentTokens.textStyle;
final ShadowTokens shadow = context.currentTokens.shadow;

// Colors
color.brandCoral              // #FF9A8B
color.brandPeach              // #FFD7A8
color.colorBackgroundPrimary  // #FFFBF8 (light) / #0F0A0A (dark)
color.colorTextPrimary        // #1A0F0F (light) / #FAF5F5 (dark)

// Typography
textStyle.displayXl    // 48sp Bold Playfair Display
textStyle.display      // 36sp Semibold Playfair Display
textStyle.headline     // 28sp Semibold Playfair Display
textStyle.body         // 16sp Regular Inter
textStyle.button       // 16sp Semibold Inter

// Shadows
shadow.shadowElevation1      // Cards (4/16/0.06)
shadow.shadowElevation2      // Modals (8/32/0.1)
shadow.shadowGlowPrimary     // Coral glow (40dp blur)
```

### Token Categories

1. **Colors** (53 tokens):
   - Brand colors (coral, peach, lavender, mint)
   - Background, surface, text colors
   - Semantic colors (success, error, warning)
   - State colors (hover, pressed, disabled)

2. **Typography** (11 styles):
   - Display styles (Playfair Display)
   - Body styles (Inter)
   - Button, caption, overline

3. **Shadows** (5 tokens):
   - Elevations (1-3)
   - Glow effects (primary, secondary)

---

## Theme System

### Theme Setup

```dart
import 'package:core_ui/core_ui.dart';

MaterialApp(
  theme: AppThemeData.createTheme(LightTokens()),
  darkTheme: AppThemeData.createTheme(DarkTokens()),
  themeMode: ThemeMode.system,
  // ...
);
```

### Using Themes

```dart
// Access tokens via context
final TextStyleTokens textStyle = context.currentTokens.textStyle;
final ColorTokens color = context.currentTokens.color;

Text(
  'Heading',
  style: textStyle.displayXl,
)

// Or via theme
Text(
  'Body text',
  style: Theme.of(context).textTheme.bodyMedium,
)

// Colors
Container(
  color: color.brandCoral,
)
```

---

## Reusable Widgets

### Creating Widgets

All widgets should:
1. Use explicit types (no `var`)
2. Have named parameters only
3. Access tokens via `context.currentTokens`
4. Follow "Emotional Depth" design philosophy

Example:
```dart
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const GradientButton({
    required this.label,
    this.onPressed,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    final TextStyleTokens textStyle = context.currentTokens.textStyle;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.brandCoral, color.brandPeach],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.brandCoral.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  )
                : Text(
                    label,
                    style: textStyle.button.copyWith(
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
```

---

## Design System Guidelines

### Color Usage

```dart
final ColorTokens color = context.currentTokens.color;

// Primary actions (CTAs)
gradient: LinearGradient(
  colors: [color.brandCoral, color.brandPeach],
)

// Secondary actions
color: color.brandLavender

// Backgrounds
color: color.colorBackgroundPrimary  // Auto switches light/dark
```

### Glassmorphism

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.7),  // Light theme
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: Colors.white.withOpacity(0.3),
      width: 1.5,
    ),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: content,
    ),
  ),
)
```

### Glow Effects

```dart
final ColorTokens color = context.currentTokens.color;

BoxShadow(
  color: color.brandCoral.withOpacity(0.4),
  blurRadius: 24,
  offset: Offset(0, 8),
)
```

### Spacing (8pt Grid)

Use token values or direct dp:
- xxs: 4dp
- xs: 8dp
- sm: 12dp
- md: 16dp
- lg: 24dp
- xl: 32dp

```dart
Padding(
  padding: EdgeInsets.all(16),  // md
  child: Column(
    spacing: 24,  // lg
    children: [...],
  ),
)
```

---

## Adding New Tokens

1. Edit token files in `core_ui/lib/theme/generate/tokens/`
   - `primitives/mobile.json` - base values
   - `tokens/light.json` - light theme tokens
   - `tokens/dark.json` - dark theme tokens
   - `global.json` - global tokens (typography, shadows)

2. Regenerate:
```bash
figma2flutter --input core_ui/lib/theme/generate/tokens --output core_ui/lib/theme/generate/
```

3. Use in code:
```dart
final ColorTokens color = context.currentTokens.color;
color.yourNewColor
```

---

## Best Practices

1. **Always use tokens** - Never hardcode colors or text styles
2. **Access via context** - `context.currentTokens.color`, `context.currentTokens.textStyle` for consistency
3. **Declare at build start** - Get tokens at the beginning of build method
4. **Responsive design** - Use MediaQuery for breakpoints
5. **Accessibility** - Respect `MediaQuery.disableAnimations`
6. **Performance** - Use `const` constructors where possible

---

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  core:
    path: ../core
```

No external packages required. All tokens are generated locally.
