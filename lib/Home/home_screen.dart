import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gradproject/Home/drawer/courses_screen.dart';
import 'package:gradproject/auth/login/login_screen.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:gradproject/Home/tabs/accScreen.dart';
import 'package:gradproject/Home/tabs/fbScreen.dart';
import 'package:gradproject/Home/tabs/newsScreen.dart';
import 'package:gradproject/Home/tabs/notificationScreen.dart';
import 'package:gradproject/Home/drawer/gpa_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'drawer/NotesScreen.dart';
import '../controllers/Auth/auth_cubit.dart';
import '../controllers/information/data_cubit.dart';
import '../widgets/DrawerLinksCustom.dart';
import 'drawer/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String RouteName = 'homeScreen';
  final int initialTabIndex;

  const HomeScreen({super.key, this.initialTabIndex = 2});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final logoutController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  int selectind = 2;
  var tabs = [
    FbScreen(),
    GpaScreen(),
    NewsScreen(),
    AccScreen(),
    NotificationsScreen()
  ];

  String userName = '';
  double gpa = 0.0;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStudentInfo();
    selectind = widget.initialTabIndex; // Use the passed index
  }

  Future<void> fetchStudentInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("🔑token:$token");

      if (token == null) {
        print("Token is null");
        return;
      }

      final response = await http.get(
        Uri.parse('http://gpa.runasp.net/api/Account/GetStudentInfo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print("🔁 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("🔍 fetchStudentInfo called");

          setState(() {
          userName = data['userName'] ?? 'No user name'; // تأكد من القيمة
          gpa = (data['gpa'] ?? 0.0).toDouble();
          print("🎓 GPA: $gpa");
          isLoading = false;
        });
      } else {
        print(
            "⚠️Failed to load student info. Status code: ${response.statusCode}");
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("❌ Error details:");
      print(e.runtimeType); // نوع الخطأ
      print(e.toString()); // رسالة الخطأ
      if (e is http.ClientException) {
        print("HTTP Client Exception: ${e.message}");
      }
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is SuccessState) {
            print("Navigating to RegisterScreen");
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          } else if (state is FailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: Color(0xff143109)),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage:
                                AssetImage("assets/images/logo.png"),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userName.isNotEmpty ? userName : 'userName',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 18)),
                              Text("GPA: ${gpa.toStringAsFixed(2)}",
                                  style: TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ]),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFFB7935F),
                    ),
                    title: Text('Profile',
                        style: TextStyle(color: Color(0xFFB7935F))),
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (_) => DataCubit()..fetchAllData(),
                            child: ProfileScreen(),
                          ),
                        )),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.calculate_outlined,
                      color: Color(0xFFB7935F),
                    ),
                    title: Text(
                      'Gpa Calculator',
                      style: TextStyle(
                        color: Color(0xFFB7935F),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => HomeScreen(
                                    initialTabIndex: 1,
                                  )));
                    },
                  ),
                  ListTile(
                      leading: Icon(
                        Icons.account_balance,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text(
                        'UMS',
                        style: TextStyle(
                          color: Color(0xFFB7935F),
                        ),
                      ),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrawerLinksCustom(
                                  screenTitle: 'UMS',
                                  url: 'https://ums.asu.edu.eg/')))),
                  ListTile(
                      leading: Icon(
                        Icons.menu_book,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text(
                        'ASU2Learn',
                        style: TextStyle(
                          color: Color(0xFFB7935F),
                        ),
                      ),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrawerLinksCustom(
                                  screenTitle: 'ASU2Learn',
                                  url:
                                  'https://asu2learn.asu.edu.eg/sciencePG/')))),
                  ListTile(
                      leading: Icon(
                        Icons.account_circle_outlined,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text('UMS account',
                          style: TextStyle(color: Color(0xFFB7935F))),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                initialTabIndex: 3), // 0 is Facebook tab index
                          ),
                        );
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.error_outline,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text('Complaints',
                          style: TextStyle(color: Color(0xFFB7935F))),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrawerLinksCustom(
                                  screenTitle: 'Complaints',
                                  url: 'https://forms.office.com/pages/responsepage.aspx?id=ZVH5axNBiEGbe8tsDBmKW-cPAmuMx6dNvjiN17RIMfRUMkRPR0xUMldPOEcwQUNFN1lKUEZLNk9XMy4u&route=shorturl')))),
                  ListTile(
                      leading: Icon(
                        Icons.facebook_sharp,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text('Facebook',
                          style: TextStyle(color: Color(0xFFB7935F))),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                initialTabIndex: 0), // 0 is Facebook tab index
                          ),
                        );
                      }),
                  ListTile(
                      leading: Icon(
                        Icons.widgets_sharp,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text(
                        'Microsoft365',
                        style: TextStyle(
                          color: Color(0xFFB7935F),
                        ),
                      ),
                      onTap: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DrawerLinksCustom(
                                  screenTitle: 'Microsoft365',
                                  url: 'https://login.microsoftonline.com/')))),
                  ListTile(
                      leading: Icon(
                        Icons.notifications_active_outlined,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text('Notifications',
                          style: TextStyle(color: Color(0xFFB7935F))),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                initialTabIndex: 4), // 0 is Facebook tab index
                          ),
                        );
                      }),
                  ListTile(
                    leading: Icon(
                      Icons.library_books_outlined,
                      color: Color(0xFFB7935F),
                    ),
                    title: Text(
                      'Courses',
                      style: TextStyle(
                        color: Color(0xFFB7935F),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CoursesScreen(), // 0 is Facebook tab index
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading: Icon(
                      Icons.notes,
                      color: Color(0xFFB7935F),
                    ),
                    title: Text(
                      'Notes',
                      style: TextStyle(
                        color: Color(0xFFB7935F),
                      ),
                    ),
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotesScreen(), // 0 is Facebook tab index
                        ),
                      );
                    },
                  ),
                  ListTile(
                      leading: Icon(
                        Icons.newspaper,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text('News',
                          style: TextStyle(color: Color(0xFFB7935F))),
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(
                                initialTabIndex: 2), // 0 is Facebook tab index
                          ),
                        );
                      }),
                  Form(
                    key: formKey,
                    child: ListTile(
                      leading: Icon(
                        Icons.logout,
                        color: Color(0xFFB7935F),
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          color: Color(0xFFB7935F),
                        ),
                      ),
                      onTap: () {
                        context.read<AuthCubit>().Logout(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 10.0), // Add some padding to the right
                  child: CircleAvatar(
                    radius: 18, // Adjust the size of the photo
                    backgroundImage: AssetImage('assets/images/logo.png'), // Replace with your image path
                  ),
                ),
              ],
              backgroundColor: Color(0xff143109),
              title: const Column(
                children: [
                  Text(
                    'Faculty Of Science ASU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'ENGR',
                    ),
                  ),
                  Text('كلية العلوم جامعة عين شمس',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'andlso',
                      )),
                ],
              ),
              automaticallyImplyLeading:
                  false, // Prevents Flutter from adding default back button
              leading: Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.menu, color: Colors.white),
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Opens the drawer
                  },
                ),
              ),
            ),
            body: tabs[selectind],
            bottomNavigationBar: Theme(
              data: Theme.of(context).copyWith(canvasColor: Color(0xff143109)),
              child: BottomNavigationBar(
                unselectedItemColor: Colors.white,
                selectedItemColor: Color(0xFFB7935F),
                currentIndex: selectind,
                onTap: (index) {
                  setState(() {
                    selectind = index;
                  });
                },
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.facebook_sharp), label: 'Facebook'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.calculate_outlined),
                      label: 'GPA calculator'),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.newspaper),
                    label: 'News',
                  ),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle_outlined),
                      label: 'Account'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.notifications_active),
                      label: 'Notification'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
