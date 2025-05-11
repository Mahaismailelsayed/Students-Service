import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/Home/drawer/profile_screen.dart';
import 'package:gradproject/widgets/custom_text_form_field.dart';
import '../controllers/Auth/auth_cubit.dart';
import '../controllers/information/data_cubit.dart';
import '../core/app_colors.dart';
import '../widgets/custom_gradient_appbar.dart';

class ChangePasssword extends StatefulWidget {
  static const String RouteName = '/change_password';

  const ChangePasssword({super.key});

  @override
  State<ChangePasssword> createState() => _ChangePassswordState();
}

class _ChangePassswordState extends State<ChangePasssword> {
  final userNameController = TextEditingController();

  final oldPasswordController = TextEditingController();

  final newPasswordController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("Password changed successfully");
            userNameController.clear();
            oldPasswordController.clear();
            newPasswordController.clear();
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

            // يقفل بعد 10 ثواني تلقائياً
            Future.delayed(const Duration(seconds: 10), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return  Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: CustomGradientAppBar(
            title: 'Change Password',
            gradientColors: [AppColors.primaryColor, AppColors.lightGreenColor],
            onBackPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => DataCubit(),
                    child: ProfileScreen(),
                  ),
                ),
              );
            }),
        body: Stack(
          children: [ Positioned(
            bottom: MediaQuery.of(context).size.height * 0.3,
            left: 25,
            right: 35,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    CustomTextFormField(
                      hint: 'UserName',
                      controller: userNameController,
                      label: 'UserName',
                    ),
                    CustomTextFormField(
                      hint: 'Old Password',
                      controller: oldPasswordController,
                      label: 'Old Password',
                      isSecure: true,
                    ),
                    CustomTextFormField(
                      hint: 'New Password',
                      controller: newPasswordController,
                      label: 'New Password',
                      isSecure: true,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          BlocProvider.of<AuthCubit>(context).ChangePass(
                            userName: userNameController.text.trim(),
                            oldPassword: oldPasswordController.text.trim(),
                            newPassword: newPasswordController.text.trim(),
                          );
                        }
                      },
                      child: Center(
                        child: Text(
                          "Change",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
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
