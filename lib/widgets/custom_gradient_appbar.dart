import 'package:flutter/material.dart';

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
    this.titleSize = 20,
    this.gradientColors,
    this.borderRadius = 30,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: iconColor,
          size: 25,
        ),
        onPressed: onBackPressed ?? () {
          Navigator.maybePop(context);
        },
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius!),
            bottomRight: Radius.circular(borderRadius!),
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
          fontSize: titleSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: actions,
    );
  }
}