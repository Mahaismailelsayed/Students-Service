import 'package:flutter/material.dart';
import 'package:gradproject/Home/drawer/courses_screen.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/auth/change_passsword.dart';
import 'package:gradproject/auth/forget_password/forget_password_screen.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:gradproject/auth/login/login_screen.dart';
import 'package:gradproject/auth/register/register_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/auth/forget_password/verification_account.dart';
import 'package:gradproject/splash_screen.dart';


import 'Home/drawer/gpa_screen.dart';

void main() async {


  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute:HomeScreen.RouteName,
      routes: {
        SplashScreen.RouteName:(context)=>SplashScreen(),
        GlobalPassword.RouteName : (context)=>GlobalPassword(),
        RegisterScreen.RouteName : (context)=>RegisterScreen(),
        LoginScreen.RouteName : (context)=>LoginScreen(),
        SendOtp.RouteName:(context)=>SendOtp(),
        VerificationAccount.RouteName:(context)=>VerificationAccount(),
        ForgetPasswordScreen.RouteName:(context)=>ForgetPasswordScreen(),
        HomeScreen.RouteName:(context)=>HomeScreen(),
        GpaScreen.RouteName : (context)=>GpaScreen(),
        ChangePasssword.RouteName:(context)=>SplashScreen(),
        CoursesScreen.RouteName:(context)=>CoursesScreen(),

      },// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
