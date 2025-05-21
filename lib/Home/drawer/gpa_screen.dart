import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/core/app_colors.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../controllers/information/data_cubit.dart';
import '../../core/number_range.dart';

class GpaScreen extends StatefulWidget {
  static const String RouteName = 'gpa_screen';

  @override
  State<GpaScreen> createState() => _GpaScreenState();
}

class _GpaScreenState extends State<GpaScreen> {
  final List<String> options = ["A", "A-", "B+", "B", "C+", "C", "D", "F"];
  List<List<TextEditingController>> _controllers = [];
  TextEditingController _prevHoursController = TextEditingController();
  TextEditingController _prevGpaController = TextEditingController();
  int _dataRefreshKey = 0; // Added to trigger FutureBuilder rebuild

  @override
  void initState() {
    super.initState();
    _loadSavedGpaData();
    _addTextFieldRow(); // Initialize with one empty row
  }

  Future<void> _loadSavedGpaData() async {
    final prefs = await SharedPreferences.getInstance();
    double? savedGpa = prefs.getDouble('savedCumulativeGpa');
    double? savedHours = prefs.getDouble('savedCreditHours');

    if (savedGpa != null) {
      _prevGpaController.text = savedGpa.toStringAsFixed(2);
    }
    if (savedHours != null) {
      _prevHoursController.text = savedHours.toStringAsFixed(0);
    }
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

  Future<double> _getPrevHours() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    if (userName != null) {
      return prefs.getDouble('$userName-savedCreditHours') ?? 0;
    }
    return 0;
  }

  Future<double> _getPrevGpa() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    if (userName != null) {
      return prefs.getDouble('$userName-savedCumulativeGpa') ?? 0;
    }
    return 0;
  }

  Future<void> _refreshGpaData() async {
    await SavedGpaData();
    setState(() {
      _dataRefreshKey++; // Trigger FutureBuilder rebuild
    });
  }

  Future<void> SavedGpaData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');

    if (userName != null) {
      double? savedGpa = prefs.getDouble('$userName-savedCumulativeGpa');
      double? savedHours = prefs.getDouble('$userName-savedCreditHours');

      if (savedGpa != null) {
        _prevGpaController.text = savedGpa.toStringAsFixed(2);
      }
      if (savedHours != null) {
        _prevHoursController.text = savedHours.toStringAsFixed(0);
      }
    }
  }

  Future<void> _calculateGpa() async {
    List<Map<String, dynamic>> courses = [];
    double totalCredits = 0;

    for (var row in _controllers) {
      String courseName = row[0].text.trim();
      String creditText = row[1].text.trim();
      String grade = row[2].text.trim();

      if (courseName.isEmpty || creditText.isEmpty || grade.isEmpty) {
        _showDialog("Input Error", "Please fill all fields for each course.");
        return;
      }

      double? credit = double.tryParse(creditText);
      if (credit == null || credit <= 0) {
        _showDialog("Input Error", "Credit hours must be a positive number.");
        return;
      }

      if (!options.contains(grade.toUpperCase())) {
        _showDialog("Input Error", "Invalid grade selected.");
        return;
      }

      int creditHours = credit.toInt();
      courses.add({
        "courseName": courseName,
        "creditHours": creditHours,
        "grade": grade.toUpperCase(),
      });
      totalCredits += creditHours;
    }

    if (courses.isEmpty) {
      _showDialog("Input Error", "Please enter at least one valid course.");
      return;
    }

    if (totalCredits == 0) {
      _showDialog("Error", "Total credit hours cannot be zero.");
      return;
    }

    final url = Uri.parse("http://gpa.runasp.net/api/Gpa/calculateGPA");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(courses),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        double gpa = result;

        final prefs = await SharedPreferences.getInstance();
        String? userName = prefs.getString('userName');

        if (userName == null) {
          _showDialog("Error", "User is not logged in.");
          return;
        }

        double prevHours = prefs.getDouble('$userName-savedCreditHours') ?? 0;
        double prevGpa = prefs.getDouble('$userName-savedCumulativeGpa') ?? 0;

        double currentQualityPoints = gpa * totalCredits;
        double previousQualityPoints = prevGpa * prevHours;
        double cumulativeQualityPoints = currentQualityPoints + previousQualityPoints;

        double totalAllCredits = totalCredits + prevHours;
        double cumulativeGpa = totalAllCredits > 0 ? cumulativeQualityPoints / totalAllCredits : 0;

        _showDialog(
          "GPA Results",
          "Your Semester GPA is: ${gpa.toStringAsFixed(2)}\n"
              "Your Cumulative GPA is: ${cumulativeGpa.toStringAsFixed(2)}",
          onConfirm: () async {
            setState(() {
              _prevHoursController.text = totalAllCredits.toStringAsFixed(0);
              _prevGpaController.text = cumulativeGpa.toStringAsFixed(2);
            });

            await prefs.setDouble('$userName-savedCumulativeGpa', cumulativeGpa);
            await prefs.setDouble('$userName-savedCreditHours', totalAllCredits);

            await _updateGpa(cumulativeGpa);

            await _refreshGpaData(); // Refresh FutureBuilder data
          },
        );
      } else {
        _showDialog("Error",
            "Failed to calculate GPA.\nStatus code: ${response.statusCode}\n${response.body}");
      }
    } catch (e) {
      _showDialog("Connection Error", "Could not connect to server. Please try again.\n$e");
    }
  }

  Future<void> _updateGpa(double newGpa) async {
    final url = Uri.parse("http://gpa.runasp.net/api/Gpa/update");

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      _showDialog("Error", "يجب تسجيل الدخول أولاً");
      return;
    }
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "newGpa": newGpa,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "تم تحديث المعدل التراكمي بنجاح!",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
        );
      } else {
        _showDialog("Error", "فشل في التحديث: ${response.body}");
      }
    } catch (e) {
      _showDialog("Connection Error", "تعذر الاتصال بالخادم: $e");
    }
  }

  void _showDialog(String title, String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            title,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.primaryColor),
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
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int flex = 1, bool isNumber = false, bool isCredit = false}) {
    if (isCredit) {
      return Expanded(
        flex: flex,
        child: NumberInputField(
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
      );
    }
    return Expanded(
      flex: flex,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
        decoration: InputDecoration(
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
    if (index < 0 || index >= _controllers.length || _controllers[index].length < 3) {
      return Expanded(
        flex: 3,
        child: TextField(
          readOnly: true,
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
          decoration: InputDecoration(
            hintText: 'Select Grade',
            hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
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
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            borderRadius: BorderRadius.circular(10.r),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.w),
            borderRadius: BorderRadius.circular(10.r),
          ),
          suffixIcon: PopupMenuButton<String>(
            icon: Icon(Icons.arrow_drop_down, size: 20.sp, color: AppColors.primaryColor),
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
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: ListView(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FutureBuilder<double>(
                        key: ValueKey(_dataRefreshKey), // Trigger rebuild on key change
                        future: _getPrevHours(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Prev Hours: Loading...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Prev Hours: Error',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              'Prev Hours: ${snapshot.data?.toStringAsFixed(0) ?? '0'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else {
                            return Text(
                              'Prev Hours: 0',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: FutureBuilder<double>(
                        key: ValueKey(_dataRefreshKey), // Trigger rebuild on key change
                        future: _getPrevGpa(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text(
                              'Prev GPA: Loading...',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Prev GPA: Error',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else if (snapshot.hasData) {
                            return Text(
                              'Prev GPA: ${snapshot.data?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          } else {
                            return Text(
                              'Prev GPA: 0.00',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            );
                          }
                        },
                      ),
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
                      style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
                      textAlign: TextAlign.center,
                    ),
                  )
                else
                  ...List.generate(_controllers.length, (index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      child: Row(
                        children: [
                          _buildTextField(_controllers[index][0], 'Enter Course', flex: 4),
                          SizedBox(width: 8.w),
                          _buildTextField(_controllers[index][1], '', flex: 2, isNumber: true, isCredit: true),
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
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
                    onPressed: _calculateGpa,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightGreenColor,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
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
  }
}