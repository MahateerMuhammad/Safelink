import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';

// import 'helpers/ad_helper.dart'; // COMMENTED OUT (No ads for now)
import 'helpers/config.dart';
import 'helpers/pref.dart';
import 'screens/splash_screen.dart';

//global object for accessing device screen size
late Size mq;

// SafeLink Modern Color Palette
class SafeLinkColors {
  static const Color primaryTeal = Color(0xFF00796B);      // Deep Teal
  static const Color secondaryBlue = Color(0xFF42A5F5);    // Sky Blue
  static const Color backgroundLight = Color(0xFFF9FAFB);  // Soft Off-White
  static const Color accentGreen = Color(0xFF43A047);      // Emerald Green
  static const Color errorRed = Color(0xFFE57373);         // Coral Red
  static const Color cardWhite = Color(0xFFFFFFFF);        // Pure White
  static const Color textDark = Color(0xFF212121);         // Dark Charcoal
  static const Color textSecondary = Color(0xFF757575);    // Cool Grey
  
  // Additional complementary colors
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color primaryDark = Color(0xFF004D47);
  static const Color accentLight = Color(0xFF81C784);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //enter full-screen
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  //firebase initialization
  await Firebase.initializeApp();

  //initializing remote config
  await Config.initConfig();

  await Pref.initializeHive();

  // await AdHelper.initAds(); // COMMENTED OUT (No ads for now)

  //for setting orientation to portrait only
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((v) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SafeLink',
      home: SplashScreen(),

      //modern light theme
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF00796B, {
          50: Color(0xFFE0F2F1),
          100: Color(0xFFB2DFDB),
          200: Color(0xFF80CBC4),
          300: Color(0xFF4DB6AC),
          400: Color(0xFF26A69A),
          500: SafeLinkColors.primaryTeal,
          600: Color(0xFF00695C),
          700: Color(0xFF004D47),
          800: Color(0xFF00363A),
          900: Color(0xFF001F23),
        }),
        primaryColor: SafeLinkColors.primaryTeal,
        scaffoldBackgroundColor: SafeLinkColors.backgroundLight,
        cardColor: SafeLinkColors.cardWhite,
        
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: SafeLinkColors.cardWhite,
          foregroundColor: SafeLinkColors.textDark,
          titleTextStyle: TextStyle(
            color: SafeLinkColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: SafeLinkColors.primaryTeal),
          surfaceTintColor: Colors.transparent,
        ),
        
        cardTheme: CardThemeData(
          color: SafeLinkColors.cardWhite,
          elevation: 8,
          shadowColor: SafeLinkColors.primaryTeal.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SafeLinkColors.primaryTeal,
            foregroundColor: Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: SafeLinkColors.secondaryBlue,
          foregroundColor: Colors.white,
          elevation: 6,
        ),
        
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: SafeLinkColors.textDark, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: SafeLinkColors.textDark, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: SafeLinkColors.textDark),
          bodyMedium: TextStyle(color: SafeLinkColors.textSecondary),
          labelLarge: TextStyle(color: SafeLinkColors.cardWhite, fontWeight: FontWeight.w600),
        ),
        
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SafeLinkColors.primaryTeal,
          primary: SafeLinkColors.primaryTeal,
          secondary: SafeLinkColors.secondaryBlue,
          surface: SafeLinkColors.cardWhite,
          background: SafeLinkColors.backgroundLight,
          error: SafeLinkColors.errorRed,
        ),
      ),

      themeMode: Pref.isDarkMode ? ThemeMode.dark : ThemeMode.light,

      //modern dark theme
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: SafeLinkColors.primaryTeal,
        scaffoldBackgroundColor: Color(0xFF121212),
        cardColor: Color(0xFF1E1E1E),
        
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: SafeLinkColors.accentLight),
          surfaceTintColor: Colors.transparent,
        ),
        
        cardTheme: CardThemeData(
          color: Color(0xFF1E1E1E),
          elevation: 8,
          shadowColor: SafeLinkColors.primaryTeal.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        
        textTheme: TextTheme(
          headlineLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          labelLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: SafeLinkColors.primaryTeal,
          brightness: Brightness.dark,
          primary: SafeLinkColors.accentLight,
          secondary: SafeLinkColors.secondaryBlue,
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
          error: SafeLinkColors.errorRed,
        ),
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}

extension AppTheme on ThemeData {
  Color get lightText => Pref.isDarkMode ? Colors.white70 : SafeLinkColors.textSecondary;
  Color get bottomNav => Pref.isDarkMode ? SafeLinkColors.primaryTeal : SafeLinkColors.secondaryBlue;
  Color get primaryAccent => SafeLinkColors.primaryTeal;
  Color get successColor => SafeLinkColors.accentGreen;
  Color get errorColor => SafeLinkColors.errorRed;
  Color get cardBackground => Pref.isDarkMode ? Color(0xFF1E1E1E) : SafeLinkColors.cardWhite;
}
