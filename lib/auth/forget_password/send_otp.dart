import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/auth/forget_password/verification_account.dart';
import '../../controllers/Auth/auth_cubit.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_text_form_field.dart';
import '../login/login_screen.dart';

class SendOtp extends StatefulWidget {
  static const String RouteName = 'send_otp';

  @override
  State<SendOtp> createState() => _SendOtpState();
}

class _SendOtpState extends State<SendOtp> {
  final emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("Navigating to VerificationAccount");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => VerificationAccount()),
            );
          } else if (state is FailedState) {
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
            backgroundColor: AppColors.whiteColor,
            body: Stack(
              children: [
                Positioned(
                  top: 45.h,
                  left: 8.w,
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: Icon(
                      Icons.arrow_back,
                      color: AppColors.primaryColor,
                      size: 30.sp,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.87.sh,
                  left: 55.w,
                  child: Column(
                    children: [
                      Text(
                        "Find your account",
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 0.6.sh,
                  left: 20.w,
                  right: 20.w,
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        CustomTextFormField(
                          hint: 'Email',
                          label: 'Enter your email',
                          controller: emailController,
                        ),
                        SizedBox(height: 10.h),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            padding: EdgeInsets.symmetric(vertical: 7.h, horizontal: 20.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                            minimumSize: Size(double.infinity, 40.h),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              BlocProvider.of<AuthCubit>(context).Sendotp(
                                Email: emailController.text,
                              );
                            }
                          },
                          child: Text(
                            "Continue",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
