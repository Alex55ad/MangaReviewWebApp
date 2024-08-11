import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'HeaderMenu.dart';

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic> _reviews = [];
  bool _loading = true;
  String? _error;
  String? _username;
  int? _id;

  @override
  void initState() {
    super.initState();
    _loadUserAndReviews();
  }

  Future<void> _loadUserAndReviews() async {
    await _loadUser();
    if (_username != null) {
      await _loadReviews();
    } else {
      setState(() {
        _loading = false;
        _error = "User not found.";
      });
    }
  }

  Future<void> _loadUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      final user = json.decode(userData);
      setState(() {
        _username = user['username'];
        _id = user['id'];
      });
    }
  }

  Future<void> _loadReviews() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/reviews/getByUsername?username=$_username'),
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
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error loading reviews: $_error'));
    } else if (_reviews.isEmpty) {
      content = Center(child: Text('No reviews found.'));
    } else {
      // Separate reviews by status
      final readingReviews = _reviews.where((review) => review['status'] == 'READING').toList();
      final completedReviews = _reviews.where((review) => review['status'] == 'COMPLETED').toList();

      content = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Reading Reviews Table
            Text('Reading', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DataTable(
              columns: const [
                DataColumn(label: Text('Cover')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Chapter')),
                DataColumn(label: Text('Review Title')),
                DataColumn(label: Text('Comments')),
              ],
              rows: readingReviews.map<DataRow>((review) {
                final manga = review['manga'];
                return DataRow(
                  cells: [
                    DataCell(
                      Image.asset(manga['cover'], width: 50, height: 50),
                    ),
                    DataCell(Text(manga['title'])),
                    DataCell(Text(review['score'].toString())),
                    DataCell(Text(review['chapter'].toString())),
                    DataCell(Text(review['title'])),
                    DataCell(Text(review['body'])),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Completed Reviews Table
            Text('Completed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            DataTable(
              columns: const [
                DataColumn(label: Text('Cover')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Score')),
                DataColumn(label: Text('Chapter')),
                DataColumn(label: Text('Review Title')),
                DataColumn(label: Text('Comments')),
              ],
              rows: completedReviews.map<DataRow>((review) {
                final manga = review['manga'];
                return DataRow(
                  cells: [
                    DataCell(
                      Image.asset(manga['cover'], width: 50, height: 50),
                    ),
                    DataCell(Text(manga['title'])),
                    DataCell(Text(review['score'].toString())),
                    DataCell(Text(review['chapter'].toString())),
                    DataCell(Text(review['title'])),
                    DataCell(Text(review['body'])),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          HeaderMenu(onThemeChanged: (bool isDarkMode) {}),
          Expanded(child: Container(padding: EdgeInsets.all(16.0), child: content)),
        ],
      ),
    );
  }
}
