import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'theme/app_theme.dart';
import 'services/smart_home_controller.dart';
import 'views/login_screen.dart';
import 'views/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartLifeApp());
}

class SmartLifeApp extends StatefulWidget {
  const SmartLifeApp({super.key});

  @override
  State<SmartLifeApp> createState() => _SmartLifeAppState();
}

class _SmartLifeAppState extends State<SmartLifeApp> {
  late final SmartHomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SmartHomeController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return MaterialApp(
          title: 'smartlive60',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: Locale(_controller.currentLanguage, ''),
          supportedLocales: const [
            Locale('ar', ''), // Arabic (RTL)
            Locale('en', ''), // English (LTR)
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Directionality(
            textDirection: _controller.textDirection,
            child: _controller.isLoggedIn
                ? DashboardScreen(controller: _controller)
                : LoginScreen(controller: _controller),
          ),
        );
      },
    );
  }
}
