import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/auth/login/login_screen.dart';
import 'package:gradproject/core/app_colors.dart';
import 'package:gradproject/widgets/custom_text_form_field.dart';

import '../../controllers/Auth/auth_cubit.dart';
import '../../widgets/custom_arrow.dart';

class ForgetPasswordScreen extends StatefulWidget {
  static const String RouteName = 'forgetPassword_screen';

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final userNameController = TextEditingController();
  final emailController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmNewPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isSecure = true;

  void _togglePasswordVisibility() {
    setState(() {
      isSecure = !isSecure;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("Navigating to LoginScreen");
            userNameController.clear();
            emailController.clear();
            newPasswordController.clear();
            confirmNewPasswordController.clear();
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Success', style: TextStyle(fontSize: 18.sp)),
                content: Text('Password changed successfully', style: TextStyle(fontSize: 14.sp)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context, rootNavigator: true).pop();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message, style: TextStyle(fontSize: 14.sp))),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.whiteColor,
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 0.5.sh, // تكييف النسبة باستخدام screen height
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
                Positioned(
                  top: 25.h,
                  left: 15.w,
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()),
                          );
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryColor,
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        'Forget password',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'IMPRISHA',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // اللوجو واسم الجامعة
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
                // نموذج إعادة تعيين كلمة المرور
                Positioned(
                  bottom: 0.10.sh,
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
                          CustomTextFormField(
                            hint: 'user name',
                            label: "User Name",
                            controller: userNameController,
                          ),
                          CustomTextFormField(
                            hint: 'email',
                            label: "Email",
                            controller: emailController,
                          ),
                          CustomTextFormField(
                            hint: 'new password',
                            label: "New Password",
                            controller: newPasswordController,
                            isSecure: true,
                          ),
                          CustomTextFormField(
                            hint: 'confirm new password',
                            label: 'Confirm New Password',
                            controller: confirmNewPasswordController,
                            isSecure: true,
                          ),
                          SizedBox(height: 10.h),
                        ],
                      ),
                    ),
                  ),
                ),
                // زر إرسال
                Positioned(
                  bottom: 0.05.sh,
                  left: 0.4.sw, // تكييف العرض باستخدام screen width
                  child: InkWell(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        BlocProvider.of<AuthCubit>(context).ForgetPassword(
                          userName: userNameController.text.trim(),
                          email: emailController.text.trim(),
                          newPassword: newPasswordController.text.trim(),
                          confirmNewPassword: confirmNewPasswordController.text.trim(),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(50.r),
                    child: CustomArrow(),
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