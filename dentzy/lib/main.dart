import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';
import 'services/language_provider.dart';
import 'services/family_provider.dart';
import 'services/settings_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final languageProvider = LanguageProvider();
  await languageProvider.initialize();
  
  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();
  
  runApp(MyApp(languageProvider: languageProvider, settingsProvider: settingsProvider));
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
  }

  @override
  void dispose() {
    _languageProvider.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: SplashScreen(languageProvider: _languageProvider),
      ),
    );
  }
}