import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'providers/theme_provider.dart';
import 'providers/cv_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const CVGeneratorApp());
}

class CVGeneratorApp extends StatelessWidget {
  const CVGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CVProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CV Generator',
            debugShowCheckedModeBanner: false,
            
            // Theme configuration
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            
            // Localization
            locale: themeProvider.locale,
            supportedLocales: const [
              Locale('en', ''), // English
              Locale('ar', ''), // Arabic
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            
            // RTL support
            builder: (context, child) {
              return Directionality(
                textDirection: themeProvider.locale.languageCode == 'ar' 
                    ? TextDirection.rtl 
                    : TextDirection.ltr,
                child: child!,
              );
            },
            
            // Initial screen
            home: const SplashScreen(),
            
            // Route configuration
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/splash':
                  return MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  );
                default:
                  return MaterialPageRoute(
                    builder: (context) => const SplashScreen(),
                  );
              }
            },
          );
        },
      ),
    );
  }
}
