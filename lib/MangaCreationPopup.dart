import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MangaPopup extends StatefulWidget {
  final int mangaId;

  MangaPopup({required this.mangaId});

  @override
  _MangaPopupState createState() => _MangaPopupState();
}

class _MangaPopupState extends State<MangaPopup> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _tagsController = TextEditingController();
  final _chaptersController = TextEditingController();
  final _releaseDateController = TextEditingController();
  DateTime _releaseDate = DateTime.now();
  String _status = 'ONGOING'; // Default value from _statusOptions
  String? _coverPath;

  final List<String> _statusOptions = ['ONGOING', 'FINISHED', 'HIATUS'];

  @override
  void initState() {
    super.initState();
    if (widget.mangaId != -1) {
      _fetchMangaData();
    } else {
      _updateReleaseDateController(_releaseDate);
    }
  }

  Future<void> _fetchMangaData() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/mangas/getById?id=${widget.mangaId}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _titleController.text = data['title'];
          _authorController.text = data['author'] ?? '';
          _tagsController.text = data['tags'] ?? '';
          _chaptersController.text = data['chapters']?.toString() ?? '';
          _releaseDate = DateTime.parse(data['release_date']);
          _updateReleaseDateController(_releaseDate);
          _status = data['status'] ?? 'ONGOING';
          _coverPath = data['cover'];
        });
      } else {
        throw Exception('Failed to load manga');
      }
    } catch (e) {
      print('Error fetching manga data: $e');
    }
  }

  void _updateReleaseDateController(DateTime date) {
    _releaseDateController.text = date.toLocal().toIso8601String().split('T').first;
  }

  Future<void> _saveManga() async {
    final url = widget.mangaId == -1
        ? 'http://localhost:8080/mangas/insert'
        : 'http://localhost:8080/mangas/update';
    final method = widget.mangaId == -1 ? 'POST' : 'PUT';

    try {
      final response = await http.Request(method, Uri.parse(url))
        ..headers.addAll({'Content-Type': 'application/json'})
        ..body = json.encode({
          'title': _titleController.text,
          'author': _authorController.text,
          'tags': _tagsController.text,
          'chapters': int.tryParse(_chaptersController.text) ?? 0,
          'release_date': _releaseDate.toLocal().toIso8601String().split('T').first,
          'status': _status,
          'cover': _coverPath != null && _coverPath!.isNotEmpty ? 'images/${_coverPath}' : '',
          'score': 0.0,
          'reviews': 0,
        });

      final streamedResponse = await response.send();
      final finalResponse = await http.Response.fromStream(streamedResponse);

      if (finalResponse.statusCode == 200 || finalResponse.statusCode == 201) {
        Navigator.of(context).pop(true); // Close popup and return true on success
      } else {
        throw Exception('Failed to save manga');
      }
    } catch (e) {
      print('Error saving manga: $e');
    }
  }

  Future<void> _deleteManga() async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:8080/mangas/delete?id=${widget.mangaId}'));

      if (response.statusCode == 204) {
        Navigator.of(context).pop(true); // Close popup and return true on success
      } else {
        throw Exception('Failed to delete manga');
      }
    } catch (e) {
      print('Error deleting manga: $e');
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
            if (_coverPath != null && _coverPath!.isNotEmpty)
              Image.asset(
                'images/$_coverPath',
                height: 100,
                fit: BoxFit.cover,
              ),
            SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _authorController,
              decoration: InputDecoration(labelText: 'Author'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(labelText: 'Tags (separated by spaces)'),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _chaptersController,
              decoration: InputDecoration(labelText: 'Chapters'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Release Date'),
                    readOnly: true,
                    controller: _releaseDateController,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _releaseDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != _releaseDate) {
                        setState(() {
                          _releaseDate = pickedDate;
                          _updateReleaseDateController(pickedDate);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _status,
              decoration: InputDecoration(labelText: 'Status'),
              items: _statusOptions.map((status) => DropdownMenuItem<String>(
                child: Text(status),
                value: status,
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _status = value!;
                });
              },
            ),
            SizedBox(height: 8),
            TextFormField(
              initialValue: _coverPath ?? '',
              onChanged: (value) {
                setState(() {
                  _coverPath = value.trim();
                });
              },
              decoration: InputDecoration(labelText: 'Cover Image File Name'),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: _saveManga,
                  child: Text('Save'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancel'),
                ),
                if (widget.mangaId != -1)
                  TextButton(
                    onPressed: () async {
                      bool? confirmed = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Confirm Deletion'),
                          content: Text('Are you sure you want to delete this manga?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        await _deleteManga();
                      }
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
