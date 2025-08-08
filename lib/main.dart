import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pz_erp_software/theme/color_theme.dart';

import 'auth/auth_wrapper.dart';
import 'auth/login_screen.dart';
import 'firebase_options.dart';
import 'home_screen.dart';

void main()async{
 WidgetsFlutterBinding.ensureInitialized();
 await Firebase.initializeApp(
 options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.themeData,
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
