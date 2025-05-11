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
                title: const Text('Success'),
                content: const Text('Password changed successfully'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.of(context, rootNavigator: true).pop(); // يغلق الديالوج
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            });
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
              backgroundColor: AppColors.whiteColor,
              body: Stack(children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 15,
                  left: 15,
                  child: Row(
                    children: [
                      InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
                          },
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.primaryColor,
                          )),
                      SizedBox(width: 20),
                      Text(
                        'Forget password',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontFamily: 'IMPRISHA',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                // اللوجو واسم الجامعة
                Positioned(
                  top: 60,
                  left: 27,
                  child: Row(
                    children: [
                      Image.asset("assets/images/logo.png", height: 80),
                      Column(
                        children: [
                          Text(
                            "Faculty Of Science,\nAin Shams University",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ENGR',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            "كلية العلوم جامعة عين شمس",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'andlso',
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // نموذج تسجيل الدخول
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.10,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
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
                              controller: userNameController),

                          CustomTextFormField(
                              hint: 'email',
                              label: "Email",
                              controller: emailController),

                          // إدخال كلمة المرور
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
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                ),
                // زر تسجيل الدخول
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.05,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: InkWell(
                    onTap: () {
                      if (formKey.currentState!.validate()) {
                        BlocProvider.of<AuthCubit>(context).ForgetPassword(
                          userName: userNameController.text.trim(),
                          email: emailController.text.trim(),
                          newPassword: newPasswordController.text.trim(),
                          confirmNewPassword:
                              confirmNewPasswordController.text.trim(),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: CustomArrow(),
                  ),
                ),
              ]));
        },
      ),
    );
  }
}
