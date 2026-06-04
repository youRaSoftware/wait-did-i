import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';

/// Gallery of all core_ui widgets + a theme toggle. Used to eyeball the design
/// system in light and dark themes.
class ShowcaseScreen extends StatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  State<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends State<ShowcaseScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  int _segmentedIndex = 0;
  String _lineTabId = 'all';
  String _chipId = 'home';

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _openBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final ColorTokens color = sheetContext.currentTokens.color;
        return BaseBottomSheet(
          contentWidget: Padding(
            padding: const EdgeInsets.all(AppDimens.padding20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Bottom sheet',
                  style: sheetContext.currentTokens.textStyle.title.copyWith(color: color.colorTextPrimary),
                ),
                const SizedBox(height: AppDimens.size8),
                Text(
                  'Готово, дверь отмечена. Одного снимка достаточно.',
                  style: sheetContext.currentTokens.textStyle.body.copyWith(color: color.colorTextSecondary),
                ),
                const SizedBox(height: AppDimens.size20),
                AppButton(
                  text: 'Закрыть',
                  onPressed: () => Navigator.of(sheetContext).pop(),
                ),
                const SizedBox(height: AppDimens.size12),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return BaseDialogWidget(
          title: 'Удалить чек-лист?',
          subTitle: 'Это действие нельзя отменить.',
          actionButtons: <Widget>[
            AppButton(
              text: 'Удалить',
              style: AppButtonStyle.error,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            AppButton(
              text: 'Отмена',
              style: AppButtonStyle.secondary,
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;

    return AppScaffold(
      showBackButton: false,
      applyTopPadding: true,
      title: Text(
        'core_ui',
        style: context.currentTokens.textStyle.title.copyWith(color: color.colorTextPrimary),
      ),
      actions: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              context.isDarkTheme ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: color.colorTextSecondary,
              size: AppDimens.size20,
            ),
            const SizedBox(width: AppDimens.size4),
            Switch(
              value: context.isDarkTheme,
              activeThumbColor: color.colorBrandCoral,
              onChanged: (bool isDark) => context.switchTheme(isDark),
            ),
          ],
        ),
      ],
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimens.padding16,
          AppDimens.padding8,
          AppDimens.padding16,
          AppDimens.padding40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _Section(
              title: 'Colors',
              child: Wrap(
                spacing: AppDimens.size12,
                runSpacing: AppDimens.size12,
                children: <Widget>[
                  _Swatch(label: 'background', color: color.colorBackgroundPrimary),
                  _Swatch(label: 'surface', color: color.colorBackgroundSurface),
                  _Swatch(label: 'accent', color: color.colorBrandCoral),
                  _Swatch(label: 'success', color: color.colorStateSuccess),
                  _Swatch(label: 'warning', color: color.colorStateWarning),
                  _Swatch(label: 'error', color: color.colorStateError),
                  _Swatch(label: 'border', color: color.colorBorderDefault),
                  _Swatch(label: 'text', color: color.colorTextPrimary),
                ],
              ),
            ),
            _Section(
              title: 'Typography',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _TypeSample(label: 'display', style: context.currentTokens.textStyle.display),
                  _TypeSample(label: 'headline', style: context.currentTokens.textStyle.headline),
                  _TypeSample(label: 'title', style: context.currentTokens.textStyle.title),
                  _TypeSample(label: 'subtitle', style: context.currentTokens.textStyle.subtitle),
                  _TypeSample(label: 'body', style: context.currentTokens.textStyle.body),
                  _TypeSample(label: 'caption', style: context.currentTokens.textStyle.caption),
                ],
              ),
            ),
            _Section(
              title: 'Buttons',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppButton(text: 'Primary', onPressed: () {}),
                  const SizedBox(height: AppDimens.size12),
                  AppButton(text: 'Secondary', style: AppButtonStyle.secondary, onPressed: () {}),
                  const SizedBox(height: AppDimens.size12),
                  AppButton(text: 'Error', style: AppButtonStyle.error, onPressed: () {}),
                  const SizedBox(height: AppDimens.size12),
                  AppButton(text: 'With icon', icon: const Icon(Icons.check), onPressed: () {}),
                  const SizedBox(height: AppDimens.size12),
                  Row(
                    children: <Widget>[
                      AppButton(text: 'Text', style: AppButtonStyle.text, isExpanded: false, onPressed: () {}),
                      const SizedBox(width: AppDimens.size12),
                      AppButton(text: 'Loading', isExpanded: false, isLoading: true, onPressed: () {}),
                      const SizedBox(width: AppDimens.size12),
                      AppButton(text: 'Disabled', isExpanded: false, isDisabled: true, onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
            const _Section(
              title: 'Circle buttons',
              child: Row(
                children: <Widget>[
                  AppCircleButton(style: AppCircleButtonStyle.primary, icon: Icon(Icons.add)),
                  SizedBox(width: AppDimens.size12),
                  AppCircleButton(icon: Icon(Icons.favorite_border)),
                  SizedBox(width: AppDimens.size12),
                  AppCircleButton(style: AppCircleButtonStyle.stroke, icon: Icon(Icons.share_outlined)),
                  SizedBox(width: AppDimens.size12),
                  AppCircleButton(isLoading: true, icon: Icon(Icons.add)),
                ],
              ),
            ),
            _Section(
              title: 'Phosphor icons',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Raw icons: outline (left group) vs filled (right group).
                  Wrap(
                    spacing: AppDimens.size16,
                    runSpacing: AppDimens.size16,
                    children: <Widget>[
                      _Icon(AppAssets.resourcesIconsOutlineBell, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsOutlineHouse, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsOutlineGear, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsOutlineHeart, color: color.colorBrandCoral),
                      _Icon(AppAssets.resourcesIconsFilledBellFill, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsFilledHouseFill, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsFilledGearFill, color: color.colorTextPrimary),
                      _Icon(AppAssets.resourcesIconsFilledHeartFill, color: color.colorBrandCoral),
                    ],
                  ),
                  const SizedBox(height: AppDimens.size16),
                  // Inside buttons: AppImage ignores IconTheme, so the content
                  // color is passed explicitly to match each button style.
                  AppButton(
                    text: 'Добавить напоминание',
                    icon: AppImage(
                      image: AppAssets.resourcesIconsOutlinePlus,
                      width: AppDimens.size24,
                      height: AppDimens.size24,
                      color: color.colorTextInverse,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimens.size12),
                  AppButton(
                    text: 'Отметить выполненным',
                    style: AppButtonStyle.secondary,
                    icon: AppImage(
                      image: AppAssets.resourcesIconsOutlineCheckCircle,
                      width: AppDimens.size24,
                      height: AppDimens.size24,
                      color: color.colorTextPrimary,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimens.size12),
                  AppButton(
                    text: 'Удалить',
                    style: AppButtonStyle.error,
                    icon: AppImage(
                      image: AppAssets.resourcesIconsFilledTrashFill,
                      width: AppDimens.size24,
                      height: AppDimens.size24,
                      color: color.colorTextInverse,
                    ),
                    onPressed: () {},
                  ),
                  const SizedBox(height: AppDimens.size16),
                  Row(
                    children: <Widget>[
                      AppCircleButton(
                        style: AppCircleButtonStyle.primary,
                        icon: AppImage(
                          image: AppAssets.resourcesIconsOutlinePlus,
                          width: AppDimens.size24,
                          height: AppDimens.size24,
                          color: color.colorTextInverse,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppDimens.size12),
                      AppCircleButton(
                        icon: AppImage(
                          image: AppAssets.resourcesIconsOutlineBell,
                          width: AppDimens.size24,
                          height: AppDimens.size24,
                          color: color.colorTextPrimary,
                        ),
                        onPressed: () {},
                      ),
                      const SizedBox(width: AppDimens.size12),
                      AppCircleButton(
                        style: AppCircleButtonStyle.stroke,
                        icon: AppImage(
                          image: AppAssets.resourcesIconsOutlineGear,
                          width: AppDimens.size24,
                          height: AppDimens.size24,
                          color: color.colorTextPrimary,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Inputs',
              child: Column(
                children: <Widget>[
                  AppInputField(controller: _inputController, hintText: 'Имя списка'),
                  const SizedBox(height: AppDimens.size12),
                  AppInputField(
                    controller: _passwordController,
                    hintText: 'Пароль',
                    obscureText: true,
                    prefixWidget: Icon(Icons.lock_outline, size: AppDimens.size20, color: color.colorTextTertiary),
                  ),
                  const SizedBox(height: AppDimens.size12),
                  const AppInputField(hintText: 'С ошибкой', errorText: 'Поле обязательно'),
                  const SizedBox(height: AppDimens.size12),
                  AppSearchField(
                    controller: _searchController,
                    hintText: 'Поиск',
                    onCancel: _searchController.clear,
                  ),
                ],
              ),
            ),
            const _Section(
              title: 'Code input',
              child: AppCodeInput(),
            ),
            _Section(
              title: 'Bio field',
              child: AppBioField(controller: _bioController, hintText: 'Заметка', maxLength: 120),
            ),
            _Section(
              title: 'Segmented tabs',
              child: SegmentedTabBar(
                labels: const <String>['Выход', 'Перед сном'],
                selectedIndex: _segmentedIndex,
                margin: EdgeInsets.zero,
                onTabChanged: (int i) => setState(() => _segmentedIndex = i),
              ),
            ),
            _Section(
              title: 'Line tabs',
              child: AppLineTabBar(
                items: const <AppLineTabItem>[
                  AppLineTabItem(id: 'all', label: 'Все'),
                  AppLineTabItem(id: 'today', label: 'Сегодня'),
                  AppLineTabItem(id: 'week', label: 'Неделя'),
                  AppLineTabItem(id: 'archive', label: 'Архив'),
                ],
                selectedId: _lineTabId,
                onSelected: (String id) => setState(() => _lineTabId = id),
                padding: EdgeInsets.zero,
              ),
            ),
            _Section(
              title: 'Chip tabs',
              child: HorizontalChipTabs(
                items: const <ChipTabItem>[
                  ChipTabItem(id: 'home', label: 'Дом'),
                  ChipTabItem(id: 'office', label: 'Офис'),
                  ChipTabItem(id: 'car', label: 'Машина'),
                  ChipTabItem(id: 'cottage', label: 'Дача'),
                ],
                selectedId: _chipId,
                onSelected: (String id) => setState(() => _chipId = id),
                padding: EdgeInsets.zero,
              ),
            ),
            const _Section(
              title: 'Toasts',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  ToastWidget(message: 'Готово, всё отмечено', toastType: ToastType.success),
                  SizedBox(height: AppDimens.size8),
                  ToastWidget(message: 'Стоит проверить ещё раз', toastType: ToastType.warning),
                  SizedBox(height: AppDimens.size8),
                  ToastWidget(message: 'Что-то пошло не так', toastType: ToastType.error),
                  SizedBox(height: AppDimens.size8),
                  ToastWidget(message: 'Напоминание поставлено'),
                ],
              ),
            ),
            _Section(
              title: 'Modals',
              child: Row(
                children: <Widget>[
                  AppButton(text: 'Bottom sheet', isExpanded: false, onPressed: _openBottomSheet),
                  const SizedBox(width: AppDimens.size12),
                  AppButton(text: 'Dialog', isExpanded: false, style: AppButtonStyle.secondary, onPressed: _openDialog),
                ],
              ),
            ),
            _Section(
              title: 'Stat cards',
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: StatCard(
                      title: 'Проверено',
                      value: '12',
                      icon: Icons.check_circle_outline,
                      accentColor: color.colorStateSuccess,
                    ),
                  ),
                  const SizedBox(width: AppDimens.size12),
                  Expanded(
                    child: StatCard(
                      title: 'Напоминаний',
                      value: '3',
                      icon: Icons.notifications_none,
                      accentColor: color.colorBrandCoral,
                    ),
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Settings list',
              child: SettingsTileSection(
                children: <Widget>[
                  SettingsTile(
                    title: 'Уведомления',
                    leading: Icon(Icons.notifications_none, color: color.colorTextSecondary, size: AppDimens.size20),
                    trailing: Icon(Icons.chevron_right, color: color.colorTextTertiary),
                    onTap: () {},
                  ),
                  SettingsTile(
                    title: 'Face ID',
                    leading: Icon(Icons.lock_outline, color: color.colorTextSecondary, size: AppDimens.size20),
                    trailing: Switch(value: true, activeThumbColor: color.colorBrandCoral, onChanged: (_) {}),
                  ),
                  SettingsTile(
                    title: 'Удалить все данные',
                    titleColor: color.colorStateError,
                    leading: Icon(Icons.delete_outline, color: color.colorStateError, size: AppDimens.size20),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            _Section(
              title: 'Section header + context menu',
              child: SectionHeader(
                title: 'Выход из дома',
                badgeColor: color.colorStateWarning,
                trailing: BaseContextMenu(
                  items: <ContextMenuModel>[
                    ContextMenuModel(title: 'Переименовать', icon: Icons.edit_outlined, onTap: () {}),
                    ContextMenuModel(
                      title: 'Дублировать',
                      icon: Icons.copy_outlined,
                      onTap: () {},
                      showDividerAfter: true,
                    ),
                    ContextMenuModel(title: 'Удалить', icon: Icons.delete_outline, isDestructive: true, onTap: () {}),
                  ],
                ),
              ),
            ),
            _Section(
              title: 'Shimmer',
              child: Row(
                children: <Widget>[
                  ShimmerBox(
                    width: AppDimens.size48,
                    height: AppDimens.size48,
                    borderRadius: BorderRadius.circular(AppDimens.borderRadius12),
                  ),
                  const SizedBox(width: AppDimens.size12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ShimmerBox(
                          width: AppDimens.size160,
                          height: AppDimens.size14,
                          borderRadius: BorderRadius.circular(AppDimens.borderRadius6),
                        ),
                        const SizedBox(height: AppDimens.size8),
                        ShimmerBox(
                          width: AppDimens.size100,
                          height: AppDimens.size14,
                          borderRadius: BorderRadius.circular(AppDimens.borderRadius6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const _Section(
              title: 'Loader',
              child: Center(child: AppLoader()),
            ),
          ],
        ),
      ),
    );
  }
}

/// Titled block wrapper used between showcase sections.
class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.padding28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title.toUpperCase(),
            style: context.currentTokens.textStyle.overline.copyWith(color: color.colorTextTertiary),
          ),
          const SizedBox(height: AppDimens.size12),
          child,
        ],
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  final String asset;
  final Color color;

  const _Icon(this.asset, {required this.color});

  @override
  Widget build(BuildContext context) {
    return AppImage(
      image: asset,
      width: AppDimens.size28,
      height: AppDimens.size28,
      color: color,
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;

  const _Swatch({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final ColorTokens tokens = context.currentTokens.color;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: AppDimens.size56,
          height: AppDimens.size56,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(AppDimens.borderRadius12),
            border: Border.all(color: tokens.colorBorderDefault),
          ),
        ),
        const SizedBox(height: AppDimens.size4),
        SizedBox(
          width: AppDimens.size56,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.currentTokens.textStyle.overline.copyWith(color: tokens.colorTextSecondary),
          ),
        ),
      ],
    );
  }
}

class _TypeSample extends StatelessWidget {
  final String label;
  final TextStyle style;

  const _TypeSample({required this.label, required this.style});

  @override
  Widget build(BuildContext context) {
    final ColorTokens color = context.currentTokens.color;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDimens.size8),
      child: Text(
        '$label — Wait, Did I?',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: style.copyWith(color: color.colorTextPrimary),
      ),
    );
  }
}
