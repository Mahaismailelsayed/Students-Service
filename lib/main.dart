import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/auth/forget_password/forget_password_screen.dart';
import 'package:gradproject/auth/global_password.dart';
import 'package:gradproject/auth/login/login_screen.dart';
import 'package:gradproject/auth/register/register_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/auth/forget_password/verification_account.dart';
import 'package:gradproject/controllers/gpa_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(),),
        BlocProvider(create: (context) => GpaCubit(),),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690), // حجم التصميم الأساسي (مثل Figma)
        minTextAdapt: true, // تكييف حجم النصوص تلقائيًا
        splitScreenMode: true,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: SplashScreen.RouteName,
          routes: {
            SplashScreen.RouteName: (context) => SplashScreen(),
            GlobalPassword.RouteName: (context) => GlobalPassword(),
            RegisterScreen.RouteName: (context) => RegisterScreen(),
            LoginScreen.RouteName: (context) => LoginScreen(),
            ForgetPasswordScreen.RouteName: (context) => ForgetPasswordScreen(),
            HomeScreen.RouteName: (context) => HomeScreen(),
            GpaScreen.RouteName: (context) => GpaScreen(),
            SendOtp.RouteName: (context) => SendOtp(),
            VerificationAccount.RouteName: (context) => VerificationAccount(),
          },
        ),
      ),
    );
  }
}
