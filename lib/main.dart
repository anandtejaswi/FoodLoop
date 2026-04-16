// ============================================================
// main.dart  –  App Entry Point Only
// Widgets used: MaterialApp (via GoRouter), ChangeNotifierProvider
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_routes.dart';
import 'config/app_theme.dart';
import 'services/auth_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized before any plugin call
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodLoopApp());
}

class FoodLoopApp extends StatelessWidget {
  const FoodLoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider: makes AuthService available throughout the widget tree
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
      child: Builder(
        builder: (context) {
          // MaterialApp.router uses GoRouter for declarative navigation
          return MaterialApp.router(
            title: 'FoodLoop',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.appTheme,       // Unified minimalist theme
            darkTheme: AppTheme.appTheme,    // Reusing the same minimalist theme for now
            themeMode: ThemeMode.light,
            routerConfig: AppRoutes.router,    // All routes defined in app_routes.dart
          );
        },
      ),
    );
  }
}
