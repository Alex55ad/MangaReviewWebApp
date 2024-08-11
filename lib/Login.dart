import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Initialize secure storage

  String? _error;

  Future<void> handleLogin() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/users/login?username=$username&password=$password'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Store user data securely
        await _storage.write(key: 'user', value: json.encode(data));

        print('Logged in user: $data');
        Navigator.pushNamed(context, '/');
      } else {
        setState(() {
          _error = response.body;
        });
      }
    } catch (error) {
      print('Error logging in: $error');
      setState(() {
        _error = 'An error occurred while logging in';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleLogin,
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}