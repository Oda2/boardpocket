import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/components/app_loading.dart';
import 'core/theme/theme.dart';
import 'core/i18n/i18n.dart';
import 'core/services/analytics_service.dart';
import 'core/di/dependency_injection.dart';
import 'presentation/providers/providers.dart';
import 'router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AnalyticsService().init();
  await DependencyInjection().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Single source of truth for the provider list, so a new provider cannot
    // be forgotten here.
    return MultiProvider(
      providers: getProviders(),
      child: const AppWithSettings(),
    );
  }
}

class AppWithSettings extends StatelessWidget {
  const AppWithSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    if (settingsProvider.isLoading) {
      return MaterialApp(
        title: 'BoardPocket',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: AppLoading())),
      );
    }

    return MaterialApp.router(
      title: 'BoardPocket',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: Locale(settingsProvider.language),
      supportedLocales: const [Locale('en'), Locale('pt'), Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
