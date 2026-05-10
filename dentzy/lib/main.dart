 import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'screens/startup_flow_screen.dart';
import 'utils/theme.dart';
import 'services/language_provider.dart';
import 'services/family_provider.dart';
import 'services/settings_provider.dart';
import 'services/auth_service.dart';
import 'services/session_manager.dart';
import 'services/app_tour_service.dart';
import 'l10n/app_localizations.dart';

void main() async {
  debugPrint('▶️  [main] App startup STARTING...');
  
  try {
    debugPrint('▶️  [main] Calling WidgetsFlutterBinding.ensureInitialized()...');
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('✅ [main] WidgetsFlutterBinding initialized');
    
    debugPrint('▶️  [main] Creating providers...');
    final languageProvider = LanguageProvider();
    final settingsProvider = SettingsProvider();
    debugPrint('✅ [main] Providers created');
    
    debugPrint('▶️  [main] Calling runApp()...');
    runApp(MyApp(
      languageProvider: languageProvider,
      settingsProvider: settingsProvider,
    ));
    debugPrint('✅ [main] runApp() called - UI should render now');
  } catch (e) {
    debugPrint('❌ [main] FATAL ERROR during startup: $e');
    rethrow;
  }
}
class MyApp extends StatefulWidget {
  final LanguageProvider languageProvider;
  final SettingsProvider settingsProvider;

  const MyApp({
    super.key,
    required this.languageProvider,
    required this.settingsProvider,
  });
  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  late LanguageProvider _languageProvider;
  late SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _languageProvider = widget.languageProvider;
    _settingsProvider = widget.settingsProvider;
    
    _languageProvider.addListener(_onLanguageChanged);

    // Defer provider initialization until after the first frame so app startup
    // does not block rendering on SharedPreferences or notification setup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapAsync());
    });
  }
  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }
  void _onLanguageChanged() {
    setState(() {});
  }

  Future<void> _bootstrapAsync() async {
    debugPrint('🔄 [_bootstrapAsync] Background initialization starting...');
    
    try {
      // Initialize language provider with timeout
      debugPrint('🔄 [_bootstrapAsync] Initializing LanguageProvider...');
      try {
        await _languageProvider.initialize()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ [_bootstrapAsync] LanguageProvider initialized');
      } catch (e) {
        debugPrint('⚠️  [_bootstrapAsync] LanguageProvider init timeout/error: $e');
        // Continue with default language
      }

      // Initialize app tour service with timeout
      debugPrint('🔄 [_bootstrapAsync] Initializing AppTourService...');
      try {
        await AppTourService.initialize()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ [_bootstrapAsync] AppTourService initialized');
      } catch (e) {
        debugPrint('⚠️  [_bootstrapAsync] AppTourService init timeout/error: $e');
        // Continue without tour if it fails
      }

      // Initialize auth service for login/signup/session flow
      debugPrint('🔄 [_bootstrapAsync] Initializing AuthService...');
      try {
        await AuthService.initialize()
            .timeout(const Duration(seconds: 5));
        debugPrint('✅ [_bootstrapAsync] AuthService initialized');
      } catch (e) {
        debugPrint('⚠️  [_bootstrapAsync] AuthService init timeout/error: $e');
      }

      // Initialize settings SEPARATELY to prevent notification issues from blocking everything
      debugPrint('🔄 [_bootstrapAsync] Initializing SettingsProvider...');
      try {
        // Use a longer timeout for settings since it includes notification init
        await _settingsProvider.initialize()
            .timeout(const Duration(seconds: 10));
        debugPrint('✅ [_bootstrapAsync] SettingsProvider initialized');
      } on TimeoutException catch (e) {
        debugPrint('⚠️  [_bootstrapAsync] SettingsProvider init TIMEOUT - continuing anyway');
        debugPrint('⚠️  [_bootstrapAsync] Timeout details: $e');
        // Don't rethrow - let app continue without notifications
      } catch (e) {
        debugPrint('⚠️  [_bootstrapAsync] SettingsProvider init error: $e');
        // Don't rethrow - let app continue without notifications
      }

      if (mounted) {
        debugPrint('🔄 [_bootstrapAsync] Triggering UI rebuild...');
        setState(() {});
        debugPrint('✅ [_bootstrapAsync] Background initialization COMPLETE');
      }
    } catch (e) {
      debugPrint('❌ [_bootstrapAsync] Unexpected error: $e');
      // Still continue - don't crash the app
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🏗️  [MyApp.build] Building MyApp - startup flow active');
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: AuthSessionService.instance),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider.value(value: _settingsProvider),
      ],
      child: MaterialApp(
        title: 'Dentzy',
        theme: AppTheme.lightTheme,
        locale: _languageProvider.currentLocale,
        supportedLocales: const [
          Locale('en'),
          Locale('ta'),
        ],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,          GlobalCupertinoLocalizations.delegate,
        ],
        home: StartupFlowScreen(languageProvider: _languageProvider),
      ),
    );
  }
}
