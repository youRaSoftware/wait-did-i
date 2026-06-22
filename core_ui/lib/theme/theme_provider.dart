part of 'app_theme.dart';

class AppThemeProvider extends StatefulWidget {
  final ThemeModeEnum initialMode;
  final ValueChanged<ThemeModeEnum> onModeChanged;
  final WidgetBuilder builder;

  const AppThemeProvider({
    required this.builder,
    required this.initialMode,
    required this.onModeChanged,
    super.key,
  });

  @override
  State<AppThemeProvider> createState() => _AppThemeProviderState();
}

class _AppThemeProviderState extends State<AppThemeProvider> with WidgetsBindingObserver {
  late ThemeModeEnum _mode;
  late ITokens _currentTokens;

  final ThemeData _lightTheme = AppThemeData.createTheme(LightTokens());
  final ThemeData _darkTheme = AppThemeData.createTheme(DarkTokens());

  final StreamController<ThemeModeEnum> _themeModeController = StreamController<ThemeModeEnum>.broadcast();

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _currentTokens = _resolveTokens(_mode);
    WidgetsBinding.instance.addObserver(this);
  }

  ITokens _resolveTokens(ThemeModeEnum mode) {
    switch (mode) {
      case ThemeModeEnum.light:
        return LightTokens();
      case ThemeModeEnum.dark:
        return DarkTokens();
      case ThemeModeEnum.system:
        final Brightness brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? DarkTokens() : LightTokens();
    }
  }

  void setThemeMode(ThemeModeEnum mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _currentTokens = _resolveTokens(mode);
    });
    _themeModeController.add(mode);
    widget.onModeChanged(mode);
  }

  /// Flip between light and dark (sets an explicit mode — leaves "system").
  void toggleTheme() => setThemeMode(_currentTokens is DarkTokens ? ThemeModeEnum.light : ThemeModeEnum.dark);

  void setTheme(ITokens tokens) => setThemeMode(tokens is DarkTokens ? ThemeModeEnum.dark : ThemeModeEnum.light);

  @override
  void didChangePlatformBrightness() {
    // Only follow the OS when the user picked "System".
    if (_mode != ThemeModeEnum.system) return;
    setState(() => _currentTokens = _resolveTokens(_mode));
    _themeModeController.add(_mode);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _themeModeController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      tokens: _currentTokens,
      mode: _mode,
      theme: _currentTokens is LightTokens ? _lightTheme : _darkTheme,
      setThemeMode: setThemeMode,
      toggleTheme: toggleTheme,
      setTheme: setTheme,
      themeModeStream: _themeModeController.stream,
      child: Builder(
        builder: widget.builder,
      ),
    );
  }
}

class AppTheme extends InheritedWidget {
  final ITokens tokens;
  final ThemeModeEnum mode;
  final ThemeData theme;
  final ValueChanged<ThemeModeEnum> setThemeMode;
  final VoidCallback toggleTheme;
  final ValueChanged<ITokens> setTheme;
  final Stream<ThemeModeEnum> themeModeStream;

  const AppTheme({
    required this.tokens,
    required this.mode,
    required this.theme,
    required this.setThemeMode,
    required this.toggleTheme,
    required this.setTheme,
    required this.themeModeStream,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return oldWidget.tokens != tokens || oldWidget.theme != theme || oldWidget.mode != mode;
  }

  static AppTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>();
  }
}

extension ThemeContextExtension on BuildContext {
  ITokens get currentTokens => AppTheme.of(this)!.tokens;

  ThemeData get theme => AppTheme.of(this)!.theme;

  ThemeModeEnum get themeMode => AppTheme.of(this)!.mode;

  bool get isDarkTheme => AppTheme.of(this)!.tokens is DarkTokens;

  void setThemeMode(ThemeModeEnum mode) => AppTheme.of(this)!.setThemeMode(mode);

  void toggleTheme() => AppTheme.of(this)!.toggleTheme();

  void setTheme(ITokens tokens) => AppTheme.of(this)!.setTheme(tokens);

  void switchTheme(bool isDark) => AppTheme.of(this)!.setThemeMode(isDark ? ThemeModeEnum.dark : ThemeModeEnum.light);

  Stream<ThemeModeEnum> get themeModeStream => AppTheme.of(this)!.themeModeStream;
}
