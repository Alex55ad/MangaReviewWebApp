import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mangareview_webapp/ReviewPopup.dart';
import 'HeaderMenu.dart';

class ReviewsPage extends StatefulWidget {
  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic> _reviews = [];
  List<dynamic> _recommendations = []; // To store recommendations
  bool _loading = true;
  String? _error;
  String? _username;
  int? _id; // User ID

  @override
  void initState() {
    super.initState();
    _loadUserAndReviews();
  }

  Future<void> _loadUserAndReviews() async {
    await _loadUser();
    if (_username != null) {
      await Future.wait([
        _loadReviews(),
        _loadRecommendations(), // Load recommendations as well
      ]);
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
    }
  }

  Future<void> _loadRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/recommendations/getByUser?username=$_username'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recommendations = data;
        });
      } else {
        throw Exception('Failed to load recommendations');
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

  Future<void> _createRecommendation() async {
    if (_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID is not available")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/recommendations/create?userId=$_id'),
      );
      if (response.statusCode == 200) {
        _loadRecommendations(); // Refresh the list
      } else {
        throw Exception('Failed to create recommendation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create recommendation: $e')),
      );
    }
  }

  Future<void> _recommendRandomManga() async {
    if (_id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User ID is not available")),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/recommendations/recommendRandomManga?userId=$_id'),
      );
      if (response.statusCode == 200) {
        _loadRecommendations(); // Refresh the list
      } else {
        throw Exception('Failed to recommend random manga');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to recommend random manga: $e')),
      );
    }
  }

  Future<void> _deleteRecommendation(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/recommendations/delete?id=$id'),
      );
      if (response.statusCode == 204) {
        _loadRecommendations(); // Refresh the list
      } else {
        throw Exception('Failed to delete recommendation');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete recommendation: $e')),
      );
    }
  }

  Future<void> _openReviewPopup(int mangaId) async {
    if (_username == null || _id == null) {
      // Handle case where the user is not logged in or ID is not available
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in or ID not available")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/reviews/getByMangaIdAndUsername?mangaId=$mangaId&username=$_username',
        ),
      );

      if (response.statusCode == 200) {
        // Parse the review from the response body
        var review = json.decode(response.body);
        int reviewId = review['id'];

        // Show the review popup with the found review
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ReviewPopup(mangaId: mangaId, reviewId: reviewId, userId: _id!);
          },
        );
      } else if (response.statusCode == 404) {
        // No review found for the specific manga and user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ReviewPopup(mangaId: mangaId, reviewId: -1, userId: _id!); // No review exists
          },
        );
      } else {
        throw Exception('Failed to load review');
      }
    } catch (e) {
      print('Error: $e');
      // Handle error, e.g., show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open review popup: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error loading data: $_error'));
    } else if (_reviews.isEmpty && _recommendations.isEmpty) {
      content = Center(child: Text('No reviews or recommendations found.'));
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
                      GestureDetector(
                        onTap: () => _openReviewPopup(manga['id']),
                        child: Image.asset(manga['cover'], width: 50, height: 50),
                      ),
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
                      GestureDetector(
                        onTap: () => _openReviewPopup(manga['id']),
                        child: Image.asset(manga['cover'], width: 50, height: 50),
                      ),
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

            // Recommended Manga Table
            Text('Recommendations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _createRecommendation,
                  child: Text('Create Recommendation'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _recommendRandomManga,
                  child: Text('Recommend Random Manga'),
                ),
              ],
            ),
            SizedBox(height: 10),
            DataTable(
              columns: const [
                DataColumn(label: Text('Cover')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Reason')),
                DataColumn(label: Text('Actions')),
              ],
              rows: _recommendations.map<DataRow>((recommendation) {
                final manga = recommendation['manga'];
                return DataRow(
                  cells: [
                    DataCell(
                      GestureDetector(
                        onTap: () => _openReviewPopup(manga['id']),
                        child: Image.asset(manga['cover'], width: 50, height: 50),
                      ),
                    ),
                    DataCell(Text(manga['title'])),
                    DataCell(Text(recommendation['reason'] ?? '')),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteRecommendation(recommendation['id']),
                      ),
                    ),
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

