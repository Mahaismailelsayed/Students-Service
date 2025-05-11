import 'package:flutter/material.dart';
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
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor, // يمكنك تغيير اللون ليكون متوافقًا مع `AppColors`
            ),
          ),
        ],
        SizedBox(height: 5),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          cursorColor: AppColors.goldColor,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.whiteColor,
            hintText: "${widget.hint}",
            hintStyle: TextStyle(color: AppColors.lightGrayColor, fontSize: 15),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldColor, width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.goldColor, width: 1),
              borderRadius: BorderRadius.circular(18),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffAA3229), width: 1),
              borderRadius: BorderRadius.circular(18),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffAA3229), width: 1.5),
              borderRadius: BorderRadius.circular(18),
            ),
            suffixIcon: widget.isSecure
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.primaryColor,
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
        SizedBox(height: 10),
      ],
    );
  }
}
