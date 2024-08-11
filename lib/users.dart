import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'HeaderMenu.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<dynamic> _users = [];
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _usr;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final userData = await _storage.read(key: 'user');
      if (userData != null) {
        setState(() {
          _usr = json.decode(userData);
        });
        if (_usr != null && _usr!['type'] == 'ADMIN') {
          await _fetchUsers();
        } else {
          setState(() {
            _loading = false;
          });
        }
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/users/getAll'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      setState(() {
        _error = error.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _handleBanUser(int userId) async {
    try {
      // Send the ban request
      await http.put(Uri.parse('http://localhost:8080/users/ban?id=$userId'));
      // Refresh the user list
      await _refreshUsers();
    } catch (error) {
      print('Error banning user: $error');
    }
  }

  Future<void> _handleUnbanUser(int userId) async {
    try {
      // Send the unban request
      await http.put(Uri.parse('http://localhost:8080/users/unban?id=$userId'));
      // Refresh the user list
      await _refreshUsers();
    } catch (error) {
      print('Error unbanning user: $error');
    }
  }

  Future<void> _refreshUsers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/users/getAll'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _users = data;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (error) {
      print('Error fetching users: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_loading) {
      content = Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      content = Center(child: Text('Error loading users: $_error'));
    } else if (_usr == null || _usr!['type'] != 'ADMIN') {
      content = Center(child: Text('Access denied. You do not have permission to view this page.'));
    } else {
      content = SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('User')),
            DataColumn(label: Text('User Type')),
            DataColumn(label: Text('User Score')),
            DataColumn(label: Text('Actions'))
          ],
          rows: _users.map<DataRow>((user) {
            final username = user['username'] ?? 'Unknown';
            final email = user['email'] ?? 'No email';
            final score = user['score']?.toString() ?? '0';
            final type = user['type'] ?? 'Unknown';

            Color typeColor;
            if (type == 'BANNED') {
              typeColor = Colors.red;
            } else if (type == 'ADMIN') {
              typeColor = Colors.deepPurple;
            } else {
              typeColor = Colors.green; // Default color
            }

            return DataRow(cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Contact: $email', style: TextStyle(color: Colors.purple)),
                  ],
                ),
              ),
              DataCell(
                Column(
                children: [
                  Text(type, style: TextStyle(color: typeColor)),
                ],
              )
              ),
              DataCell(
                Column(
                  children: [
                    Text(score, style: TextStyle(color: Colors.blueAccent)),
                  ],
                ),
              ),
              DataCell(
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () => _handleBanUser(user['id']),
                      child: Text('Ban', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleUnbanUser(user['id']),
                      child: Text('Unban', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
            ]);
          }).toList(),
        ),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          HeaderMenu(onThemeChanged: (bool isDarkMode) {
          }),
          Expanded(child: Container(padding: EdgeInsets.all(16.0), child: content)),
        ],
      ),
    );
  }
}
