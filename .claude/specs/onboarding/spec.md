# Onboarding — Flutter implementation spec

Это спецификация для реализации онбординга приложения **Wait, Did I? — Home Checklist**
во Flutter. Рядом с этим документом лежит файл `reference.html` — это
эталонный прототип. Если в чём-то сомневаешься, **открой HTML и сверься с ним**.
Анимации, тайминги, тени, цвета — всё рабочее и проверенное.

## Что мы делаем

Три экрана онбординга, по которым пользователь свайпает или жмёт кнопку Continue.
Каждый экран рассказывает свой "акт":

1. **Слайд 1 — Проблема.** Три карточки чек-листа падают сверху и собираются стопкой.
2. **Слайд 2 — Решение.** Поляроид прилетает с разворотом, фото "проявляется",
   зелёная галочка-штамп опускается сверху.
3. **Слайд 3 — Результат.** Силуэт дома ночью с тёплым светящимся окном,
   луной и мерцающими звёздами.

После третьего слайда кнопка меняет текст с `Continue` на `Get started` и
закрывает онбординг.

## Архитектура

```
lib/
├── features/
│   └── onboarding/
│       ├── onboarding_screen.dart      # PageView + общая обвязка
│       ├── widgets/
│       │   ├── progress_bar.dart       # Тонкий прогресс сверху
│       │   ├── page_dots.dart          # Точки-индикаторы
│       │   ├── cta_button.dart         # Кнопка Continue / Get started
│       │   ├── background_glow.dart    # Радиальные glow на фоне
│       │   └── animated_slide.dart     # Базовый враппер для слайдов
│       └── slides/
│           ├── slide_1_falling_cards.dart
│           ├── slide_2_polaroid.dart
│           └── slide_3_night_house.dart
└── theme/
    └── app_colors.dart                 # Уже есть в проекте, см. design tokens
```

## Цвета (из design tokens dark)

```dart
// Фоны
const bgPrimary    = Color(0xFF0F1419);  // основной фон экрана
const bgSecondary  = Color(0xFF1A202C);  // вторичный
const bgSurface    = Color(0xFF1E2530);  // карточки

// Текст
const textPrimary   = Color(0xFFF7FAFC);
const textSecondary = Color(0xFFB4C0CE);
const textTertiary  = Color(0xFF718096);

// Бренд
const brandBlue      = Color(0xFF5A9BD4);  // основной акцент
const brandBlueLight = Color(0xFF7BB0DD);  // верх градиента
const brandBlueDeep  = Color(0xFF4F86C6);  // низ градиента

// State
const stateSuccess = Color(0xFF68C58F);  // зелёная галочка
const stateWarning = Color(0xFFE8B860);  // тёплое окно дома

// Поляроид (отдельная палитра тёплая)
const polaroidPaper = Color(0xFFF7FAFC); // = textPrimary, но в другой роли
const polaroidText  = Color(0xFF4A5568); // подпись внизу
```

Градиент бренда (для кнопок-акцентов, прогресса, иконок):
```dart
const brandGradient = LinearGradient(
  begin: Alignment.topLeft, end: Alignment.bottomRight,
  colors: [brandBlueLight, brandBlueDeep],
);
```

## Анимационные кривые

В CSS-прототипе используется `cubic-bezier(0.34, 1.56, 0.64, 1)` для всех
"падающих" и "приземляющихся" элементов. Это пружинка с overshoot.
Во Flutter это **точно** `Curves.easeOutBack`.

Для текста и плавных fade-in используется `cubic-bezier(0.22, 1, 0.36, 1)` —
это `Curves.easeOutQuint` (или близкая `Curves.easeOutCubic`, разница на глаз
почти не видна).

```dart
const dropCurve = Curves.easeOutBack;     // карточки, поляроид, штамп, точка
const fadeCurve = Curves.easeOutCubic;    // текст, прогресс, сцена
```

## Главный экран — структура

```dart
class OnboardingScreen extends StatefulWidget { ... }

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Важно: каждый слайд должен заново проигрывать свои анимации
  // когда пользователь возвращается к нему свайпом.
  // Передаём в каждый слайд key с индексом, чтобы при смене страницы
  // виджет пересоздавался и анимации стартовали заново.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgPrimary,
      body: Stack(
        children: [
          // Фоновые glow — общие, не привязаны к слайду
          const BackgroundGlow(),

          // Слайды
          PageView(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            children: [
              Slide1FallingCards(key: ValueKey('slide-0-$_currentPage')),
              Slide2Polaroid(key: ValueKey('slide-1-$_currentPage')),
              Slide3NightHouse(key: ValueKey('slide-2-$_currentPage')),
            ],
          ),

          // Прогресс + skip сверху
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 28, right: 28,
            child: Row(
              children: [
                Expanded(child: ProgressBar(progress: (_currentPage + 1) / 3)),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _pageController.animateToPage(
                    2, duration: const Duration(milliseconds: 500), curve: fadeCurve,
                  ),
                  child: const Text('Skip', style: TextStyle(
                    color: textTertiary, fontSize: 14, fontWeight: FontWeight.w500,
                  )),
                ),
              ],
            ),
          ),

          // Точки + CTA снизу
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Column(
              children: [
                PageDots(current: _currentPage, total: 3),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: CtaButton(
                    label: _currentPage == 2 ? 'Get started' : 'Continue',
                    onTap: _onCta,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCta() {
    if (_currentPage == 2) {
      // Закрываем онбординг — переход на главный экран
      Navigator.of(context).pushReplacement(...);
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: fadeCurve,
      );
    }
  }
}
```

## Тайминги анимаций (одинаковы для всех трёх слайдов)

Все анимации внутри слайда начинают играть от t=0, где t=0 — момент, когда
слайд стал виден. Когда пользователь свайпает обратно — анимации играют заново.

### Общее для всех слайдов
- **Заголовок** появляется в t=1.2s (длительность 0.6s, fade + translateY 20→0)
- **Подзаголовок** появляется в t=1.4s (та же длительность)

Используй `AnimationController` длительностью 2.0–2.5s и проигрывай разные
интервалы через `Interval(begin, end)`.

### Слайд 1 — падающие карточки

Три карточки, каждая прилетает сверху (translateY -400 → 0), с поворотом
и приземлением "в стопку".

| Карточка | Начало | Длительность | Финальная позиция                            |
|----------|--------|--------------|-----------------------------------------------|
| 1 "Front door" (pending) | 0.3s | 0.7s | top=10, x=0, rotate=-3° |
| 2 "Stove off" (done) | 0.5s | 0.7s | top=75, x=+8, rotate=0° |
| 3 "Windows closed" (done) | 0.7s | 0.7s | top=140, x=-4, rotate=+2.5° |

Внутри карточки:
- Полупрозрачный фон `rgba(30, 37, 48, 0.7)` + **backdrop blur 20px**.
- Border `1px solid rgba(123, 176, 221, 0.15)`.
- Border radius 18.
- Тень: `BoxShadow(color: Colors.black.withOpacity(0.4), offset: Offset(0, 24), blurRadius: 48)`.

**Backdrop blur во Flutter:**
```dart
ClipRRect(
  borderRadius: BorderRadius.circular(18),
  child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E2530).withOpacity(0.7),
        border: Border.all(color: brandBlueLight.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ...
    ),
  ),
)
```

Состояния check-кружка:
- **Pending** — пустой кружок 24×24, фон `rgba(255,255,255,0.04)`,
  бордер 1.5px dashed `rgba(255,255,255,0.25)`.
  Во Flutter сделай через `CustomPainter` (Flutter не умеет dashed border из коробки)
  или используй пакет `dotted_border`.
- **Done** — заливка `stateSuccess`, внутри белая галочка-svg.

Эмодзи 📷 справа на второй карточке — `opacity: 0.5`, размер 14.

Текст карточки 1 (pending) — приглушённый `textSecondary`, остальных — `textPrimary`,
вес 500.

### Слайд 2 — поляроид

Поляроид прилетает целиком, потом внутри него **по очереди появляются три слоя**:
тёмное фото, "проявленная" иллюстрация двери, штамп.

Структура виджета — Stack:
1. Белая "карточка" поляроида (полароидная пропорция: padding 12/12/50/12).
2. Внутри сверху — квадратное "фото" (aspect ratio 1:1, тёмный градиент).
3. На фото поверх — SVG двери (можно через `flutter_svg` или `CustomPaint`).
4. Над фото в углу — круглый штамп-галочка.
5. Снизу под фото — подпись `Today · 9:34 PM · Home`.

Тайминги:
| Слой | Начало | Длительность | Эффект |
|------|--------|--------------|--------|
| Поляроид целиком | 0.4s | 0.9s | translateY -300→0, rotate -25°→-4°, scale 0.6→1, opacity 0→1 |
| Тёмное фото (фон) | 1.0s | 1.0s | opacity 0→1 |
| Дверь на фото | 1.2s | 1.0s | opacity 0→1 |
| Штамп галочки | 1.5s | 0.4s | scale 2→0.85→1, rotate 20°→-8°→-5°, opacity 0→1 (двухстадийная анимация — overshoot) |
| Подпись | 1.7s | 0.5s | opacity 0→1, translateY 20→0 |

Тень поляроида (важна — она делает его "осязаемым"):
```dart
boxShadow: [
  BoxShadow(color: Colors.black.withOpacity(0.5), offset: Offset(0, 30), blurRadius: 60),
  BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(0, 10), blurRadius: 20),
],
```

SVG двери:
```
<path d="M 12 130 L 12 36 C 12 18, 22 8, 40 8 C 58 8, 68 18, 68 36 L 68 130 Z"/>
```
Заливка — линейный градиент `[brandBlueLight 0.8, brandBlueDeep 0.6]` сверху вниз.
Замок — белый круг `cx=55 cy=78 r=5` + прямоугольник `x=53 y=80 w=4 h=10`.

Штамп:
- Круг 56×56, фон `stateSuccess`.
- Внутри белая галочка-SVG: `path d="M3 11 L10 18 L23 4"` stroke=`bgPrimary`, width 3.5.
- Тень: `BoxShadow(color: stateSuccess.withOpacity(0.4), offset: Offset(0, 4), blurRadius: 12)`.

### Слайд 3 — сцена дома

Это **самый поэтичный** слайд. Реализация через `CustomPaint` или composed SVG.

Композиция (SVG-координаты в viewBox 320×280):

```
Звёзды (белые точки):
- star_1: cx=60  cy=40  r=1.5
- star_2: cx=240 cy=55  r=1.2
- star_3: cx=280 cy=90  r=1.0
- star_4: cx=40  cy=80  r=1.3

Луна-серп (два круга, второй "вычитает" — но это просто наложение):
- основа: cx=260 cy=40 r=20  fill=textPrimary (opacity 0.85)
- маска:  cx=252 cy=36 r=20  fill=bgSecondary

Силуэт дома:
- path d="M 80 250 L 80 130 L 160 70 L 240 130 L 240 250 Z"
- fill: линейный градиент [Color(0xFF2A3441), bgSecondary] сверху вниз
- stroke: brandBlueLight с opacity 0.2, width 1.5

Окно (тёплое):
- rect x=135 y=160 w=50 h=50 rx=4
- fill: радиальный градиент [Color(0xFFFFE4A0), stateWarning]
- + перекрестье: line x1=160 y1=160 x2=160 y2=210 + line x1=135 y1=185 x2=185 y2=185
  stroke=rgba(45,55,72, 0.5) width=1

Дверь:
- rect x=148 y=215 w=24 h=35 rx=2 fill=bgPrimary
- ручка: circle cx=167 cy=232 r=1.5 fill=brandBlueLight

Линия земли:
- line x1=0 y1=250 x2=320 y2=250 stroke=brandBlueLight (opacity 0.15) width=1
```

Тайминги:
| Элемент | Начало | Длительность | Эффект |
|---------|--------|--------------|--------|
| Сцена целиком (контейнер) | 0.3s | 1.0s | scale 0.9→1, opacity 0→1 |
| Окно "загорается" | 1.0s | 1.5s | opacity 0→0.95 (custom curve: ease-out, в середине достигает 1, потом стабилизируется на 0.95) |
| Звезда 1 | 0.8s | — | мигает после появления (loop) |
| Звезда 2 | 1.0s | — | мигает |
| Звезда 3 | 1.2s | — | мигает |
| Звезда 4 | 1.4s | — | мигает |

**Мерцание звёзд** — это бесконечный loop после того как звезда появилась.
Кривая: `opacity: 1.0 → 0.3 → 1.0` за 3 секунды, каждая звезда чуть в разной фазе
(можно сдвинуть на `delay` 0.2–0.4s между ними).

```dart
// Пример звезды с пульсацией
class _TwinklingStar extends StatefulWidget {
  final double appearDelay;
  final double twinkleDelay;
  final Offset position;
  final double radius;
  ...
}

class _TwinklingStarState extends State<_TwinklingStar>
    with TickerProviderStateMixin {
  late AnimationController _appearCtrl;
  late AnimationController _twinkleCtrl;

  @override
  void initState() {
    super.initState();
    _appearCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _twinkleCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 3),
    );
    Future.delayed(Duration(milliseconds: (widget.appearDelay * 1000).toInt()), () {
      if (!mounted) return;
      _appearCtrl.forward();
      Future.delayed(Duration(milliseconds: (widget.twinkleDelay * 1000).toInt()), () {
        if (!mounted) return;
        _twinkleCtrl.repeat(reverse: true);
      });
    });
  }
  // ...
}
```

## Фоновые glow

Это две большие радиальные тени, которые создают атмосферу в тёмной теме.
Без них экран выглядит плоско.

```dart
// Нижний центральный — основной "свет" приложения
Positioned(
  bottom: -180, left: -80, right: -80,
  child: Container(
    height: 500,
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          brandBlue.withOpacity(0.35),
          brandBlue.withOpacity(0.10),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.7],
      ),
    ),
  ),
)

// Верхний правый — холодный отблеск
Positioned(
  top: -100, right: -100,
  child: Container(
    width: 350, height: 350,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [brandBlueLight.withOpacity(0.20), Colors.transparent],
        stops: const [0.0, 0.6],
      ),
    ),
  ),
)
```

Чтобы они выглядели как настоящий blur (а не резкие градиенты), оберни в
`ImageFiltered`:

```dart
ImageFiltered(
  imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
  child: <тот самый Container с градиентом>
)
```

## Прогресс-бар и точки

**Прогресс-бар:**
```dart
class ProgressBar extends StatelessWidget {
  final double progress; // 0.0..1.0
  const ProgressBar({super.key, required this.progress});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(2),
      ),
      child: AnimatedFractionallySizedBox(
        duration: const Duration(milliseconds: 600),
        curve: fadeCurve,
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [brandBlueLight, brandBlue],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
```

**Точки-индикаторы:**
- Неактивная: 6×6 round, фон `rgba(255,255,255,0.15)`.
- Активная: 22×6 (pill), фон `brandBlue`.
- Анимация перехода: 300ms ease.

## CTA-кнопка

```dart
class CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const CtaButton({super.key, required this.label, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: textPrimary,  // белая на тёмном — высокий контраст
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: const TextStyle(
              color: bgPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              fontFamily: 'Manrope',
            )),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, size: 16, color: bgPrimary),
          ],
        ),
      ),
    );
  }
}
```

При тапе — лёгкое scale 0.98 (через `AnimatedScale` или `GestureDetector` с
state). Не критично для первой версии.

## Размеры и отступы

- **Внешние горизонтальные** — 28px.
- **Верхняя зона** (прогресс + skip) — top: SafeArea + 16.
- **Stage** (центральная зона с анимацией) — top: 160, высота 280–320.
- **Текстовая зона** — bottom: 180.
- **Точки** — bottom: 130.
- **CTA** — bottom: 50, высота кнопки 17px padding (итого ~54).

Эти числа подобраны под 390×844 (iPhone 14/15 Pro). На других размерах
зона анимации может центрироваться, текст и кнопка остаются прибиты к низу.
Не используй абсолютные позиции для всего — основное прибей к `bottom`,
а центральную зону положи в `Center` или `Align`.

## Шрифт

Manrope, веса 400 / 500 / 600 / 700. Подключи через `pubspec.yaml`
(скачать с Google Fonts).

```yaml
fonts:
  - family: Manrope
    fonts:
      - asset: assets/fonts/Manrope-Regular.ttf
        weight: 400
      - asset: assets/fonts/Manrope-Medium.ttf
        weight: 500
      - asset: assets/fonts/Manrope-SemiBold.ttf
        weight: 600
      - asset: assets/fonts/Manrope-Bold.ttf
        weight: 700
```

Размеры:
- Headline: 30, weight 700, letter-spacing -0.5, line-height 1.15.
- Subline: 15, weight 400, line-height 1.55, color `textSecondary`.
- CTA: 16, weight 600.
- Skip: 14, weight 500, color `textTertiary`.

## SVG-ассеты

Можно нарисовать всё SVG-кодом через `flutter_svg`, но **проще через
`CustomPaint`** — нет зависимости и больше контроля над анимацией отдельных частей.

Особенно это важно для слайда 3 (сцены дома) — там окно должно отдельно
fade-in, звёзды — мерцать. Если рисовать сцену одним SVG-файлом, придётся
делать несколько слоёв в виде разных файлов. CustomPaint позволяет иметь
один painter с параметрами `windowOpacity`, `star1Opacity` и так далее.

## Что важно не сломать

**Анимации перезапускаются при возврате к слайду.** Если пользователь
свайпнул вперёд и вернулся назад — должна снова сыграть. В HTML-прототипе
это сделано через клонирование DOM. Во Flutter — через `key` с индексом
текущей страницы (виджет пересоздаётся, `initState` запускает анимацию).

**Backdrop blur может быть дорогим.** На слайде 1 — три карточки с blur 20.
Если на слабых устройствах будет тормозить, можно заменить blur на
полупрозрачный фон без blur — визуально немного беднее, но плавнее.

**Skip перебрасывает на последний слайд**, не закрывает онбординг.
Пользователь всё равно увидит финальный экран и нажмёт Get started.
Это лучше для конверсии — даже если он торопится, бренд-сообщение он увидит.

**Состояние онбординга сохраняется.** После первого прохождения и нажатия
Get started — флаг "onboarding_done" в локальном хранилище (Hive),
и следующий раз приложение открывается сразу на главном экране.

## Проверка

Когда соберёшь — открой `reference.html` рядом и сравни:
- Тайминги (карточки падают в правильном порядке, поляроид прилетает не
  одновременно со штампом, окно загорается позже сцены).
- Углы поворотов карточек.
- Тёплый цвет окна (это **жёлто-оранжевое тепло**, не белый).
- Glow на фоне — он должен быть, без него экран мёртвый.

Если что-то выглядит "почти, но не так" — открой HTML и подкрути значения
в Flutter, пока не совпадёт. CSS-числа в HTML — финальные, проверены глазом.

## Текстовые строки

```dart
// Slide 1
'Did I really\nturn it off?'
"Mark it once. We'll keep the proof.\nYou keep your evening."

// Slide 2
'Snap a photo\n— and relax.'
"A timestamped picture means\nyou don't have to wonder again."

// Slide 3
'Locked up.\nSorted.'
'You did everything you needed to.\nNow actually relax.'

// CTA
'Continue' // на 1 и 2
'Get started' // на 3

// Skip
'Skip'
```

Переводы на русский (если будет локализация) — НЕ machine-translate.
Тон голоса разговорный, человеческий. Сделай это отдельной задачей с
переводчиком, не сейчас.
