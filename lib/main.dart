import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:mangareview_webapp/Login.dart';
import 'package:mangareview_webapp/reviews.dart';
import 'package:mangareview_webapp/users.dart';
import 'package:mangareview_webapp/Signup.dart';
import 'package:mangareview_webapp/HeaderMenu.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaRev',
      theme: _isDarkMode
          ? ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      )
          : ThemeData.light().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: MyHomePage(
        title: 'MangaRev',
        onThemeChanged: (isDarkMode) {
          setState(() {
            _isDarkMode = isDarkMode;
          });
        },
      ),
      routes: {
        '/Login': (context) => LoginPage(),
        '/Signup': (context) => SignupPage(),
        '/Users': (context) => UsersPage(),
        '/Reviews': (context) => ReviewsPage(),
        // Add other routes here if needed
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final ValueChanged<bool> onThemeChanged;

  const MyHomePage({super.key, required this.title, required this.onThemeChanged});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderMenu(
            onThemeChanged: onThemeChanged,
          ),
          Expanded(
            child: Center(
              child: Text(
                'Welcome to MangaRev!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
