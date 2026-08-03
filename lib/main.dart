import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'presentation/widgets/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyAiopYbig4ClDfFbp1Od2i_AQWwNl2USJ4",
      authDomain: "footstat-pro.firebaseapp.com",
      projectId: "footstat-pro",
      storageBucket: "footstat-pro.firebasestorage.app",
      messagingSenderId: "650593577397",
      appId: "1:650593577397:web:62603a7fd1627081aad1fc",
    ),
  );

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
      home: const AuthWrapper(),
    );
  }
}

