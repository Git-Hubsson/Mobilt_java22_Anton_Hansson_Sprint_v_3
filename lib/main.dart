import 'package:chatlator/pages/home.dart';
import 'package:chatlator/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool rememberMe = prefs.getBool('rememberMe') ?? false;

    runApp(MyApp(rememberMe: rememberMe));
}

class MyApp extends StatelessWidget {
  const MyApp({required this.rememberMe, Key? key}) : super(key: key);

  final bool rememberMe;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: rememberMe ? '/home' : '/',
      routes: {
        '/home': (context) => const Home(),
      },
      debugShowCheckedModeBanner: false,
      title: 'ChatLator',
      theme: ThemeData(
        primaryColor: Color.fromRGBO(83, 129, 124, 1.0),
        appBarTheme: const AppBarTheme(
          color: Color.fromRGBO(19, 30, 29, 1.0),
        ),
        scaffoldBackgroundColor: Color.fromRGBO(84, 136, 122, 1.0),
        useMaterial3: true,
      ),
      home: LoginPage(),
    );
  }
}
