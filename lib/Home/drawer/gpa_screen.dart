import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/app_colors.dart';
import '../../controllers/gpa_cubit.dart';
import '../../core/gpa_range.dart';
import '../../core/number_range.dart';

class GpaScreen extends StatefulWidget {
  static const String RouteName = 'gpa_screen';

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  final List<String> options =['A', 'A-', 'B+', 'B', 'C+', 'C', 'D', 'F'];
  List<List<TextEditingController>> _controllers = [];
  TextEditingController _prevHoursController = TextEditingController();
  TextEditingController _prevGpaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _addTextFieldRow();
    context.read<GpaCubit>().loadSavedGpaData();
  }

  @override
  void dispose() {
    _prevHoursController.dispose();
    _prevGpaController.dispose();
    for (var row in _controllers) {
      for (var controller in row) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _addTextFieldRow() {
    setState(() {
      _controllers.add([
        TextEditingController(),
        TextEditingController(),
        TextEditingController(),
      ]);
    });
  }

  void _removeTextFieldRow(int index) {
    if (index < 0 || index >= _controllers.length) return;
    setState(() {
      _controllers[index].forEach((controller) => controller.dispose());
      _controllers.removeAt(index);
    });
  }

  void _showDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor),
          ),
          content: Text(
            message,
            style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                if (onConfirm != null) onConfirm();
              },
              child: Text(
                title == "GPA Results" ? "Save" : "OK",
                style: TextStyle(
                  color: AppColors.lightGreenColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
            if (title == "GPA Results")
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14.sp,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(
  TextEditingController controller,
  String hintText, {
  int flex = 1,
  bool isNumber = false,
  bool isNum=false,
  bool isCredit = false,
  String? label,
  }){
    final labelWidget = label != null
        ? Padding(
      padding: EdgeInsets.only(bottom: 5.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.primaryColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    ) : SizedBox.shrink();
    if (isCredit) {
      return Expanded(
        flex: flex,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            labelWidget,
            NumberInputField(
              controller: controller,
              labelText: hintText.isEmpty ? 'Credit' : hintText,
              decoration: InputDecoration(
                hintText: hintText.isEmpty ? 'Credit' : hintText,
                hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.w),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red, width: 2.w),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
      );
    }
    if (isNum) {
      return Expanded(
        flex: flex,
        child: GpaInputField(
          controller: controller,
          labelText: hintText,
          decoration: InputDecoration(
            labelText: hintText,
            hintText: 'Enter a number from 1 to 4',
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      );
    }

    return Expanded(
      flex: flex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labelWidget,
          TextField(

            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
            decoration: InputDecoration(
              labelText: hintText,
              hintText: hintText,
              hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2.w),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeaderBox(String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryColor, AppColors.lightGreenColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.whiteColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          fontFamily: 'IMPRISHA',
        ),
      ),
    );
  }

  Widget _buildDropdownField(int index) {
    if (index < 0 ||
        index >= _controllers.length ||
        _controllers[index].length < 3) {
      return Expanded(
        flex: 3,
        child: TextField(
          readOnly: true,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
          decoration: InputDecoration(
            hintText: 'Select Grade',
            hintStyle:
            TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      );
    }
    return Expanded(
      flex: 3,
      child: TextField(
        controller: _controllers[index][2],
        readOnly: true,
        style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
        decoration: InputDecoration(
          hintText: 'Select Grade',
          hintStyle:
          TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            borderRadius: BorderRadius.circular(10.r),
          ),
          suffixIcon: PopupMenuButton<String>(
            icon: Icon(Icons.arrow_drop_down,
                size: 20.sp, color: AppColors.primaryColor),
            onSelected: (String value) {
              setState(() {
                _controllers[index][2].text = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return options.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(
                    choice,
                    style: TextStyle(
                        fontSize: 14.sp, color: AppColors.primaryColor),
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GpaCubit, GpaState>(
      listener: (context, state) {
        if (state is GpaError) {
          _showDialog("Error", state.message);
        } else if (state is GpaCalculated) {
          _showDialog(
            "GPA Results",
            "Your Semester GPA is: ${state.semesterGpa.toStringAsFixed(2)}\n"
                "Your Cumulative GPA is: ${state.cumulativeGpa.toStringAsFixed(2)}",
            onConfirm: () {
              context.read<GpaCubit>().saveGpa(
                state.cumulativeGpa,
                state.totalCredits,
              );
            },
          );
        } else if (state is GpaLoaded) {
          _prevGpaController.text = state.prevGpa.toStringAsFixed(2);
          _prevHoursController.text = state.prevHours.toStringAsFixed(0);
        } else if (state is GpaSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Cumulative GPA saved successfully",
                style: TextStyle(fontSize: 14.sp),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        return Stack(
          children: [
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
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: state is GpaLoading ? 5.h : 15.h),
                child: ListView(
                  children: [
                    Row(
                      children: [
                        _buildTextField(
                          _prevHoursController,
                          'Previous Hours',
                          flex: 1,
                          isNumber: true,
                        ),
                        SizedBox(width: 16.w),
                        _buildTextField(
                          _prevGpaController,
                          'Previous GPA',
                          flex: 1,
                          isNumber: true,
                          isNum: true,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 18.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHeaderBox('Course Name'),
                          _buildHeaderBox('Credit'),
                          _buildHeaderBox('Grade'),
                        ],
                      ),
                    ),
                    if (_controllers.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 20.h),
                        child: Text(
                          'No courses added yet. Tap "Add Course" to start.',
                          style: TextStyle(
                              fontSize: 14.sp, color: AppColors.primaryColor),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      ...List.generate(_controllers.length, (index) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Row(
                            children: [
                              _buildTextField(
                                  _controllers[index][0], 'Enter Course',
                                  flex: 4),
                              SizedBox(width: 8.w),
                              _buildTextField(_controllers[index][1], '',
                                  flex: 2, isNumber: true, isCredit: true),
                              SizedBox(width: 8.w),
                              _buildDropdownField(index),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20.sp,
                                  ),
                                  onPressed: () => _removeTextFieldRow(index),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    SizedBox(height: 16.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: _addTextFieldRow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add, color: Colors.white, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              "Add Course",
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'IMPRISHA',
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          List<Map<String, dynamic>> courses = _controllers
                              .where((row) => row.every((controller) =>
                          controller.text.trim().isNotEmpty))
                              .map((row) => {
                            "courseName": row[0].text.trim(),
                            "creditHours":
                            int.tryParse(row[1].text.trim()) ?? 0,
                            "grade": row[2].text.trim(),
                          })
                              .toList();

                          final gpaCubit = context.read<GpaCubit>();
                          bool valid =
                          gpaCubit.validateCourseInputs(courses, options);

                          if (valid) {
                            final parsedPrevGpa =
                                double.tryParse(_prevGpaController.text.trim()) ??
                                    0.0;
                            final parsedPrevHours = double.tryParse(
                                _prevHoursController.text.trim()) ??
                                0.0;

                            gpaCubit.calculateGpa(
                              courses,
                              parsedPrevGpa,
                              parsedPrevHours,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightGreenColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 24.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Calculate GPA",
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'IMPRISHA',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}