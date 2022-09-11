import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:tesis/home.dart';
import 'package:tesis/provider/google_sign_in.dart';
import 'package:tesis/start.dart';
import 'package:tesis/theme/color_schemes.g.dart';
import 'package:tesis/theme/theme_provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    ChangeNotifierProvider<ThemeProvider>(
      child: const MyApp(),
      create: (_) => ThemeProvider()..initialize(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: Consumer<ThemeProvider>(builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Tesis',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
          ),
          themeMode: provider.themeMode,
          initialRoute: '/',
          routes: {
            '/': (context) => const Start(),
            '/second': (context) => const Home(),
          },
        );
      }),
    );
  }
}