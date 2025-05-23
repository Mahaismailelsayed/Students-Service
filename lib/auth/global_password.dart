import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/auth/register/register_screen.dart';
import 'package:gradproject/widgets/custom_arrow.dart';
import '../controllers/Auth/auth_cubit.dart';
import '../core/app_colors.dart';

class GlobalPassword extends StatefulWidget {
  static const String RouteName = 'global_screen';

  const GlobalPassword({super.key});

  @override
  State<GlobalPassword> createState() => _GlobalPasswordState();
}

class _GlobalPasswordState extends State<GlobalPassword> {
  final globalPasswordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  bool isSecure = true;

  @override
  void dispose() {
    _scrollController.dispose();
    globalPasswordController.dispose();
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
            print("Navigating to RegisterScreen");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => RegisterScreen()),
            );
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            // Prevent resizing when keyboard appears
            backgroundColor: AppColors.whiteColor,
            body: SafeArea(
              minimum: EdgeInsets.zero,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(
                  bottom: MediaQuery
                      .of(context)
                      .viewInsets
                      .bottom + 20, // Adjust for keyboard
                ),
                child: SizedBox(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height, // Define Stack height
                  child: Stack(
                    children: [
                      // Bottom Colored Section
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.5,
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
                      // Top Section (White with Logo & Text)
                      Positioned(
                        top: 85.h,
                        left: 27.w,
                        child: Row(
                          children: [
                            // University Logo
                            Image.asset("assets/images/logo.png", height: 80.h),
                            // University Name
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
                      // Form Container
                      Positioned(
                        bottom: MediaQuery
                            .of(context)
                            .size
                            .height * 0.4,
                        left: 20.w,
                        right: 20.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 15.h),
                          decoration: BoxDecoration(
                            color: AppColors.whiteColor,
                            borderRadius: BorderRadius.circular(20.r),
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
                                  "Global Password",
                                  style: TextStyle(
                                    fontStyle: FontStyle.normal,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Container(
                                  height: 2.5.h,
                                  color: AppColors.primaryColor,
                                  width: 135.w,
                                ),
                                SizedBox(height: 18.h),
                                TextFormField(
                                  controller: globalPasswordController,
                                  obscureText: isSecure,
                                  cursorColor: AppColors.goldColor,
                                  onTap: _scrollToField,
                                  // Scroll when focused
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter the global password';
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.whiteColor,
                                    hintText: "Global Password",
                                    hintStyle: TextStyle(
                                      color: AppColors.lightGrayColor,
                                      fontSize: 15.sp,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.goldColor,
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: AppColors.goldColor,
                                        width: 1.w,
                                      ),
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffAA3229),
                                        width: 1.w,
                                      ),
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color(0xffAA3229),
                                        width: 1.5.w,
                                      ),
                                      borderRadius: BorderRadius.circular(18.r),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Submit Button
                      Positioned(
                        bottom: MediaQuery
                            .of(context)
                            .size
                            .height * 0.36,
                        left: (MediaQuery
                            .of(context)
                            .size
                            .width - 50) / 2, // Center horizontally
                        child: InkWell(
                          onTap: () {
                            if (formKey.currentState!.validate()) {
                              BlocProvider.of<AuthCubit>(context).globalPass(
                                Password: globalPasswordController.text,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(50.r),
                          child: CustomArrow(),
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
