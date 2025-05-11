import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:gradproject/core/app_colors.dart';
import 'package:gradproject/widgets/custom_arrow.dart';
import 'package:gradproject/widgets/custom_text_form_field.dart';
import '../../Home/home_screen.dart';
import '../../controllers/Auth/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  static const String RouteName = 'login_screen';

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
              SnackBar(content: Text(state.message)),
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
                  bottom: MediaQuery.of(context).size.height * 0.28,
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
                          Text(
                            "Login",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Container(
                            height: 2.5,
                            color: AppColors.primaryColor,
                            width: 55,
                          ),
                          SizedBox(height: 15),

                          // إدخال اسم المستخدم
                          CustomTextFormField(
                            hint: 'username',
                            label: 'User Name',
                            controller: userNameController,
                          ),
                          // إدخال كلمة المرور
                          CustomTextFormField(
                              hint: 'password',
                              label: 'Password',
                              controller: passwordController,
                            isSecure: true,
                          ),
                          SizedBox(
                            height: 10,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // زر تسجيل الدخول
                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.23,
                  left: MediaQuery.of(context).size.width * 0.4,
                  child: InkWell(
                    onTap: () {
                      if (formKey.currentState?.validate() ?? false) {
                        BlocProvider.of<AuthCubit>(context).Login(
                          userName: userNameController.text.trim(),
                          password: passwordController.text.trim(),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: CustomArrow(),
                  ),
                ),
                Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.19,
                    left: MediaQuery.of(context).size.width * 0.04,
                    child: Row(
                      children: [
                        Text(
                          'Forget Your Password?',
                          style: TextStyle(
                            color: AppColors.whiteColor,
                            fontSize: 15,
                          ),
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SendOtp()));
                            },
                            child: Text(
                              ' Click here',
                              style: TextStyle(
                                color: AppColors.goldColor,
                                fontSize: 15,
                              ),
                            )),
                      ],
                    )),
              ],
            ),
          );
        },
      ),
    );
  }
}
