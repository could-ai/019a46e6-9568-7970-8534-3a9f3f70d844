import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/view_records_screen.dart';
import 'screens/statistics_screen.dart';
import 'screens/detail_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const ComunidadSantaRosaliaApp(),
    ),
  );
}

class ComunidadSantaRosaliaApp extends StatelessWidget {
  const ComunidadSantaRosaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Comunidad Santa Rosalía',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFFFFD700), // Amarillo Venezuela
          secondary: Color(0xFF0033A0), // Azul Venezuela
          surface: Color(0xFFD52B1E), // Rojo Venezuela
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onError: Colors.white,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          primary: Color(0xFFFFD700),
          secondary: Color(0xFF0033A0),
          surface: Color(0xFFD52B1E),
          error: Colors.red,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/view': (context) => const ViewRecordsScreen(),
        '/stats': (context) => const StatisticsScreen(),
      },
    );
  }
}