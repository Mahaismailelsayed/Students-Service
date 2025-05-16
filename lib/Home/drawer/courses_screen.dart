import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_gradient_appbar.dart';
import '../home_screen.dart';

class CoursesScreen extends StatefulWidget {
  static const String RouteName = 'courses_entry';

  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> courses = [
    {'name': '', 'day': '', 'time': ''},
  ];
  List<List<TextEditingController>> controllers = [];

  @override
  void initState() {
    super.initState();
    _loadUserCourses();
  }

  @override
  void dispose() {
    for (var controllerList in controllers) {
      for (var controller in controllerList) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  Future<void> _saveCourses() async {
    final userName = await _getUsername();
    if (userName == null) {
      print("❌ No username found");
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    final String key = 'courses_$userName';
    final String jsonCourses = jsonEncode(courses);
    await prefs.setString(key, jsonCourses);
    print("✅ Courses saved for $userName: $jsonCourses");
  }

  List<TextEditingController> _createControllersForCourse(Map<String, dynamic> course) {
    return [
      TextEditingController(text: course['name']),
      TextEditingController(text: course['day']),
      TextEditingController(text: course['time']),
    ];
  }

  Future<void> _loadUserCourses() async {
    final userName = await _getUsername();
    if (userName == null) {
      print("❌ No username found");
      setState(() {
        courses = [{'name': '', 'day': '', 'time': ''}];
        controllers = [_createControllersForCourse(courses[0])];
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String key = 'courses_$userName';
    final String? jsonCourses = prefs.getString(key);

    setState(() {
      if (jsonCourses != null) {
        final List<dynamic> decoded = jsonDecode(jsonCourses);
        courses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        controllers = courses.map(_createControllersForCourse).toList();
        print("📦 Loaded ${courses.length} courses for $userName");
      } else {
        print("ℹ️ No saved courses for $userName");
        courses = [{'name': '', 'day': '', 'time': ''}];
        controllers = [_createControllersForCourse(courses[0])];
      }
    });
  }

  void _addRow() {
    setState(() {
      final newCourse = {'name': '', 'day': '', 'time': ''};
      courses.add(newCourse);
      controllers.add(_createControllersForCourse(newCourse));
    });
    _saveCourses();
  }

  void _deleteRow(int index) {
    if (index < 0 || index >= courses.length) return;
    setState(() {
      courses.removeAt(index);
      controllers[index].forEach((controller) => controller.dispose());
      controllers.removeAt(index);
    });
    _saveCourses();
  }

  void _submitCourses() {
    bool hasValidCourse = false;
    for (var course in courses) {
      if (course['name'].isNotEmpty || course['day'].isNotEmpty || course['time'].isNotEmpty) {
        hasValidCourse = true;
        print("📚 ${course['name']} - ${course['day']} - ${course['time']}");
      }
    }
    if (!hasValidCourse) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            "Warning",
            style: TextStyle(
              color: AppColors.lightGreenColor,
              fontWeight: FontWeight.w700,
              fontSize: 20.sp,
            ),
          ),
          content: Text(
            'No valid courses entered.',
            style: TextStyle(
              color: AppColors.lightGreenColor,
              fontWeight: FontWeight.w400,
              fontSize: 18.sp,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "OK",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }
    _saveCourses();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Success",
          style: TextStyle(
            color: AppColors.lightGreenColor,
            fontWeight: FontWeight.w700,
            fontSize: 20.sp,
          ),
        ),
        content: Text(
          'Courses Are Saved',
          style: TextStyle(
            color: AppColors.lightGreenColor,
            fontWeight: FontWeight.w400,
            fontSize: 18.sp,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget styledText(String text) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGreenColor,
        ),
      ),
    );
  }

  Widget _buildTable() {
    if (courses.isEmpty || controllers.isEmpty || courses.length != controllers.length) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Text(
          'No courses added yet. Tap "Add Course" to start.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.primaryColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      width: 1.sw, // Full screen width
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          border: TableBorder.symmetric(
            inside: BorderSide(width: 1.w, color: AppColors.goldColor),
            outside: BorderSide(width: 1.w, color: AppColors.goldColor),
          ),
          columnSpacing: 8.w,
          dataRowMinHeight: 48.h,
          dataRowMaxHeight: 64.h,
          columns: [
            DataColumn(
              label: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Course Name',
                  style: TextStyle(
                    color: AppColors.lightGreenColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                  ),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Day',
                style: TextStyle(
                  color: AppColors.lightGreenColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Time',
                style: TextStyle(
                  color: AppColors.lightGreenColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                'Delete',
                style: TextStyle(
                  color: AppColors.lightGreenColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
              ),
            ),
          ],
          rows: List.generate(courses.length, (index) {
            return DataRow(cells: [
              DataCell(
                SizedBox(
                  width: 140.w, // Adjusted for better fit
                  child: TextFormField(
                    cursorColor: AppColors.goldColor,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.lightGreenColor,
                    ),
                    controller: controllers[index][0],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      hintText: 'Enter course',
                      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    textAlign: TextAlign.start,
                    onChanged: (val) {
                      courses[index]['name'] = val;
                      _saveCourses();
                    },
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 80.w,
                  child: TextFormField(
                    maxLines: null,
                    cursorColor: AppColors.goldColor,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.lightGreenColor,
                    ),
                    controller: controllers[index][1],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      hintText: 'Enter day',
                      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
                    ),
                    onChanged: (val) {
                      courses[index]['day'] = val;
                      _saveCourses();
                    },
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 80.w,
                  child: TextFormField(
                    cursorColor: AppColors.goldColor,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.lightGreenColor,
                    ),
                    controller: controllers[index][2],
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 4.h),
                      hintText: 'Enter time',
                      hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.lightGrayColor),
                    ),
                    keyboardType: TextInputType.datetime,
                    onChanged: (val) {
                      courses[index]['time'] = val;
                      _saveCourses();
                    },
                  ),
                ),
              ),
              DataCell(
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                  onPressed: () => _deleteRow(index),
                ),
              ),
            ]);
          }),
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
          appBar: CustomGradientAppBar(
            title: 'Courses',
            gradientColors: [AppColors.primaryColor, AppColors.lightGreenColor],
            onBackPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildTable(),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreenColor,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _addRow,
                      icon: Icon(Icons.add, color: AppColors.whiteColor, size: 20.sp),
                      label: Text(
                        'Add Course',
                        style: TextStyle(color: AppColors.whiteColor, fontSize: 16.sp),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightGreenColor,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      onPressed: _submitCourses,
                      icon: Icon(Icons.save, color: AppColors.whiteColor, size: 20.sp),
                      label: Text(
                        'Save',
                        style: TextStyle(color: AppColors.whiteColor, fontSize: 16.sp),
                      ),
                    ),
                  ],
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