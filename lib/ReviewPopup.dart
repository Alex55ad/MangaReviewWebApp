import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewPopup extends StatefulWidget {
  final int mangaId;
  final int reviewId;
  final int userId;

  ReviewPopup({required this.mangaId, required this.reviewId, required this.userId});

  @override
  _ReviewPopupState createState() => _ReviewPopupState();
}

class _ReviewPopupState extends State<ReviewPopup> {
  late String _status;
  late double _score;
  late int _chapterProgress;
  late DateTime _reviewDate;
  String? _title = "";
  String? _notes;


  String? _mangaTitle;
  String? _mangaCover;

  @override
  void initState() {
    super.initState();
    if (widget.reviewId != -1) {
      _initializeReview();
    }
    else {
      _status = "READING"; // Default status
      _score = 0.0;
      _chapterProgress = 0;
      _reviewDate = DateTime.now();
      _title = "";
    }

  }

  Future<void> _initializeReview() async {
    try {
      // Fetch review data
      await _fetchReview();
    } catch (e) {
      print('Error during review initialization: $e');
    }
  }

  Future<void> _fetchReview() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/reviews/getById?id=${widget.reviewId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _mangaTitle = data['manga']['title'];
          _mangaCover = data['manga']['cover'];
          _status = data['status'];
          _score = data['score']?.toDouble() ?? 0.0;
          _chapterProgress = data['chapter'] ?? 0;
          _reviewDate = DateTime.parse(data['date']);
          _title = data['title'];
          _notes = data['body'];
          // _isPrivate = data['status'] == 'PRIVATE'; // Remove this line
        });
      } else {
        throw Exception('Failed to load review');
      }
    } catch (e) {
      print('Error fetching review: $e');
    }
  }

  String getFormattedDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/users/getById?id=${widget.userId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load user');
      }
    } catch (e) {
      print('Error fetching user: $e');
      throw e;
    }
  }

  Future<void> _saveReview() async {
    try {
      final user = await _fetchUser(); // Fetch the user details

      final url = widget.reviewId == -1
          ? 'http://localhost:8080/reviews/insert' // Create a new review
          : 'http://localhost:8080/reviews/update?id=${widget.reviewId}'; // Update existing review

      final method = widget.reviewId == -1 ? 'POST' : 'PUT';

      final response = await http.Request(method, Uri.parse(url))
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = json.encode({
          'title': _title,
          'status': _status,
          'user': user,
          'score': _score,
          'chapter': _chapterProgress,
          'date': getFormattedDate(_reviewDate),
          'body': _notes,
          'manga': {'id': widget.mangaId},
        });

      final streamedResponse = await response.send();
      final finalResponse = await http.Response.fromStream(streamedResponse);

      if (finalResponse.statusCode == 200 || finalResponse.statusCode == 201) {
        Navigator.of(context).pop(true); // Close popup and return true on success
      } else {
        throw Exception('Failed to save review');
      }
    } catch (e) {
      print('Error saving review: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_mangaCover != null)
              Image.network(
                _mangaCover!,
                height: 100,
              ),
            if (_mangaTitle != null)
              Text(
                _mangaTitle!,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16),
            TextFormField(
              initialValue: _title,
              decoration: InputDecoration(labelText: 'Title'),
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(labelText: 'Status'),
              items: [
                DropdownMenuItem(child: Text('Reading'), value: 'READING'),
                DropdownMenuItem(child: Text('Completed'), value: 'COMPLETED'),
              ],
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _score.toString(),
                    decoration: InputDecoration(labelText: 'Score'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        _score = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_upward),
                  onPressed: () {
                    setState(() {
                      if (_score < 10.0) _score += 0.5;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    setState(() {
                      if (_score > 0.0) _score -= 0.5;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: _chapterProgress.toString(),
              decoration: InputDecoration(labelText: 'Chapter Progress'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _chapterProgress = int.tryParse(value) ?? 0;
                });
              },
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: getFormattedDate(_reviewDate),
                    decoration: InputDecoration(labelText: 'Review Date'),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _reviewDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null && picked != _reviewDate) {
                        setState(() {
                          _reviewDate = picked;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: _notes,
              decoration: InputDecoration(labelText: 'Review'),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  _notes = value;
                });
              },
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _saveReview,
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                if (widget.reviewId != -1)
                  TextButton(
                    onPressed: () async {
                      // Implement delete functionality here
                    },
                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
