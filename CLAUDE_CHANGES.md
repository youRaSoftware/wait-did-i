# CLAUDE_CHANGES.md

Лог изменений, сделанных через Claude Code. Новые задачи добавляются сверху.
Легенда статусов: ✅ сделано · 🚧 в работе · ❌ отменено.

---

## 2026-06-22 — Тема: System / Light / Dark в настройках (персист)

**Задача:** Добавить в настройки выбор темы. Раньше провайдер темы принудительно следовал
системной яркости (перебивал dark-дефолт) и выбор не сохранялся между запусками.

### Что сделано

- ✅ `ThemeService` (core, SharedPreferences) — хранит `ThemeModeEnum` (system / light / dark),
  дефолт **dark**; зарегистрирован в `app_di` (тот же prefs, что у `OnboardingService`).
- ✅ `AppThemeProvider` переписан на режимы: `initialMode` + `onModeChanged`; `_resolveTokens`
  (system → яркость платформы, light/dark → фикс). `didChangePlatformBrightness` следует системе
  **только** в режиме `system`. `AppTheme` отдаёт `mode` + `setThemeMode`; в extension добавлены
  `context.themeMode` / `context.setThemeMode`. `toggleTheme` / `switchTheme` / `setTheme` сохранены
  (через режимы) — витрина не сломана. Заодно убран deprecated `window.platformBrightness`
  (→ `platformDispatcher`) — ушли и предсуществующие deprecation-варнинги.
- ✅ `lib/app.dart` — `initialMode: appLocator<ThemeService>().mode`,
  `onModeChanged: appLocator<ThemeService>().setMode`.
- ✅ `features/lib/settings/screen/settings_form.dart` — секция «Тема»: `SettingsTileSection` с тремя
  `SettingsTile` (System / Light / Dark; активный помечен галочкой в акценте), тап →
  `context.setThemeMode`. Лейблы — существующие `common.system/light/dark`; добавлен `settings.theme`.

### Проверка

- Перегенерированы ключи; `flutter analyze` — 0 по нашему коду (остаются предсуществующие removed-lint
  в `analysis_options.yaml`). `dart format` — ок.
- 🚧 Прогон (нужен **hot restart**, т.к. меняется bootstrap/DI): Settings → Light → весь app светлеет
  мгновенно; kill/relaunch — выбор сохранён; System — следует системе; дефолт на чистой установке — Dark.

---

## 2026-06-22 — Главный экран (активный чек-лист) + hive_ce

**Задача:** Реализовать главный экран по `.claude/specs/home/`: активный чек-лист сразу при
запуске, три состояния (empty / idle / checking), табы списков, анимированные чекбоксы,
прогресс-бар, bottom hint, FAB. Хранение — hive_ce.

### Решения

- ✅ Главный экран — **themed** (токены `context.currentTokens.color`), не локальная палитра.
  Dark-значения токенов совпадают с эталоном → выглядит как спека, при светлой теме адаптируется.
- ✅ Чистая архитектура: domain Freezed-модели + интерфейс репо; data hive_ce (entities + адаптеры
  через `@GenerateAdapters` + mapper + provider + impl); DI + `Hive.initFlutter` в `dataDI.preLoginScope`.
  Кубит — конструктор-инъекция репозитория (screen резолвит `appLocator<ChecklistRepository>`).
- ✅ Сид трёх стартовых списков — Home (Leaving home) / Bed (Before bed) / Car — один раз
  (флаг seed `v2` в Hive). Появляется таб-свитчер; empty-состояние достижимо, если удалить все.
- ✅ Переключение списков — `PageView` (свайп + плавный горизонтальный слайд); тап по табу
  анимирует страницу (`animateToPage`), свайп обновляет активный таб (`onPageChanged`). `HomeForm`
  стал `StatefulWidget` ради `PageController`. (Был резкий `AnimatedSwitcher`-fade.)
- ✅ `ListSwitcher` переписан: единая «пилюля», которая едет по позиции `PageController`
  (`AnimatedBuilder`), отслеживая свайп; цвет лейблов интерполируется. Раньше каждый таб
  анимировал свой фон/тень независимо (`AnimatedContainer`) — это и давало «моргание».
- ✅ Greeting по времени суток + состоянию; allDone-приветствие на ~3с, потом обратно в idle.
- ⚠️ Фото-флоу, экран добавления списка, детальный экран — заглушки (snackbar); модель готова под фото.
- ⚠️ Имена дефолтного списка/пунктов — английские (редактируемый контент; UI-чрома локализована).

### Файлы

- **domain:** `models/checklist/{checklist_model,checklist_item_model}.dart` (Freezed),
  `repositories/checklist_repository.dart`, барелы.
- **data:** `entities/{checklist_entity,checklist_item_entity}.dart`, `hive/hive_adapters.dart`
  (+ сгенерированные `hive_adapters.g.dart` / `hive_registrar.g.dart`),
  `providers/hive/checklist_hive_provider.dart`, `mappers/checklist/checklist_mapper.dart`,
  `repositories/checklist_repository_impl.dart`, `di/data_di.dart` (Hive init + регистрация),
  `pubspec.yaml` (+ `hive_ce`, `hive_ce_flutter`, dev `hive_ce_generator`).
- **features/home:** `cubit/{home_cubit,home_state}.dart` (переписаны),
  `screen/{home_screen,home_form}.dart`, `widgets/` (greeting_header, list_switcher, checklist_view,
  checklist_item, home_progress_line, bottom_hint, add_fab, home_empty_state, home_background_glow).
- **Локализация:** блок `home.*` заменён на новый набор (greetings / прогресс / мета / пусто / хинты),
  EN финал + RU черновик; перегенерирован `locale_keys.g.dart`.

### Проверка

- `flutter pub get --offline` (hive_ce из кэша), build_runner в domain + data — ок.
- `flutter analyze` — 0 замечаний по новому коду (остаются предсуществующие removed-lint в
  `analysis_options.yaml` и deprecated `window` в `theme_provider.dart`). `dart format` — ок.
- 🚧 Прогон на симуляторе, сверка с `reference.html`, проверка персиста (kill/relaunch) — за пользователем.

---

## 2026-06-22 — Разбор корня: специи фич в `.claude/specs/`, бриф влит в PLAN.md

**Задача:** Перестать кидать спеки/эталоны и версионные `CLAUDE_N.md` в корень.
Навести порядок и зафиксировать конвенцию именования.

### Что сделано

- ✅ `.claude/specs/<feature>/` — новая папка под дизайн-спеки фич. Перемещены:
  - `ONBOARDING_SPEC.md` → `.claude/specs/onboarding/spec.md`
  - `onboarding_final.html` → `.claude/specs/onboarding/reference.html`
  - `HOME_SCREEN_SPEC.md` → `.claude/specs/home/spec.md`
  - `home_screen_final.html` → `.claude/specs/home/reference.html`
- ✅ `.claude/specs/README.md` — конвенция: фича → `spec.md` + `reference.html`,
  эталон главнее кода, продуктовый контекст живёт в `PLAN.md` (без `CLAUDE_N`).
- ✅ `CLAUDE_2.md` / `CLAUDE_3.md` удалены; `CLAUDE_3` (новее, = бриф + главный экран)
  влит в `PLAN.md`: UX-фразы (greetings/прогресс/дефолтные пункты), dark-токены,
  шрифт Manrope, кривые анимаций (`easeOutBack`/`easeOutCubic`), haptic на чекбоксах,
  иконка-ключ, маскот «Дотти», главный экран + авто-создание дефолтного списка
  `Leaving home`. Заодно поправлено: шрифт (был «Inter»), FVM (не используется).
- ✅ Ссылки обновлены: внутри спек (`onboarding_final.html`/`home_screen_final.html`
  → `reference.html`), в doc-комментах онбординга (→ `.claude/specs/onboarding/reference.html`),
  в `PLAN.md` (→ `.claude/specs/...`), в `.claude/my_docs/ROADMAP.md`.

### Конвенция (на будущее)

- Дизайн фичи → `.claude/specs/<feature>/spec.md` + `reference.html`. В корень — не кидать.
- Продуктовый контекст → `PLAN.md` (один источник, без версионных `CLAUDE_N.md`).
- Корень держим чистым: `CLAUDE.md`, `PLAN.md`, `CLAUDE_CHANGES.md`, `README.md`.

---

## 2026-06-22 — Тёмная тема по умолчанию

**Задача:** Сделать тёмную тему дефолтной при запуске (онбординг тёмный → home тоже тёмный,
без скачка). Светлая тема — опцией в настройках позже. Снять противоречие старого PLAN
(«только светлая») и `CLAUDE_2.md` («тёмная — основная»).

### Что сделано

- ✅ `lib/app.dart` — `initialTokens: LightTokens()` → `DarkTokens()`. Home/Settings token-driven,
  поэтому переключаются на тёмные значения автоматически.
- ✅ `PLAN.md` и `.claude/my_docs/ROADMAP.md` — формулировки темы приведены к «тёмная по умолчанию,
  светлая — опцией в настройках (позже)».
- 🚧 Тоггл светлой темы в настройках — отдельной задачей (пламбинг уже есть:
  `context.toggleTheme()` / `context.switchTheme(bool)`; нужна UI-строка в настройках + персист флага).

---

## 2026-06-22 — Новый анимированный онбординг (3 слайда)

**Задача:** Реализовать новый онбординг по эталону `onboarding_final.html` (+ `ONBOARDING_SPEC.md`,
`CLAUDE_2.md`): 3 тёмных слайда с анимациями — падающие карточки, поляроид с проявкой и штампом,
ночная сцена дома. Заменить старый плейсхолдер-онбординг, сохранив нашу архитектуру.

### Решения

- ✅ Визуал/тайминги — точно по HTML-эталону; **архитектура — наша** (cubit/screen/form, go_router,
  `OnboardingService`-гейт уже были — переиспользованы без изменений).
- ✅ Палитра онбординга — локальная (`onboarding_colors.dart`), dark-only, пиксель-в-пиксель к эталону
  (осознанное исключение из правила «только токены»: бэстрые значения поляроида/сцены не являются
  токенами, а онбординг тёмный независимо от темы приложения).
- ✅ Иллюстрации — `CustomPaint` (дверь, ночная сцена, пунктирный кружок, галочка) — больше контроля
  над покадровой анимацией, без новых зависимостей.
- ✅ RU — авторский перевод-черновик в тоне бренда (помечен как draft, нужна вычитка переводчиком).
- ✅ Manrope 700 уже был забандлен — доп. правок шрифта не потребовалось.

### Изменённые / добавленные файлы

- `features/lib/onboarding/screen/onboarding_form.dart` — переписан: `Scaffold` + `Stack`
  (glow → `PageView` из 3 слайдов → прогресс+Skip сверху → точки+CTA снизу). Skip → последний слайд;
  CTA на последнем → `cubit.finish()`.
- `features/lib/onboarding/widgets/`: `onboarding_colors.dart` (палитра + текстстили), `onboarding_motion.dart`
  (кривые `easeOutBack`/`easeOutCubic` + интервалы таймингов), `onboarding_background_glow.dart`,
  `onboarding_progress_bar.dart`, `onboarding_page_dots.dart` (заменил `onboarding_dots.dart`),
  `onboarding_cta_button.dart` (+ `HapticService`).
- `features/lib/onboarding/widgets/painters/`: `check_mark_painter.dart` (галочка + пунктирный кружок),
  `polaroid_door_painter.dart`, `night_house_painter.dart` (параметризован `windowOpacity` + opacity звёзд).
- `features/lib/onboarding/slides/`: `onboarding_slide_frame.dart` (общий каркас + перезапуск анимации
  по `isActive` + появление заголовка/подзаголовка), `slide_falling_cards.dart`, `slide_polaroid.dart`,
  `slide_night_house.dart`.
- Удалены `widgets/onboarding_dots.dart`, `widgets/onboarding_step_view.dart` (старый плейсхолдер).
- `core/resources/translations/en-US.json` + `ru-RU.json` — блок `onboarding.*` заменён на новые ключи
  (`slide1..3Title/Subtitle`, `continueLabel`, `getStarted`, `skip`, `slide2PolaroidCaption`); перегенерирован
  `core/lib/localization/locale_keys.g.dart`.
- `cubit/onboarding_cubit.dart` / `onboarding_state.dart` — без изменений (хватило `currentIndex`/`isLast`/
  `onPageChanged`/`finish`).

### Проверка

- `flutter analyze features core` — **0 issues**. `dart format` — ок.
- Анимации перезапускаются при возврате к слайду (`isActive` → `forward(from: 0)`); Skip ведёт на финал,
  не закрывает; флаг `OnboardingService` после «Начать» → следующий запуск сразу на `/home`.
- 🚧 Визуальная сверка с `onboarding_final.html` на устройстве/симуляторе — за пользователем
  (тайминги, углы карточек, тёплое окно, glow).
- ⚠️ RU-тексты — черновик, нужна финальная вычитка переводчиком.

---

## 2026-06-05 — Удаление Figma-токенов из скриптов и истории git

**Задача:** GitHub Push Protection блокировал пуш `develop`: в коммите "Add scripts"
были захардкожены два Figma Personal Access Token. Убрать секреты и запушить.

### Что сделано

- ✅ `script/export_figma_flags.sh` — токен заменён на обязательную переменную окружения
  `FIGMA_TOKEN` (`${FIGMA_TOKEN:?...}` с подсказкой по запуску).
- ✅ `script/export_figma_icons.sh` — то же самое.
- ✅ История переписана (`git commit --fixup` + `rebase --autosquash`): фикс вшит в исходный
  коммит "Add scripts", секреты удалены из истории, а не только из рабочей копии.
- ✅ Пуш `develop` прошёл успешно (`f24b122..7dea4e9`).

### Проверка

- `bash -n` обоих скриптов — синтаксис OK.
- `git log -p origin/develop..develop | grep figd_` перед пушем — реальных токенов нет,
  только плейсхолдер `figd_xxx` в тексте подсказки.

### Важно (действие пользователя)

- ❗ Старые токены (`figd_JXXq...`, `figd_v8mb...`) нужно отозвать в Figma:
  Settings → Security → Personal access tokens. Запуск скриптов теперь:
  `FIGMA_TOKEN=figd_xxx ./script/export_figma_icons.sh`

---

## 2026-05-26 — Экран-витрина core_ui + переключение темы (стартовый экран)

**Задача:** Сделать первый экран витриной всех виджетов core_ui с переключателем
светлой/тёмной темы — для визуальной проверки дизайн-системы.

### Что сделано

- ✅ `features/lib/showcase/screen/showcase_screen.dart` — `ShowcaseScreen`: прокручиваемая
  галерея со всеми виджетами (цвета-свотчи, типографика, кнопки, инпуты, code/bio,
  табы segmented/line/chip, тосты, модалки bottom sheet/dialog, stat cards, settings list,
  section header + context menu, shimmer, loader). В app bar — переключатель темы
  (`Switch` + `context.switchTheme`).
- ✅ `features/lib/features.dart` — экспорт `showcase_screen.dart`.
- ✅ `navigation/.../router_constants.dart` — добавлена `showcaseRoute = '/showcase'`.
- ✅ `navigation/.../app_router.dart` — добавлен `GoRoute` showcase, `initialLocation`
  переключён на него (стартовый экран). Маршрут example сохранён.

### Проверка

- `flutter analyze` — по витрине и роутеру 0 замечаний. Остаются предсуществующие:
  7 warning о removed-lints в `analysis_options.yaml` и 2 info `deprecated window`
  в `theme_provider.dart` — не относятся к задаче.

### Дальнейшие шаги

- Прогнать `fvm flutter run --flavor dev` и поглядеть витрину в обеих темах.
- Витрина временная — при появлении реальных экранов поменять `initialLocation` назад.

---

## 2026-05-26 — Перенос UI kit из проекта rvach (в нашем стиле и цветах)

**Задача:** Взять базовые generic-виджеты UI kit из `/Users/yury/StudioProjects/rvach`
(кнопки, инпуты, модалки, табы и т.д.) и перенести в `wait_did_i`, адаптировав под наши
токены и плоский спокойный стиль из PLAN. Без доменных виджетов (achievement/match/
player_card/season/medal/premium).

### Решения по адаптации (согласованы)

- ✅ Стиль — под PLAN: убраны blur/BackdropFilter, свечение (glow), градиенты; плоские
  поверхности, тонкие границы, наши цвета. API и анимации нажатия сохранены.
- ✅ Размеры — наш `AppDimens` на фиксированных `double` (без flutter_screenutil).
- ✅ Иконки — Material Icons вместо SVG-ассетов (`AppImage`/`AppAssets` не переносились).
- ✅ Маппинг токенов rvach→наши: `orangeAccentPrimary`→`colorBrandCoral`,
  `white2/8/...`→`colorBackgroundSurface/Secondary`/`colorBorderDefault`,
  `systemRed`→`colorStateError`, текстстили `texts16pxRegular`→`body` и т.п.

### Фундамент

- ✅ `core`: добавлен `HapticService` (`service/haptic_service.dart`, экспортирован из `services.dart`).
- ✅ `core_ui`: `AppDimens` дополнен `borderRadius*`/`padding*`/`margin*`/`opacity*`/`thickness*`.
- ✅ `core_ui/core_ui.dart`: экспортирует `theme/app_dimens.dart`.
- ✅ `core_ui/pubspec.yaml`: добавлен `pinput: ^5.0.1` (для code input).

### Перенесённые виджеты (26)

- Кнопки: `AppButton` (primary/secondary/error/text × large/medium/small), `AppCircleButton`.
- Инпуты: `AppInputField`, `AppSearchField`, `AppCodeInput` (pinput), `AppBioField`.
- Скаффолд/навбар: `AppScaffold`, `CustomAppBar`, `AppBottomNavBar` (упрощён: без анимированной центральной FAB; `AppBottomNavItem` на `IconData`).
- Модалки: `BaseBottomSheet`, `BaseDialogWidget`.
- Тост: `ToastWidget` (+ локальный enum `ToastType` success/error/warning/info).
- Табы: `SegmentedTabBar`, `AppLineTabBar`, `HorizontalChipTabs`, `StickyChipTabsHeader` (модели упрощены до id+label, без logoUrl/liveCount).
- Контекст-меню: `ContextMenuModel`, `ContextMenuItem`, `BaseContextMenu` (на штатном `PopupMenuButton`; форк `custom_popup_menu_button.dart` НЕ переносился).
- Лоадеры: `AppLoader`, `BouncingDotsLoader`.
- Прочее: `SectionHeader`, `SettingsTile`, `SettingsTileSection`, `ShimmerBox`, `StatCard` (плоский, без градиента и AnimatedCountText).

Все экспортируются из `core_ui/lib/widgets/widgets.dart`.

### Не переносилось (доменное/инфра)

achievement/*, match/*, player_card/*, competition/*, season/*, `medal_widget`,
`premium_gate`, `achievement_unlock_overlay`, `animated_count_text`,
`animated_gradient_background`, `app_image`, `empty_state/mascot_message`,
`custom_popup_menu_button` (форк Material).

### Проверка

- `flutter pub get` — ок (pinput 5.0.2).
- `flutter analyze core_ui core` — 0 ошибок/warning по перенесённым виджетам.
  Остаются 2 `info` (`deprecated_member_use: window`) в предсуществующем
  `core_ui/lib/theme/theme_provider.dart` — не относятся к этой задаче.

### Открытые вопросы / дальнейшие шаги

- ✅ Удалён `buttons/primary_button.dart` (заглушка); единственное использование в
  `features/lib/example/screen/example_form.dart` заменено на `AppButton`.
- Визуально прогнать на устройстве: проверить контраст/радиусы под PLAN-палитру.

---

## 2026-05-26 — Замена палитры и шрифта дизайн-токенов на «спокойный голубой»

**Задача:** Заменить значения дизайн-токенов (тема) в JSON под палитру из PLAN.md
(«Палитра A — спокойный голубой») и перегенерировать Dart-токены. Структуру и ключи
токенов не менять — только значения.

### Что сделано

- ✅ `tokens/light.json` — фон `#F4F7F9`, карточки `#FFFFFF`, акцент `#5A9BD4`, текст `#2D3748`/`#718096`/`#A0AEC0`, граница `#E2E8F0`, success `#68C58F`, warning `#E8B860`, info `#5A9BD4`, error `#E07A7A`.
- ✅ `tokens/dark.json` — придумана тёмная тема в синей гамме (фон `#0F1419`→`#252E3A`, текст `#F7FAFC`/`#B4C0CE`/`#718096`, акцент/состояния как в light, границы — accent-tinted rgba).
- ✅ `primitives/mobile.json` — brand перекрашен в сине-зелёное семейство (coral=акцент `#5A9BD4`, mint=`#68C58F`), neutral переведён из тёплых в холодные slate-тона, supportive синхронизирован, описания поправлены.
- ✅ `global.json` — тени из тёплого чёрного в холодный `#2D3748`-alpha, glow primary→`#5A9BD4`, secondary→`#68C58F`.
- ✅ Шрифт: display-шрифт `Playfair Display` → `Inter` (по PLAN: без декоративных). Inter уже забандлен в `core/resources/fonts/`.
- ✅ Error-токен — мягкий приглушённый `#E07A7A` (PLAN запрещает алармный красный).
- ✅ Перегенерированы `tokens.g.dart` / `tokens_extra.g.dart` через `figma2flutter` (53 color, 11 textStyle, 5 shadow). Ключи/имена полей не изменились — код, использующий токены, не затронут.

### Изменённые файлы

- `core_ui/lib/theme/generate/tokens/tokens/light.json`
- `core_ui/lib/theme/generate/tokens/tokens/dark.json`
- `core_ui/lib/theme/generate/tokens/primitives/mobile.json`
- `core_ui/lib/theme/generate/tokens/global.json`
- `core_ui/lib/theme/generate/tokens.g.dart` (перегенерирован)
- `core_ui/lib/theme/generate/tokens_extra.g.dart` (перегенерирован)

### Детали и решения

- Источник — JSON (Tokens Studio); `figma2flutter` генерирует Dart. Команда:
  `fvm dart pub global run figma2flutter --input core_ui/lib/theme/generate/tokens --output core_ui/lib/theme/generate/`.
- Ключи токенов сохранены, чтобы не ломать сгенерированные имена полей (`brandCoral`, `colorBackgroundPrimary` и т.п.). Поэтому brand-слоты `peach/lavender/ocean` остались под старыми именами, но с новыми голубыми значениями.
- Значения, которых нет в PLAN (третичный текст `#A0AEC0`, disabled, светлый акцент `#8FBDE0`, вторичный фон `#ECF1F5`, тёмная тема), подобраны в гамме slate/blue (Tailwind-совместимо) — при желании легко скорректировать.

### Открытые вопросы / дальнейшие шаги

- Необязательная чистка: `Playfair Display` больше не используется — можно убрать из `pubspec.yaml` и `core/resources/fonts/`.
- Стоит свериться визуально, прогнав приложение, что контраст текста на новом фоне комфортный.

---

## 2026-05-26 — Настройка бандлов, имени приложения и проектных документов

**Задача:** Настроить bundle id / package на Android и iOS (`com.pyf.waitdidi`
для prod, с суффиксами `.dev` / `.stage`) и отображаемое имя `Wait, Did I?`
(DEV/STAGE для не-прод окружений). Завести проектные документы PLAN.md и
CLAUDE_CHANGES.md.

### Что сделано

- ✅ Android: `namespace` и `applicationId` → `com.pyf.waitdidi` (было `com.example.template`).
- ✅ Android: имена по флейворам через `resValue` app_name → `Wait, Did I?` / `… STAGE` / `… DEV`.
- ✅ Android: `MainActivity.kt` перемещён в пакет `com.pyf.waitdidi`, обновлён `package`.
- ✅ Android: `android:label` в манифесте → `@string/app_name` (был хардкод `template`).
- ✅ iOS: `APP_NAME` по конфигурациям (Debug/Release × dev/stage/prod) → `Wait, Did I?` (+ DEV/STAGE).
- ✅ iOS: bundle id у таргета `RunnerTests` → `com.pyf.waitdidi.RunnerTests`.
- ✅ iOS: `CFBundleName` → `Wait, Did I?` (был `template`). Bundle id таргета Runner (`com.pyf.waitdidi[.dev/.stage]`) уже был задан ранее.
- ✅ Созданы `PLAN.md` (концепция продукта) и `CLAUDE_CHANGES.md` (этот файл).

### Итоговые идентификаторы

| Flavor | applicationId / bundle id | Display name |
|--------|---------------------------|--------------|
| prod   | `com.pyf.waitdidi`        | Wait, Did I? |
| stage  | `com.pyf.waitdidi.stage`  | Wait, Did I? STAGE |
| dev    | `com.pyf.waitdidi.dev`    | Wait, Did I? DEV |

### Изменённые / добавленные файлы

- `android/app/build.gradle.kts` — namespace, applicationId, app_name по флейворам.
- `android/app/src/main/AndroidManifest.xml` — `android:label` → `@string/app_name`.
- `android/app/src/main/kotlin/com/pyf/waitdidi/MainActivity.kt` — перемещён из `com/example/template/`, обновлён package.
- `ios/Runner.xcodeproj/project.pbxproj` — `APP_NAME` по конфигурациям, bundle id `RunnerTests`.
- `ios/Runner/Info.plist` — `CFBundleName`.
- `PLAN.md` — новый, концепция продукта.
- `CLAUDE_CHANGES.md` — новый, этот лог.

### Детали и решения

- iOS-флейворинг (схемы `dev`/`stage`/`prod`, конфигурации `Debug-*`/`Release-*`,
  bundle id) был заведён в предыдущем коммите «Update for iOS» — изменены только
  плейсхолдеры имени, структура схем не трогалась.
- Display name берётся из `$(APP_NAME)` через `CFBundleDisplayName` на iOS и из
  `@string/app_name` (генерится `resValue` на флейвор) на Android.
- Dart-сторона флейворов уже работает: `main.dart` читает `--dart-define=environment`,
  `AppConfig.fromFlavor` (`core/lib/config/app_config.dart`) выдаёт конфиг на окружение.
- Валидация: `plutil -lint project.pbxproj` → OK; `xcodebuild -list` видит все 6 конфигураций и схемы.

### Открытые вопросы / дальнейшие шаги

- `AppConfig.apiBaseUrl` — заглушки `*.example.com`, нужны реальные адреса.
- Не настроены: иконки на флейвор (`flutter_launcher_icons`), splash (`flutter_native_splash`),
  разрешения камеры/фото (iOS Info.plist + Android manifest), release-подпись Android,
  iOS signing/Team и регистрация bundle id в сторах.
