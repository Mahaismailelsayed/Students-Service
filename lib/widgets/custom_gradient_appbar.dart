import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomGradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? iconColor;
  final double? titleSize;
  final List<Color>? gradientColors;
  final double? borderRadius;

  const CustomGradientAppBar({
    required this.title,
    this.onBackPressed,
    this.actions,
    this.iconColor = Colors.white,
    this.titleSize = 25,
    this.gradientColors,
    this.borderRadius = 40,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight.h);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: iconColor,
          size: 30.sp,
        ),
        onPressed: onBackPressed ?? () {
          Navigator.maybePop(context);
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius!.r),
            bottomRight: Radius.circular(borderRadius!.r),
          ),
          gradient: LinearGradient(
            colors: gradientColors ?? [Colors.blue, Colors.lightGreen],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: iconColor,
          fontFamily: 'IMPRISHA',
          fontSize: titleSize!.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions,
    );
  }
}