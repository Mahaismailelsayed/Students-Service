import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/auth/forget_password/forget_password_screen.dart';
import 'package:gradproject/auth/forget_password/send_otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/Auth/auth_cubit.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_text_form_field.dart';

class VerificationAccount extends StatefulWidget {
  static const String RouteName = 'verification_acc';

  @override
  State<VerificationAccount> createState() => _VerificationAccountState();
}

class _VerificationAccountState extends State<VerificationAccount> {

  final otpController = TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
  child:  BlocConsumer<AuthCubit, AuthState>(
    listener: (context, state) {
      if (state is SuccessState) {
        print("Navigating to RegisterScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ForgetPasswordScreen()),
        );
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
          top: 15,
          left: 8,
          child: InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SendOtp()));
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryColor,
                size: 30,
              )),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.79,
          left: 18,
          child: Column(children: [
            Text(
              "OTP code verification",
              style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
            ),
            ),
            SizedBox(height: 5,),
            Text('We sent an OTP code to your email. Enter that\n code to confirm your account',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 15,
              fontWeight: FontWeight.w400
            ),),

          ]),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.58,
          left: 20,
          right: 20,
          child: Form(
            key: formKey,
            child: Column(children: [
              CustomTextFormField(
                hint: 'Enter OTP',
                controller: otpController,
              ),
              SizedBox(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 7 ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      String? email = prefs.getString('email');

                      if (email == null || email.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('لم يتم العثور على البريد الإلكتروني')),
                        );
                        return;
                      }

                      BlocProvider.of<AuthCubit>(context).Validateotp(
                        otp: otpController.text,
                      );
                    }
                  },
                  child: Center(
                    child: Text("Continue",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,),
                    ),
                  ),
                  
                ),
              ),
              SizedBox(height: 10,),
            ]),
          ),
        ),
      ]),
    );
  },
),
);
  }
}
