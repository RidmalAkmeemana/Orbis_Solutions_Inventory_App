import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:inventory_app/API/api_service.dart';
import 'HomeScreen.dart';
import 'package:loading_indicator/loading_indicator.dart';

class LogScreen extends StatefulWidget {
  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleLogin() async {
    final String username = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      _showSnack('Username & Password is Required');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.login(username, password);

      // Example server responses you showed:
      // {"success":"false","error":"empty"}
      // {"success":"false","error":"invalid"}
      // {"success":"true","token":"...","status":"Super Admin"}

      final successString = (result['success'] ?? '').toString().toLowerCase();

      if (successString == 'false') {
        final error = (result['error'] ?? '').toString().toLowerCase();
        if (error == 'empty') {
          // According to API: empty username or password
          _showSnack('Username & Password is Required');
        } else if (error == 'invalid') {
          _showSnack('Invalid Username or Password');
        } else {
          _showSnack('Login Failed Please Try Again');
          print("Login Failed: ${result['error'] ?? 'Unknown error'}");
        }
      } else if (successString == 'true') {
        final token = result['token']?.toString() ?? '';
        final status = result['status']?.toString() ?? '';
        final id = result['id']?.toString() ?? '';

        if (token.isEmpty) {
          _showSnack('Insecure Login Detected');
        } else {
          // Save token & status to SharedPreferences to persist login
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          await prefs.setString('status', status);
          await prefs.setString('username', username);

          // Navigate to HomeScreen (replace current)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } else {
        _showSnack('Unexpected Server Response');
      }
    } catch (e) {
      _showSnack('Please Check Your Network Connection & Try Again');
      print("$e");
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0), // Padding for the content
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.asset(
              'assets/images/logo-small.png', // Path to your logo
              width: 150, // Adjust width as needed
              height: 150, // Adjust height as needed
            ),
            Text(
              'Inventory Management System',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30.0), // Spacing between elements
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Username',
                floatingLabelStyle: TextStyle(color: Color(0xFFbe3235)),
                prefixIcon: Icon(Icons.person),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFbe3235), width: 1),
                ),
              ),
            ),
            SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                floatingLabelStyle: TextStyle(color: Color(0xFFbe3235)),
                prefixIcon: Icon(Icons.lock),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFD9D9D9), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFbe3235), width: 1),
                ),
              ),
            ),

            SizedBox(height: 30.0),
            ElevatedButton(
              onPressed: _loading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFbe3235), // Button color
                padding: EdgeInsets.symmetric(vertical: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _loading
                  ? SizedBox(
                height: 30,
                width: 30,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballClipRotateMultiple,
                  colors: [Color(0xFFbe3235)],
                  strokeWidth: 2,
                  backgroundColor: Colors.transparent,
                  pathBackgroundColor: Colors.transparent,
                ),
              )
                  : Text(
                'Log In',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
