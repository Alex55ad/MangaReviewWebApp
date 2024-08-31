import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:mangareview_webapp/Login.dart';
import 'package:mangareview_webapp/ReviewCard.dart';
import 'package:mangareview_webapp/mangas.dart';
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
  List<dynamic> _reviews = [];
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadReviews(); // Load reviews when the widget is first created
    _startPeriodicReviewFetch(); // Start periodic fetching of reviews
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/reviews/getAllSortedByDate'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _reviews = data;
        });
      } else {
        throw Exception('Failed to load reviews');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _startPeriodicReviewFetch() {
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      await _loadReviews(); // Fetch new reviews periodically
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

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
        reviews: _reviews,
        error: _error,
        isDarkMode: _isDarkMode, // Pass the _isDarkMode value here
      ),
      routes: {
        '/Login': (context) => LoginPage(),
        '/Signup': (context) => SignupPage(),
        '/Users': (context) => UsersPage(),
        '/Reviews': (context) => ReviewsPage(),
        '/Manga': (context) => MangasPage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  final ValueChanged<bool> onThemeChanged;
  final List<dynamic> reviews;
  final String? error;
  final bool isDarkMode; // Add this parameter

  const MyHomePage({
    super.key,
    required this.title,
    required this.onThemeChanged,
    required this.reviews,
    this.error,
    required this.isDarkMode, // Initialize new parameter
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          HeaderMenu(
            onThemeChanged: onThemeChanged,
          ),
          Expanded(
            child: error != null
                ? Center(child: Text(error!))
                : ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return ReviewCard(
                  username: review['user']['username'],
                  mangaTitle: review['manga']['title'],
                  chapter: review['chapter'],
                  reviewTitle: review['title'],
                  reviewBody: review['body'] ?? ' ',
                  coverUrl: review['manga']['cover'],
                  date: review['date'],
                  isDarkMode: isDarkMode, // Pass the isDarkMode value here
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
