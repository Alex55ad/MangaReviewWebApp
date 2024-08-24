import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';  // Add this import
import 'package:mangareview_webapp/HeaderMenu.dart';
import 'ReviewPopup.dart'; // Import the ReviewPopup class

class Manga {
  final int id;
  final String title;
  final String cover;
  final String tags;
  final String status;

  Manga({required this.id, required this.title, required this.cover, required this.tags, required this.status});

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'],
      title: json['title'],
      cover: json['cover'],
      tags: json['tags'],
      status: json['status'],
    );
  }
}

class MangasPage extends StatefulWidget {
  @override
  _MangasPageState createState() => _MangasPageState();
}

class _MangasPageState extends State<MangasPage> {
  List<Manga> _mangas = [];
  List<String> _tags = [];
  bool _loading = true;
  String? _error;
  String? _selectedTag;
  String? _selectedStatus;
  String? _loggedInUsername;
  late int _userId;
  final FlutterSecureStorage _storage = FlutterSecureStorage();  // Create a storage instance

  @override
  void initState() {
    super.initState();
    _loadUser();  // Load the user when the widget initializes
    _loadMangas();
    _loadTags();
  }

  Future<void> _loadUser() async {
    final userData = await _storage.read(key: 'user');  // Read user data from secure storage
    if (userData != null) {
      final user = json.decode(userData);
      setState(() {
        _loggedInUsername = user['username'];  // Set the username in the state
        _userId = user['id'];
      });
    }
  }

  Future<void> _loadMangas() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/mangas/sortByScore'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _mangas = data.map((json) => Manga.fromJson(json)).toList();
          _loading = false;
        });
      } else {
        throw Exception('Failed to load mangas');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadTags() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/mangas/uniqueTags'));
      if (response.statusCode == 200) {
        List<String> tags = List<String>.from(json.decode(response.body));
        setState(() {
          _tags = ['Any', ...tags];
        });
      } else {
        throw Exception('Failed to load tags');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  Future<void> _openReviewPopup(int mangaId) async {
    if (_loggedInUsername == null) {
      // Handle case where the user is not logged in
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://localhost:8080/reviews/getByMangaIdAndUsername?mangaId=$mangaId&username=$_loggedInUsername',
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
            return ReviewPopup(mangaId: mangaId, reviewId: reviewId, userId: _userId);
          },
        );
      } else if (response.statusCode == 404) {
        // No review found for the specific manga and user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ReviewPopup(mangaId: mangaId, reviewId: -1, userId: _userId); // No review exists
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

  void _search(String query) async {
    try {
      if (query.isEmpty) {
        _loadMangas();
        return;
      } else {
        final response = await http.get(
            Uri.parse('http://localhost:8080/mangas/findByTitle?title=$query'));
        if (response.statusCode == 200) {
          setState(() {
            _mangas = [Manga.fromJson(json.decode(response.body))];
            _error = null;
          });
        } else {
          throw Exception('No manga found with that title');
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _filterTags(String? tag) async {
    if (tag == 'Any' || tag == null) {
      _loadMangas();
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/mangas/sortByTags?tags=$tag'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _mangas = data.map((json) => Manga.fromJson(json)).toList();
          _error = null;
        });
      } else {
        throw Exception('No mangas found for the selected tag');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  void _filterStatus(String? status) async {
    if (status == 'Any' || status == null) {
      _loadMangas();
      return;
    }

    try {
      final response = await http.get(Uri.parse('http://localhost:8080/mangas/findByStatus?status=$status'));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _mangas = data.map((json) => Manga.fromJson(json)).toList();
          _error = null;
        });
      } else {
        throw Exception('No mangas found with the selected status');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error loading mangas: $_error'));
    } else {
      content = GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 5.0,
          childAspectRatio: 0.7,
        ),
        itemCount: _mangas.length,
        itemBuilder: (context, index) {
          final manga = _mangas[index];
          return InkWell( // Use InkWell to detect taps on the cover
            onTap: () => _openReviewPopup(manga.id), // Open the review popup
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 220.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(manga.cover),
                          fit: BoxFit.contain,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 10,
                      child: CircleAvatar(
                        backgroundColor: Colors.black.withOpacity(0.7),
                        child: Text(
                          '#${index + 1}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  manga.title,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Column(
        children: [
          HeaderMenu(onThemeChanged: (bool isDarkMode) {
          }),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSubmitted: (value) {
                      _search(value);
                    },
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedTag,
                    decoration: InputDecoration(
                      hintText: 'Tags',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: _tags.map((tag) => DropdownMenuItem<String>(
                      child: Text(tag),
                      value: tag,
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTag = value;
                        _filterTags(value);
                      });
                    },
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      hintText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    items: ['Any', 'Ongoing', 'Completed']
                        .map((status) => DropdownMenuItem<String>(
                      child: Text(status),
                      value: status,
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                        _filterStatus(value);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}
