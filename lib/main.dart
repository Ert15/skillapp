import 'package:flutter/material.dart';
import 'demo_store.dart';
import 'screens/auth_screen.dart';
import 'screens/main_shell.dart';

void main() => runApp(const SkillSwapApp());

class SkillSwapApp extends StatefulWidget {
  const SkillSwapApp({super.key});

  @override
  State<SkillSwapApp> createState() => _SkillSwapAppState();
}

class _SkillSwapAppState extends State<SkillSwapApp> {
  bool _isAuthenticated = false;
  String _displayName = '';
  final _demoStore = DemoStore();

  void _signInLocally(String name) {
    setState(() {
      _displayName = name;
      _isAuthenticated = true;
    });
    _demoStore.setCurrentUserName(name);
  }

  void _updateName(String name) {
    setState(() => _displayName = name);
    _demoStore.setCurrentUserName(name);
  }

  void _signOutLocally() {
    setState(() {
      _displayName = '';
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'SkillSwap',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F6FF),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF5B55D6),
            brightness: Brightness.light,
          ),
          fontFamily: 'Arial',
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F6FF),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFD8D5EA)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFFD8D5EA)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF5B55D6), width: 2),
            ),
          ),
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(18)),
            ),
          ),
        ),
        home: _isAuthenticated
            ? MainShell(
                store: _demoStore,
                profileName: _displayName,
                onSignOut: _signOutLocally,
                onNameChanged: _updateName,
              )
            : AuthScreen(onAuthenticated: _signInLocally),
      );
}
