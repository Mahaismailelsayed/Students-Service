import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        print("Navigating to RegisterScreen");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerificationAccount()),
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
                        builder: (context) => LoginScreen()));
              },
              child: Icon(
                Icons.arrow_back,
                color: AppColors.primaryColor,
                size: 30,
              )),
        ),

        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.85,
          left: 20,
          child: Column(children: [
            Text("Find your account",
              style: TextStyle(color: AppColors.primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
              ),),
          ]),
        ),
        Positioned(
          bottom: MediaQuery.of(context).size.height * 0.6,
          left: 20,
          right: 20,
          child: Form(
            key: formKey,
            child: Column(children: [
              CustomTextFormField(
                hint: 'Email',
                label: 'Enter your email',
                controller: emailController,
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
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      BlocProvider.of<AuthCubit>(context).Sendotp(
                        Email: emailController.text,
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
