import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import 'package:mangareview_webapp/MangaCreationPopup.dart';

class HeaderMenu extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;

  HeaderMenu({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _HeaderMenuState createState() => _HeaderMenuState();
}

class _HeaderMenuState extends State<HeaderMenu> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _username;
  String? _userType;
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final userData = await _storage.read(key: 'user');
    if (userData != null) {
      final user = json.decode(userData);
      setState(() {
        _username = user['username'];
        _userType = user['type'];
      });
    }
  }

  Future<void> _logout() async {
    await _storage.delete(key: 'user');
    setState(() {
      _username = null;
      _userType = null;
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
      widget.onThemeChanged(_isDarkMode);
    });
  }

  void _openMangaPopup() async {
    bool? result = await showDialog(
      context: context,
      builder: (context) => MangaPopup(mangaId: -1), // Pass -1 for new manga
    );

    if (result == true) {
      // Handle successful result if needed
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = _userType == 'ADMIN';

    return Container(
      color: Color.fromARGB(200, 3, 54, 117),
      padding: EdgeInsets.all(10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'images/mangarevlogo.png',
            width: 150,
            height: 70,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/'),
                child: Text('Home', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/Manga'),
                child: Text('Manga List', style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/Reviews'),
                child: Text('My List', style: TextStyle(color: Colors.white)),
              ),
              if (isAdmin)
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/Users'),
                  child: Text('Users', style: TextStyle(color: Colors.white)),
                ),
              if (isAdmin)
                TextButton(
                  onPressed: _openMangaPopup,
                  child: Text('Add Manga', style: TextStyle(color: Colors.white)),
                ),
            ],
          ),
          Spacer(),
          if (_username != null)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Logged in as $_username ($_userType)', style: TextStyle(color: Colors.white)),
                ),
                TextButton(
                  onPressed: _logout,
                  child: Text('Logout', style: TextStyle(color: Colors.white)),
                ),
              ],
            )
          else ...[
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/Login'),
              child: Text('Log in', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/Signup'),
              child: Text('Sign up', style: TextStyle(color: Colors.white)),
            ),
          ],
          IconButton(
            icon: Icon(
              _isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Colors.white,
            ),
            onPressed: _toggleTheme,
          ),
        ],
      ),
    );
  }
}