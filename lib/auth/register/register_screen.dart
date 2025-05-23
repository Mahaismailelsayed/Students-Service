import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/app_colors.dart';
import 'package:gradproject/widgets/custom_text_form_field.dart';
import '../../controllers/Auth/auth_cubit.dart';
import '../login/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  static const String RouteName = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmedPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isMale = true;
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
            print("succes");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else if (state is FailedState) {
            print("failed");
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
            backgroundColor: AppColors.primaryColor,
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 0.83.sh,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.r),
                        topRight: Radius.circular(25.r),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12.h,
                  left: 40.w,
                  child: Row(
                    children: [
                      Container(
                        width: 85.w,
                        height: 85.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage("assets/images/logo.png"),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            "Faculty Of Science,\nAin Shams University",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'ENGR',
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.whiteColor,
                            ),
                          ),
                          Text(
                            "كلية العلوم جامعة عين شمس",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'andlso',
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.whiteColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 100.h),
                  child: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
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
                              "Sign up",
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Container(
                              height: 2.5.h,
                              color: AppColors.primaryColor,
                              width: 60.w,
                            ),
                            SizedBox(height: 25.h),
                            CustomTextFormField(
                              hint: 'first name',
                              label: "First Name",
                              controller: firstNameController,
                            ),
                            CustomTextFormField(
                              hint: 'last name',
                              label: "Last Name",
                              controller: lastNameController,
                            ),
                            CustomTextFormField(
                              hint: 'email',
                              label: "Email",
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            CustomTextFormField(
                              hint: 'phone',
                              label: "Phone",
                              controller: phoneController,
                              keyboardType: TextInputType.number,
                            ),
                            CustomTextFormField(
                              hint: 'password',
                              label: "Password",
                              controller: passwordController,
                              isSecure: true,
                            ),
                            CustomTextFormField(
                              hint: 'confirm password',
                              label: "Confirm Password",
                              controller: confirmedPasswordController,
                              isSecure: true,
                            ),
                            CustomTextFormField(
                              hint: 'NID',
                              label: "NID",
                              controller: idController,
                              keyboardType: TextInputType.number,
                            ),
                            SizedBox(height: 10.h),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                minimumSize: Size(double.infinity, 40.h),
                              ),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  BlocProvider.of<AuthCubit>(context).Register(
                                    firstName: firstNameController.text.trim(),
                                    lastName: lastNameController.text.trim(),
                                    email: emailController.text.trim(),
                                    phone: phoneController.text.trim(),
                                    password: passwordController.text.trim(),
                                    confirmPassword:
                                    confirmedPasswordController.text.trim(),
                                    NID: idController.text.trim(),
                                  );
                                }
                              },
                              child: Text(
                                state is LoadingState ? "Loading..." : "Register",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Already have an account",
                                style: TextStyle(
                                  color: AppColors.goldColor,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
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
