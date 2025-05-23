import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/core/app_colors.dart';
import 'package:gradproject/widgets/custom_arrow.dart';
import 'package:gradproject/widgets/custom_text_form_field.dart';
import '../../Home/home_screen.dart';
import '../../controllers/Auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  static const String RouteName = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSecure = true;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is LoginSuccessState) {
            print("✅ Login Success");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          } else if (state is FailedState) {
            print("❌ Login Failed ${state.message}");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.h),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Stack(
                      children: [
                        // Bottom Colored Section
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 0.5.sh,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.r),
                                topRight: Radius.circular(25.r),
                              ),
                            ),
                          ),
                        ),
                        // Logo and University Name
                        Positioned(
                          top: 85.h,
                          left: 27.w,
                          child: Row(
                            children: [
                              Image.asset("assets/images/logo.png", height: 80.h),
                              Column(
                                children: [
                                  Text(
                                    "Faculty Of Science,\nAin Shams University",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'ENGR',
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Text(
                                    "كلية العلوم جامعة عين شمس",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: 'andlso',
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Login Form
                        Positioned(
                          bottom: 0.28.sh,
                          left: 20.w,
                          right: 20.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                            decoration: BoxDecoration(
                              color: AppColors.whiteColor,
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10.r,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Form(
                              key: formKey,
                              child: Column(
                                children: [
                                  Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  Container(
                                    height: 2.5.h,
                                    color: AppColors.primaryColor,
                                    width: 55.w,
                                  ),
                                  SizedBox(height: 15.h),
                                  CustomTextFormField(
                                    hint: 'username',
                                    label: 'User Name',
                                    controller: userNameController,
                                    keyboardType: TextInputType.text,
                                  ),
                                  CustomTextFormField(
                                    hint: 'password',
                                    label: 'Password',
                                    controller: passwordController,
                                    keyboardType: TextInputType.text,
                                    isSecure: true,
                                  ),
                                  SizedBox(height: 10.h),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Submit Button
                        Positioned(
                          bottom: 0.24.sh,
                          left: (MediaQuery.of(context).size.width - 50.w) / 2,
                          child: InkWell(
                            onTap: () {
                              if (formKey.currentState?.validate() ?? false) {
                                BlocProvider.of<AuthCubit>(context).Login(
                                  userName: userNameController.text.trim(),
                                  password: passwordController.text.trim(),
                                );
                              }
                            },
                            borderRadius: BorderRadius.circular(50.r),
                            child: CustomArrow(),
                          ),
                        ),
                        // Forget Password
                        Positioned(
                          bottom: 0.19.sh,
                          left: 0.04.sw,
                          child: Row(
                            children: [
                              Text(
                                'Forget Your Password?',
                                style: TextStyle(
                                  color: AppColors.whiteColor,
                                  fontSize: 15.sp,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => SendOtp()),
                                  );
                                },
                                child: Text(
                                  ' Click here',
                                  style: TextStyle(
                                    color: AppColors.goldColor,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}