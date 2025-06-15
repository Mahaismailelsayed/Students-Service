import 'package:flutter/material.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splashify/splashify.dart';
import 'auth/register/register_screen.dart';
import 'core/token_utils.dart';

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
        navigateDuration: 3,
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigate();
    });
  }

  Future<void> _navigate() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('isFirstTime') ?? true;
    final token = prefs.getString('token');
    String route;

    if (isFirstTime) {
      await prefs.setBool('isFirstTime', false);
      route = GlobalPassword.RouteName;
    } else {
      // ✅ تحققي من صلاحية التوكن باستخدام TokenUtils
      final bool tokenValid = token != null && token.isNotEmpty && !TokenUtils.isTokenExpired(token);

      if (tokenValid) {
        print("✅ Token صالح");
        route = HomeScreen.RouteName;
      } else {
        print("⛔ Token منتهي أو مش موجود");

        await prefs.remove('token');
        await prefs.setBool('hasLoggedIn', false);
        route = RegisterScreen.RouteName;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, route);
      print('🔑 Token: $token');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
