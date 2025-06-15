import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/auth/change_passsword.dart';
import 'package:gradproject/controllers/information/data_cubit.dart';
import 'package:gradproject/widgets/custom_gradient_appbar.dart';

import '../../core/app_colors.dart';
import '../home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context
        .read<DataCubit>()
        .fetchAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: Colors.white,
        child: Image.asset(
          'assets/images/background.png',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
      Scaffold(
        backgroundColor: Colors.transparent,
        appBar: CustomGradientAppBar(
            title: 'My Profile',
            gradientColors: [AppColors.primaryColor, AppColors.lightGreenColor],
            onBackPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }),
        body: BlocBuilder<DataCubit, DataState>(
          builder: (context, state) {
            if (state is DataLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is DataLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'UserName: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreenColor,
                            ),
                          ),
                          TextSpan(
                            text: state.userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Divider(
                      color: AppColors.goldColor,
                      thickness: .5,
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Email: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreenColor,
                            ),
                          ),
                          TextSpan(
                            text: state.email,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor, // لون مختلف
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: AppColors.goldColor, // لون الخط
                      thickness: .5, // سمك الخط
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Phone: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreenColor,
                            ),
                          ),
                          TextSpan(
                            text: state.phoneNumber, // البيانات من الـ response
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor, // لون مختلف
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: AppColors.goldColor, // لون الخط
                      thickness: .5, // سمك الخط
                    ),
                    SizedBox(height: 20),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Cumulative GPA: ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreenColor,
                            ),
                          ),
                          TextSpan(
                            text: state.gpa
                                .toStringAsFixed(2), // البيانات من الـ response
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryColor, // لون مختلف
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Divider(
                      color: AppColors.goldColor, // لون الخط
                      thickness: .5, // سمك الخط
                    ),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: ()=>Navigator.pushReplacement(context,MaterialPageRoute(builder: (context) =>ChangePasssword())),
                      child: Row(
                        children: [
                          Text(
                            'Change Password ',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightGreenColor,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward_ios,color: AppColors.lightGreenColor,size: 15,weight: 50,)
                        ],
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is DataError) {
              return Center(
                child: Text(
                  '❌ ${state.message}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else {
              return const SizedBox(); // حالة مبدئية
            }
          },
        ),
      ),
    ]);
  }
}
