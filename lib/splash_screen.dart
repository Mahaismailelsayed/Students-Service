import 'package:flutter/material.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashify/splashify.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SplashScreen extends StatelessWidget {
  static const String RouteName = 'splashScreen';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Splashify(
        imagePath: 'assets/images/logo.png',
        title: 'Faculty of Science ASU',
        slideNavigation: true,
        titleColor: Colors.green.shade900,
        titleBold: true,
        titleFadeIn: true,
        imageFadeIn: true,
        imageSize: 200, // Fixed size
        heightBetween: 20, // Fixed size
        glowIntensity: 20,
        navigateDuration: 5,
        colorizeTitleAnimation: true,
        colorizeTileAnimationColors: [
          Colors.white,
          Colors.green.shade900,
        ],
        child: const IntermediateScreen(), // Required child
      ),
    );
  }
}

class IntermediateScreen extends StatefulWidget {
  const IntermediateScreen({super.key});

  @override
  _IntermediateScreenState createState() => _IntermediateScreenState();
}

class _IntermediateScreenState extends State<IntermediateScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;

    String route;
    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      route = GlobalPassword.RouteName;
    } else if (token != null && token.isNotEmpty) {
      // Optionally validate token
      final isValid = await _validateToken(token);
      route = isValid ? HomeScreen.RouteName : GlobalPassword.RouteName;
    } else {
      route = GlobalPassword.RouteName; // Or LoginScreen.RouteName
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  Future<bool> _validateToken(String token) async {
    try {
      final response = await http.get(
        Uri.parse('http://gpa.runasp.net/api/Account/ValidateToken'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isValid'] ?? false; // Adjust based on your API
      }
      return false;
    } catch (e) {
      print('Token validation error: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Minimal UI since this screen is only used for navigation
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()), // Brief loading
    );
  }
}
