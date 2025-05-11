import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../../widgets/custom_gradient_appbar.dart';
import '../home_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<Map<String, dynamic>> courses = [
    {'name': '', 'code': '', 'hours': ''},
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
      TextEditingController(text: course['code']),
      TextEditingController(text: course['hours']),
    ];
  }

  Future<void> _loadUserCourses() async {
    final userName = await _getUsername();
    if (userName == null) {
      print("❌ No username found");
      setState(() {
        controllers = [_createControllersForCourse(courses[0])];
      });
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String key = 'courses_$userName';
    final String? jsonCourses = prefs.getString(key);

    if (jsonCourses != null) {
      final List<dynamic> decoded = jsonDecode(jsonCourses);
      setState(() {
        courses = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
        controllers = courses.map(_createControllersForCourse).toList();
      });
      print("📦 Loaded ${courses.length} courses for $userName");
    } else {
      print("ℹ️ No saved courses for $userName");
      setState(() {
        controllers = [_createControllersForCourse(courses[0])];
      });
    }
  }

  void _addRow() {
    setState(() {
      final newCourse = {'name': '', 'code': '', 'hours': ''};
      courses.add(newCourse);
      controllers.add(_createControllersForCourse(newCourse));
    });
    _saveCourses();
  }

  void _deleteRow(int index) {
    setState(() {
      courses.removeAt(index);
      controllers[index].forEach((controller) => controller.dispose());
      controllers.removeAt(index);
    });
    _saveCourses();
  }

  void _submitCourses() {
    for (var course in courses) {
      print("📚 ${course['name']} - ${course['code']} - ${course['hours']}");
    }
    _saveCourses();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الكورسات')),
    );
  }
  Widget styledText(String text) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppColors.lightGreenColor,
        ),
      ),
    );
  }

  Widget _buildTable() {
    return DataTable(
      border: TableBorder.symmetric(
        inside: BorderSide(width: 1, color: AppColors.goldColor),
        outside: BorderSide(width: 1, color: AppColors.goldColor),
      ),
      columnSpacing: 38,
      columns: const [
        DataColumn(label: Align(
            alignment: Alignment.centerLeft,
            child: Text('Course Name',style: TextStyle(color: AppColors.lightGreenColor,fontWeight:FontWeight.w700 ,fontSize:20)))),
        DataColumn(label: Text('Hours',style: TextStyle(color: AppColors.lightGreenColor,fontWeight:FontWeight.w700 ,fontSize:20))),
        DataColumn(label: Text('Delete',style: TextStyle(color: AppColors.lightGreenColor,fontWeight:FontWeight.w700 ,fontSize:20))),
      ],
      rows: List.generate(courses.length, (index) {
        return DataRow(cells: [
          DataCell(SizedBox(
            width: 120, // تحديد عرض ثابت للحقل
            child: TextFormField(
              cursorColor: AppColors.goldColor,
              style: const TextStyle(
                fontSize: 20,
                color: AppColors.lightGreenColor,
              ),
              controller: controllers[index][0],
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              maxLines: null, // السماح بأسطر متعددة
              textInputAction: TextInputAction.newline, // إضافة سطر جديد عند الضغط على Enter
              textAlign: TextAlign.start, // محاذاة النص من البداية
              onChanged: (val) {
                courses[index]['name'] = val;
                _saveCourses(); // حفظ تلقائي
              },
            ),
          ),),
          DataCell(TextFormField(
            cursorColor: AppColors.goldColor,
            style: const TextStyle(
              fontSize: 20,
              color: AppColors.lightGreenColor,
            ),
            controller: controllers[index][2],
            decoration: const InputDecoration(border: InputBorder.none),
            keyboardType: TextInputType.number,
            onChanged: (val) {
              courses[index]['hours'] = val;
              _saveCourses(); // حفظ تلقائي عند التغيير
            },
          )),
          DataCell(IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteRow(index),
          )),
        ]);
      }),
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  _buildTable(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(AppColors.lightGreenColor)),
                        onPressed: _addRow,
                        icon: const Icon(Icons.add,color:AppColors.whiteColor),
                        label: const Text('Add Course',style: TextStyle(color: AppColors.whiteColor,fontSize: 20,)),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(AppColors.lightGreenColor)),
                        onPressed: _submitCourses,
                        icon: const Icon(Icons.save,color:AppColors.whiteColor),
                        label: const Text('Save',style: TextStyle(color: AppColors.whiteColor,fontSize: 20,),),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}