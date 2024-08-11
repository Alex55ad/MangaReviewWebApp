import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FlutterSecureStorage _storage = FlutterSecureStorage(); // Initialize secure storage

  String? _error;

  Future<void> handleSignup() async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;
    final String email = _emailController.text;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/users/signin'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Store user data securely
        await _storage.write(key: 'user', value: json.encode(data));

        print('Signed up user: $data');
        Navigator.pushNamed(context, '/');
      } else {
        setState(() {
          _error = response.body;
        });
      }
    } catch (error) {
      print('Error signing up: $error');
      setState(() {
        _error = 'An error occurred while signing up';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Signup'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter your username',
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password (minimum 7 characters)',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              const Text(
                'Password must be at least 7 characters long and contain at least one special character (_!#\$%&\'*+/=?`~^.-)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
              ),
              SizedBox(height: 20),
              if (_error != null)
                Text(
                  _error!,
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleSignup,
                child: Text('Signup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
