import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:gradproject/controllers/Auth/auth_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashify/splashify.dart';

import 'auth/register/register_screen.dart';

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
        imageSize: 200,
        heightBetween: 20,
        glowIntensity: 20,
        navigateDuration: 5,
        colorizeTitleAnimation: true,
        colorizeTileAnimationColors: [
          Colors.white,
          Colors.green.shade900,
        ],
        child: const IntermediateScreen(),
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
  @override
  void initState() {
    super.initState();
    // استدعاء _navigate بعد بناء الـ widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate(context);
    });
  }

  Future<void> _navigate(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLoggedIn = prefs.getBool('hasLoggedIn') ?? false;

      String route = hasLoggedIn ? HomeScreen.RouteName : GlobalPassword.RouteName;

      if (mounted) {
        Navigator.pushReplacementNamed(context, route);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, SendOtp.RouteName);
      }
    }
  }  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
