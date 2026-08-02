import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: FootStatApp(),
    ),
  );
}

class FootStatApp extends StatelessWidget {
  const FootStatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FootStat Pro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeScreen(),
    );
  }
}
