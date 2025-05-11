import 'package:flutter/material.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:splashify/splashify.dart';


class SplashScreen extends StatelessWidget {
  static const String RouteName = '/';

  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Splashify(
          imagePath: 'assets/images/logo.png',
          // Ensure this path is correct
          title: 'Faculty of Science ASU',
          slideNavigation: true,
          titleColor: Colors.green.shade900,
          // Deeper green for aesthetics
          titleBold: true,
          titleFadeIn: true,
          imageFadeIn: true,
          imageSize: 200,
          // Moderate size for better scaling
          heightBetween: 20,
          glowIntensity: 20,
          navigateDuration: 5,
          colorizeTitleAnimation: true,
          colorizeTileAnimationColors: [
            Colors.white,
            Colors.green.shade900,
          ],
          child: GlobalPassword()),
    );
  }
}
