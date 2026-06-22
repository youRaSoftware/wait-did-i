# Home Screen — Flutter implementation spec

Это спецификация главного экрана приложения **Wait, Did I?**. Рядом
лежит эталонный прототип `reference.html` — открой его и
переключай состояния кнопками внизу.

## Что мы делаем

Главный экран — это **активный чек-лист**, открытый сразу при запуске
приложения. Никакого выбора списка из меню — пользователь сразу видит
свой текущий контекст и может отмечать пункты в один тап.

## Три состояния

Экран встречает пользователя в одном из трёх состояний:

### 1. Empty (пусто)
Редкое — встречается только если пользователь удалил все списки.
После онбординга **не показывается**, потому что мы создаём один
дефолтный список сразу.

- Greeting: `Wait, Did I?` / `Let's get started.`
- В центре экрана — большая иконка-плашка с галочкой.
- Текст: «Your first list is ready» / «Start with «Leaving home» or build your own from scratch.»
- Кнопка-CTA с градиентом бренда: «+ Add your first list».
- НЕТ табов, НЕТ FAB снизу.

### 2. Idle (списки есть, спокойное)
Утро/день, пользователь зашёл проверить что есть. Список открыт,
ничего не отмечено, ничего срочного не нужно.

- Greeting: `Good evening` / `Nothing pressing — take your time.`
  (Greeting меняется по времени суток — см. ниже)
- Табы со списками (Home / Bed / Car), активный подсвечен.
- Заголовок текущего списка + статус «Last checked 6 hours ago».
- Прогресс-бара **нет** (он появляется только когда что-то отмечено).
- Все пункты — пустые чекбоксы (`pending`).
- FAB снизу справа.

### 3. Checking (момент проверки)
Пользователь начал отмечать пункты. По мере галочек обновляется
прогресс-бар, статус, и появляется подсказка снизу.

- Greeting: `Heading out?` / `One quick list to clear.`
- Те же табы и заголовок.
- **Прогресс-бар** наверху над списком.
- Статус становится `N of M checked`.
- Отмеченные пункты приглушены, имеют светло-зелёный фон и метаданные
  (время отметки, иконка фото если было).
- Снизу — **bottom hint**: glass-карточка с зелёной иконкой галочки и
  ободряющим текстом. Меняется по прогрессу (см. строки ниже).
- FAB остаётся.

**Важно**: переход между состояниями 2 и 3 — органический. Когда пользователь
отметил первый пункт, состояние плавно превращается из idle в checking:
появляется прогресс-бар, меняется greeting сверху, всплывает bottom hint.

## Архитектура

```
lib/
└── features/
    └── home/
        ├── home_screen.dart            # Корневой StatefulWidget
        ├── widgets/
        │   ├── greeting_header.dart    # Верх: greeting + settings-btn
        │   ├── list_switcher.dart      # Табы со списками
        │   ├── checklist_view.dart     # Тело списка с пунктами
        │   ├── checklist_item.dart     # Один пункт чек-листа
        │   ├── progress_bar.dart       # Тонкий бар прогресса
        │   ├── bottom_hint.dart        # Glass-карточка снизу
        │   ├── empty_state.dart        # Состояние «пусто»
        │   └── add_fab.dart            # Floating action button
        └── models/
            ├── checklist.dart          # Модель чек-листа
            └── checklist_item_model.dart
```

## Структура корневого виджета

```dart
class HomeScreen extends StatefulWidget { ... }

class _HomeScreenState extends State<HomeScreen> {
  late List<Checklist> _lists;
  int _activeListIndex = 0;

  Checklist get _activeList => _lists[_activeListIndex];
  bool get _isEmpty => _lists.isEmpty;
  bool get _isChecking =>
    _activeList.items.any((i) => i.isChecked);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Фоновые glow (общие для всех состояний)
          const _BackgroundGlow(),

          if (_isEmpty)
            const EmptyState()
          else
            Column(
              children: [
                GreetingHeader(state: _getHeaderState()),
                ListSwitcher(
                  lists: _lists,
                  activeIndex: _activeListIndex,
                  onTap: (i) => setState(() => _activeListIndex = i),
                ),
                Expanded(
                  child: ChecklistView(
                    list: _activeList,
                    showProgress: _isChecking,
                    onItemTap: _toggleItem,
                  ),
                ),
              ],
            ),

          // Bottom hint появляется только в состоянии checking
          if (_isChecking) _buildBottomHint(),

          // FAB не показываем в empty
          if (!_isEmpty) const AddFab(),
        ],
      ),
    );
  }
}
```

## Модели данных

```dart
class Checklist {
  final String id;
  final String name;        // 'Leaving home'
  final String emoji;       // '🏠'
  final List<ChecklistItem> items;
  final DateTime? lastChecked;
}

class ChecklistItem {
  final String id;
  final String name;        // 'Front door'
  final bool isChecked;
  final DateTime? checkedAt;
  final String? photoPath;  // null если без фото
  final bool photoRecommended; // показывать ли «Photo recommended» в meta
}
```

В MVP создаём один дефолтный список `Leaving home` с тремя пунктами:
Front door, Stove off, Windows closed. Делается в `onboarding_done`
callback'е перед переходом на главный экран.

## Цвета и токены

Все цвета из `dark.json`. Ключевые для этого экрана:

```dart
// Фоны
const bgPrimary  = Color(0xFF0F1419);
const bgSurface  = Color(0xFF1E2530);

// Текст
const textPrimary   = Color(0xFFF7FAFC);
const textSecondary = Color(0xFFB4C0CE);
const textTertiary  = Color(0xFF718096);

// Бренд (для FAB и градиентов)
const brandLight = Color(0xFF7BB0DD);
const brand      = Color(0xFF5A9BD4);
const brandDeep  = Color(0xFF4F86C6);

// Success (отмеченные пункты)
const success    = Color(0xFF68C58F);

// Border subtle
const borderSubtle = Color(0x14FFFFFF);  // rgba(255,255,255,0.08)
```

## Размеры и отступы

- **Горизонтальные** — 28px.
- **Top padding** (greeting) — SafeArea + 10 (≈ 64 на iPhone).
- **Между greeting и табами** — 16.
- **Между табами и заголовком** — 22.
- **Между пунктами чек-листа** — 10.
- **Bottom FAB** — bottom: 32, right: 24, size: 60×60.
- **Bottom hint** — bottom: 110, padding 14×16.

## Анимации

Все timing и кривые — те же, что мы используем в онбординге:
- `easeOutBack` (`cubic-bezier(0.34, 1.56, 0.64, 1)`) — для отскоков.
- `easeOutCubic` (`cubic-bezier(0.22, 1, 0.36, 1)`) — для плавных fade.

### Тап по пункту чек-листа

Когда пользователь тапает по пустому пункту:

1. **Чекбокс** превращается из dashed-кружка в зелёный круг с галочкой.
   Длительность 250ms, кривая `easeOutBack`. Чекбокс делает лёгкий
   scale (0.8 → 1.1 → 1.0) для ощущения «штампа».

2. **Фон карточки** мягко переходит из `#1E2530` в `rgba(104, 197, 143, 0.05)`.
   Длительность 250ms, кривая `easeOutCubic`.

3. **Имя пункта** меняет цвет с `textPrimary` на `textSecondary`,
   но БЕЗ зачёркивания (в HTML-прототипе у меня нет line-through —
   на dark theme это выглядит грязно). 200ms fade.

4. **Метаданные обновляются**: вместо «Tap to check» появляется
   таймстемп «9:35 PM». Crossfade 200ms.

5. **Прогресс-бар** анимированно растёт до новой ширины. 400ms easeOutCubic.

6. **Если это первый чек** — проявляется прогресс-бар сам (opacity 0→1,
   высота 0→4 за 300ms), и появляется bottom hint (translateY 20→0,
   opacity 0→1 за 400ms).

7. **Если это последний чек** — bottom hint меняет текст:
   `Almost there` → `All done`, `One more to go.` → `Have a good evening.`
   Crossfade 250ms.

8. **Haptic** — `HapticFeedback.lightImpact()` на момент тапа.

### Переключение табов

При тапе по неактивному табу:
1. Активный фон (`bgSurface`) с тенью плавно «переезжает» под новый таб.
   300ms easeOutCubic. Используй `AnimatedAlign` или `AnimatedPositioned`
   внутри table-track.
2. Цвета лейблов плавно меняются (active: `textPrimary`, inactive: `textSecondary`).
3. **Содержимое списка** меняется через `AnimatedSwitcher` с
   `FadeTransition` + лёгким slide (200ms).

## Компоненты по отдельности

### GreetingHeader

Большой жирный заголовок + подзаголовок-подсказка справа от кнопки
настроек.

```dart
class GreetingHeader extends StatelessWidget {
  final HeaderState state;
  // ...
}

enum HeaderState { empty, idle, checking, allDone }
```

Тексты по состояниям:

| State    | Greeting             | Sub                                      |
|----------|----------------------|------------------------------------------|
| empty    | Wait, Did I?         | Let's get started.                       |
| idle (morning)   | Good morning         | A quick check before you head out?       |
| idle (afternoon) | Hey there            | Anything to verify?                      |
| idle (evening)   | Good evening         | Nothing pressing — take your time.       |
| idle (night)     | Wind down            | Time for the bedtime check?              |
| checking | Heading out?         | One quick list to clear.                 |
| allDone  | All clear            | Have a good one.                         |

Логика выбора greeting:
- Если активен `Before bed` или время > 22:00 → night
- Если время 5-12 → morning, 12-17 → afternoon, 17-22 → evening
- Если хоть один пункт отмечен, но не все → checking
- Если все отмечены → allDone (3 секунды, потом сворачивается обратно в idle)

### ListSwitcher (табы)

Pill-style сегмент-контрол. Контейнер `bgSurface` с прозрачностью,
внутри pills для каждого таба. Активный pill — твёрдый `bgSurface` с
тенью, остальные — прозрачные.

```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.04),
    borderRadius: BorderRadius.circular(14),
  ),
  padding: const EdgeInsets.all(4),
  child: Row(children: tabs.asMap().entries.map((e) => Expanded(
    child: GestureDetector(
      onTap: () => onTap(e.key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: e.key == activeIndex ? bgSurface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: e.key == activeIndex ? [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: Offset(0, 2))
          ] : null,
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(e.value.emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(e.value.shortName, style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: e.key == activeIndex ? textPrimary : textSecondary,
            )),
          ],
        ),
      ),
    ),
  )).toList()),
)
```

**Важно**: `shortName` — это короткое имя для табов (Home, Bed, Car), а
не полное `Leaving home`. У `Checklist` должно быть два имени.

### ChecklistItem (один пункт)

Высота ≈ 60px (16 vertical padding + 28 chek + ...). Карточка кликабельная
целиком — тап в любое место отмечает пункт. Это критично для UX: пользователь
тыкает пальцем не глядя.

```dart
GestureDetector(
  onTap: () {
    HapticFeedback.lightImpact();
    onTap();
  },
  behavior: HitTestBehavior.opaque,
  child: AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOutCubic,
    decoration: BoxDecoration(
      color: item.isChecked
        ? success.withOpacity(0.05)
        : bgSurface,
      border: Border.all(
        color: item.isChecked
          ? success.withOpacity(0.15)
          : Colors.white.withOpacity(0.04),
      ),
      borderRadius: BorderRadius.circular(18),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    child: Row(
      children: [
        _AnimatedCheckbox(isChecked: item.isChecked),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: item.isChecked ? textTertiary : textPrimary,
                ),
                child: Text(item.name),
              ),
              const SizedBox(height: 2),
              Text(_metaText(item), style: TextStyle(
                fontSize: 12,
                color: textTertiary,
              )),
            ],
          ),
        ),
        if (item.photoPath != null) _PhotoThumbnail(path: item.photoPath!),
      ],
    ),
  ),
)
```

Метатекст логика:
- `item.isChecked && item.photoPath != null` → `'9:34 PM · with photo'`
- `item.isChecked` → `'9:35 PM'`
- `item.photoRecommended` (и не отмечен) → `'Photo recommended'`
- иначе → `'Tap to check'` или просто пустая строка

### AnimatedCheckbox

```dart
class _AnimatedCheckbox extends StatelessWidget {
  final bool isChecked;
  const _AnimatedCheckbox({required this.isChecked});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? success : Colors.white.withOpacity(0.04),
        border: isChecked
          ? null
          : Border.all(
              color: Colors.white.withOpacity(0.22),
              width: 1.5,
              style: BorderStyle.solid,  // dashed нужен через CustomPainter или dotted_border
            ),
        boxShadow: isChecked ? [
          BoxShadow(color: success.withOpacity(0.25), blurRadius: 12, offset: Offset(0, 4))
        ] : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isChecked ? 1 : 0,
        child: const Center(
          child: Icon(Icons.check, size: 14, color: bgPrimary, weight: 800),
        ),
      ),
    );
  }
}
```

Для **dashed border** в pending-состоянии используй пакет `dotted_border`
или нарисуй через `CustomPainter`. Чтобы не возиться, можно поставить
solid с opacity 0.22 — визуально на dark theme разницу почти не видно,
но в HTML-эталоне у меня именно dashed.

### Progress bar

```dart
class ProgressLine extends StatelessWidget {
  final double progress; // 0.0..1.0
  // ...
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [brandLight, brand]),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
```

Появление прогресс-бара (при первом отмеченном пункте) делается через
`AnimatedSize` сверху — высота 0 → 4 + opacity 0 → 1 за 300ms.

### BottomHint

Glass-карточка снизу. Тоже использует `BackdropFilter` для blur эффекта.

```dart
Positioned(
  bottom: 110, left: 28, right: 28,
  child: AnimatedSlide(
    offset: visible ? Offset.zero : const Offset(0, 0.5),
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeOutCubic,
    child: AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 400),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgSurface.withOpacity(0.75),
              border: Border.all(color: brandLight.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: success,
                    boxShadow: [BoxShadow(
                      color: success.withOpacity(0.25),
                      blurRadius: 12, offset: Offset(0, 4),
                    )],
                  ),
                  child: const Icon(Icons.check, size: 14, color: bgPrimary, weight: 800),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600, color: textPrimary,
                    )),
                    Text(sub, style: const TextStyle(
                      fontSize: 12, color: textSecondary, fontWeight: FontWeight.w500,
                    )),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)
```

Тексты подсказки по прогрессу:
- 1 из 3 отмечено → `Good start` / `Two more to go.`
- 2 из 3 отмечено → `Almost there` / `One more to go.`
- 3 из 3 отмечено → `All done` / `Have a good one.`

(В моём HTML-прототипе показан только второй вариант — остальные сделай по аналогии.)

### AddFab

Floating action button — открывает экран создания нового чек-листа.

```dart
Positioned(
  bottom: 32, right: 24,
  child: GestureDetector(
    onTap: _openAddList,
    child: Container(
      width: 60, height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [brandLight, brandDeep],
        ),
        boxShadow: [BoxShadow(
          color: brand.withOpacity(0.4),
          blurRadius: 28, offset: Offset(0, 12),
        )],
      ),
      child: const Icon(Icons.add, size: 24, color: Colors.white),
    ),
  ),
)
```

### EmptyState

```dart
Center(
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      // Иконка-плашка
      Container(
        width: 96, height: 96,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [
              brandLight.withOpacity(0.15),
              brandDeep.withOpacity(0.08),
            ],
          ),
          border: Border.all(color: brandLight.withOpacity(0.15)),
        ),
        child: Center(child: Icon(/* галочка */, size: 44, color: brandLight)),
      ),
      const SizedBox(height: 24),
      const Text('Your first list is ready', style: TextStyle(
        fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary,
        letterSpacing: -0.3,
      )),
      const SizedBox(height: 10),
      const Text(
        'Start with «Leaving home» or\nbuild your own from scratch.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: textSecondary, height: 1.55),
      ),
      const SizedBox(height: 24),
      // CTA с градиентом
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [brandLight, brandDeep]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.add, size: 14, color: Colors.white),
            SizedBox(width: 8),
            Text('Add your first list', style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
            )),
          ],
        ),
      ),
    ],
  ),
)
```

## Фоновые glow

Те же два радиальных glow, что в онбординге, но менее ярких — на главном
экране пользователь проводит много времени, и сильные эффекты будут
утомлять. В HTML-прототипе значения уже понижены: glow-1 opacity 0.20,
glow-2 opacity 0.15.

## Что точно проверить перед сдачей

- Тап по пункту работает на любой точке карточки (не только по чекбоксу).
- Прогресс-бар появляется именно при ПЕРВОМ отмеченном пункте, не сразу.
- Bottom hint меняет тексты на 1/3, 2/3, 3/3 — не одинаковый.
- Greeting меняется по времени суток и состоянию.
- Backdrop blur на bottom-hint работает (на низких устройствах может
  тормозить — если так, заменить на solid `bgSurface` с opacity 0.95).
- Haptic feedback срабатывает на тапе по пункту.
- При свайпе между табами содержимое плавно сменяется, не моргает.

## Текстовые строки (для локализации)

```dart
// Greetings
'Wait, Did I?'         // empty / fallback
'Good morning'
'Hey there'
'Good evening'
'Wind down'
'Heading out?'
'All clear'

// Greeting subs
"Let's get started."
'A quick check before you head out?'
'Anything to verify?'
'Nothing pressing — take your time.'
'Time for the bedtime check?'
'One quick list to clear.'
'Have a good one.'

// List
'Last checked %s ago'  // 6 hours ago
'%d of %d checked'      // 2 of 3 checked
'Tap to check'
'Photo recommended'
'%s · with photo'        // 9:34 PM · with photo

// Empty state
'Your first list is ready'
'Start with «Leaving home» or\nbuild your own from scratch.'
'Add your first list'

// Bottom hints
'Good start'
'Almost there'
'All done'
'Two more to go.'
'One more to go.'
'Have a good evening.'
```

## Открытые вопросы для следующей задачи

Эти экраны нужны для полного цикла, но не входят в скоуп этой спеки:

1. **Детальный экран чек-листа** — что показывать, если тапнуть на сам
   заголовок списка. История проверок, настройки списка, удаление пунктов.
2. **Экран добавления пункта/списка** — что открывается при FAB.
3. **Экран съёмки фото** — на «Photo recommended» пунктах.
4. **Меню настроек** — что в правом верхнем углу.

После того как пройдём home screen и убедимся, что Claude Code собрал
его правильно, добёмся до этих экранов.
