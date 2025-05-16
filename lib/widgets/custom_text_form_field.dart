import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/app_colors.dart';

class CustomTextFormField extends StatefulWidget {
  final String? label;
  final String hint;
  final TextEditingController controller;
  final bool isSecure;
  final TextInputType keyboardType;

  const CustomTextFormField({
    super.key,
    this.label,
    required this.hint,
    required this.controller,
    this.isSecure = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isSecure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null && widget.label!.isNotEmpty) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 15.sp, // تكييف حجم الخط
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ],
        SizedBox(height: 5.h), // تكييف الارتفاع
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          cursorColor: AppColors.goldColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.whiteColor,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: AppColors.lightGrayColor,
              fontSize: 15.sp, // تكييف حجم الخط
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldColor, width: 1.5.w), // تكييف عرض الحد
              borderRadius: BorderRadius.circular(18.r), // تكييف نصف القطر
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldColor, width: 1.w), // تكييف عرض الحد
              borderRadius: BorderRadius.circular(18.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xffAA3229), width: 1.w),
              borderRadius: BorderRadius.circular(18.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: const Color(0xffAA3229), width: 1.5.w),
              borderRadius: BorderRadius.circular(18.r),
            ),
            suffixIcon: widget.isSecure
                ? IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility : Icons.visibility_off,
                color: AppColors.primaryColor,
                size: 20.sp, // تكييف حجم الأيقونة
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            )
                : null,
          ),
          validator: (input) {
            if (input == null || input.isEmpty) {
              return "Enter ${widget.label}";
            }
            return null;
          },
        ),
        SizedBox(height: 10.h), // تكييف الارتفاع
      ],
    );
  }
}
