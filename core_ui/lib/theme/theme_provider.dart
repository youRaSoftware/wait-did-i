part of 'app_theme.dart';

class AppThemeProvider extends StatefulWidget {
  final ITokens? initialTokens;
  final WidgetBuilder builder;

  const AppThemeProvider({
    required this.builder,
    this.initialTokens,
    super.key,
  });

  @override
  _AppThemeProviderState createState() => _AppThemeProviderState();
}

class _AppThemeProviderState extends State<AppThemeProvider> with WidgetsBindingObserver {
  late ITokens _currentTokens;

  final ThemeData _lightTheme = AppThemeData.createTheme(LightTokens());
  final ThemeData _darkTheme = AppThemeData.createTheme(DarkTokens());

  @override
  void initState() {
    super.initState();
    _currentTokens = widget.initialTokens ?? LightTokens();
    WidgetsBinding.instance.addObserver(this);
    _notifyChangeTheme();
  }

  void toggleTheme() {
    setState(() {
      _currentTokens = _currentTokens is LightTokens ? DarkTokens() : LightTokens();
    });
  }

  void setTheme(ITokens tokens) {
    setState(() {
      _currentTokens = tokens;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _notifyChangeTheme();
  }

  void _notifyChangeTheme() {
    log(
      'System theme changed to ${WidgetsBinding.instance.window.platformBrightness}',
    );
    final Brightness brightness = WidgetsBinding.instance.window.platformBrightness;
    if (brightness == Brightness.dark) {
      setTheme(DarkTokens());
      _themeModeController.add(ThemeModeEnum.dark);
    } else {
      setTheme(LightTokens());
      _themeModeController.add(ThemeModeEnum.light);
    }
  }

  final StreamController<ThemeModeEnum> _themeModeController = StreamController<ThemeModeEnum>.broadcast();

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      tokens: _currentTokens,
      theme: _currentTokens is LightTokens ? _lightTheme : _darkTheme,
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
  final ThemeData theme;
  final VoidCallback toggleTheme;
  final Function(ITokens) setTheme;
  final Stream<ThemeModeEnum> themeModeStream;

  const AppTheme({
    required this.tokens,
    required this.theme,
    required this.toggleTheme,
    required this.setTheme,
    required this.themeModeStream,
    required super.child,
    super.key,
  });

  @override
  bool updateShouldNotify(AppTheme oldWidget) {
    return oldWidget.tokens != tokens || oldWidget.theme != theme;
  }

  static AppTheme? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>();
  }
}

extension ThemeContextExtension on BuildContext {
  ITokens get currentTokens => AppTheme.of(this)!.tokens;

  ThemeData get theme => AppTheme.of(this)!.theme;

  bool get isDarkTheme => AppTheme.of(this)!.tokens is DarkTokens;

  void toggleTheme() => AppTheme.of(this)!.toggleTheme();

  void setTheme(ITokens tokens) => AppTheme.of(this)!.setTheme(tokens);

  void switchTheme(bool isDark) => AppTheme.of(this)!.setTheme(isDark ? DarkTokens() : LightTokens());

  Stream<ThemeModeEnum> get themeModeStream => AppTheme.of(this)!.themeModeStream;
}
