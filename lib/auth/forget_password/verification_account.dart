import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/auth/forget_password/forget_password_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/Auth/auth_cubit.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_text_form_field.dart';

class VerificationAccount extends StatefulWidget {
  static const String RouteName = 'verification_acc';

  const VerificationAccount({super.key});

  @override
  State<VerificationAccount> createState() => _VerificationAccountState();
}

class _VerificationAccountState extends State<VerificationAccount> {
  final otpController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    otpController.dispose();
    super.dispose();
  }

  void _scrollToField() {
    if (formKey.currentState != null) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("Navigating to ForgetPasswordScreen");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
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
            resizeToAvoidBottomInset:
                false, // Prevent resizing when keyboard appears
            backgroundColor: AppColors.whiteColor,
            body: SafeArea(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom +
                      20.h, // Adjust for keyboard
                ),
                child: SizedBox(
                  height:
                      MediaQuery.of(context).size.height, // Define Stack height
                  child: Stack(
                    children: [
                      // Back Arrow
                      Positioned(
                        top: 45.h,
                        left: 8.w,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SendOtp()),
                            );
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryColor,
                            size: 30.sp,
                          ),
                        ),
                      ),
                      // OTP Title and Description
                      Positioned(
                        bottom: 0.75.sh,
                        left: 20.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "OTP code verification",
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'We sent an OTP code to your email. Enter that\n code to confirm your account',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Form
                      Positioned(
                        bottom: 0.50.sh,
                        left: 20.w,
                        right: 20.w,
                        child: Form(
                          key: formKey,
                          child: Column(
                            children: [
                              CustomTextFormField(
                                hint: 'Enter OTP',
                                controller: otpController,
                                keyboardType: TextInputType.number,
                              ),
                              SizedBox(height: 10.h),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryColor,
                                  padding: EdgeInsets.symmetric(
                                      vertical: 7.h, horizontal: 20.w),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.r),
                                  ),
                                  minimumSize: Size(double.infinity, 40.h),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    String? email = prefs.getString('email');

                                    if (email == null || email.isEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'لم يتم العثور على البريد الإلكتروني',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      );
                                      return;
                                    }

                                    BlocProvider.of<AuthCubit>(context)
                                        .Validateotp(
                                      otp: otpController.text,
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
                              SizedBox(height: 2.h),
                              InkWell(
                                onTap: () {
                                  BlocProvider.of<AuthCubit>(context).resendOtp();
                                  },
                                child: Text(
                                  "Resend OTP",
                                  style: TextStyle(
                                    color: AppColors.goldColor,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
