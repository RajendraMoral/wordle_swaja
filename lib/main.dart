import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasSavedGame = prefs.getBool('hasGame') ?? false;
  runApp(MyApp(hasSavedGame: hasSavedGame));
}

class MyApp extends StatelessWidget {
  final bool hasSavedGame;
  const MyApp({required this.hasSavedGame});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wordle Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
