import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_colors.dart';

class CustomArrow extends StatelessWidget{

  @override
  Widget build(BuildContext context,) {
    return Container(
      width: 52.w,
      height: 50.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.lightGreenColor,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.arrow_forward,
          size: 25.sp, // Use sp for responsive icon size
          color: Colors.white,
        ),
      ),
    );
  }
}