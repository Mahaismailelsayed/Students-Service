import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/auth/forget_password/forget_password_screen.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:gradproject/auth/login/login_screen.dart';
import 'package:gradproject/auth/register/register_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/auth/forget_password/verification_account.dart';
import 'package:gradproject/splash_screen.dart';
import 'package:gradproject/Home/drawer/gpa_screen.dart';

import 'controllers/Auth/auth_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
        routes: {
          SplashScreen.RouteName: (context) => const SplashScreen(),
          GlobalPassword.RouteName: (context) =>  GlobalPassword(),
          RegisterScreen.RouteName: (context) =>  RegisterScreen(),
          LoginScreen.RouteName: (context) =>  LoginScreen(),
          ForgetPasswordScreen.RouteName: (context) => ForgetPasswordScreen(),
          HomeScreen.RouteName: (context) => const HomeScreen(),
          GpaScreen.RouteName: (context) =>  GpaScreen(),
          SendOtp.RouteName: (context) => SendOtp(),
          VerificationAccount.RouteName: (context) =>  VerificationAccount(),
        },
      ),
    );
  }
}