import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'register.dart';
import 'dart:developer' as developer;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    developer.log("Login button clicked", name: "LoginScreen");

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    String enteredEmail = _emailController.text.trim();
    String enteredPassword = _passwordController.text.trim();

    try {
      DataSnapshot snapshot = await _databaseRef.child("patients").get();
      bool isValidUser = false;
      String? userKey;

      if (snapshot.exists) {
        Map<dynamic, dynamic> patients = snapshot.value as Map;
        for (var entry in patients.entries) {
          Map<dynamic, dynamic> userData = entry.value as Map;
          if (userData["email"] == enteredEmail && userData["password"] == enteredPassword) {
            isValidUser = true;
            userKey = entry.key;
            break;
          }
        }
      }

      if (!isValidUser) {
        throw Exception("Invalid email or password.");
      }

      // Update the database with the logged-in status
      await _databaseRef.child("patients/$userKey").update({"isLoggedIn": true});

      // Save session locally
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("loggedInUser", enteredEmail);

      developer.log("Login successful: $enteredEmail", name: "LoginScreen");

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      developer.log("Login error: $e", name: "LoginScreen");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Invalid email or password.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Image.asset("assets/logo.png", height: 80),
                  const Text("CureReach", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: "Email",
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: "Password",
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text("Login"),
                        ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                    },
                    child: const Text("Not registered yet? Register now"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
