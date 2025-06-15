import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/token_utils.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitialState());

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      return false;
    }
    else {
      print("$token");
      return true;

    }

  }

  Future<void> Logout(BuildContext context) async {
    emit(LoadingState());

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null || TokenUtils.isTokenExpired(token)) {
        print("⏰ التوكن غير موجود أو منتهي الصلاحية");
        await prefs.remove('token');
        await prefs.setBool('hasLoggedIn', false);
        Navigator.of(context).pushReplacementNamed('login_screen');
        return;
      }

      final response = await http.post(
        Uri.parse('http://gpa.runasp.net/api/Account/Logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      print("🔁 Status code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");
      print("📦 token being sent: Bearer $token");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['isSuccess'] == true) {
          debugPrint("Response is: $data");
          emit(SuccessState());
          // مسح التوكن وحالة اللوج إن
          await prefs.remove('token');
          await prefs.setBool('hasLoggedIn', false); // إضافة هذه السطر
          Navigator.of(context).pushReplacementNamed('login_screen');
        }

        else {
          emit(FailedState(
            message: data['message'] ?? "حدث خطأ أثناء تسجيل الخروج",
          ));
          debugPrint("📌 Full Response: ${response.body}");
        }
      } else {
        emit(FailedState(message: "فشل الاتصال بالسيرفر"));
        debugPrint("📌 Full Response: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 Failed to Logout: $e");
      emit(FailedState(message: "حدث خطأ غير متوقع: $e"));
    }
  }
  //Global Pass http
  Future<void> globalPass({required String Password}) async {
    // Emit loading state
    emit(LoadingState());
    // Validate input
    if (Password.isEmpty) {
      emit(FailedState(message: "Enter the Password"));
      return;
    }
    if (Password != 'W%4012qsx%24%25233') {
      emit(FailedState(message: "Uncorrect Password"));
      return;
    }
    try {
      // Make API request
      final response = await http
          .post(
            Uri.parse(
                "http://gpa.runasp.net/api/Account/CheckPassword?Password=W%4012qsx%24%25233"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "GlobalPassword": Password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      // Print response for debugging
      debugPrint("Status Code: ${response.statusCode}");
      print("📦 Response body: ${response.body}");

      // Decode response
      final responseBody = jsonDecode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Emit success state
        if (responseBody['success'] == true) {
          emit(SuccessState());
        } else {
          // Emit failed state with error message
          emit(FailedState(
            message: responseBody['message'] ?? "فشل التحقق من كلمة المرور",
          ));
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      print("Error: $e");
      emit(FailedState(message: "حدث خطأ غير متوقع"));
    }
  }

  //Register http
  Future<void> Register(
      {required String firstName,
      required String lastName,
      required String email,
      required String phone,
      required String password,
      required String confirmPassword,
      required String NID}) async {

    String? validateNID(String nid) {
      if (!RegExp(r'^\d{14}$').hasMatch(nid)) {
        return "الرقم القومي يجب أن يكون 14 رقمًا";
      }
      return null;
    }
    String? validatePhone(String phone) {
      if (!RegExp(r'^01[0-9]{9}$').hasMatch(phone)) {
        return "رقم الهاتف يجب أن يكون 11 رقمًا ويبدأ بـ 01";
      }
      return null;
    }
    String? validatePassword(String password) {
      if (password.length < 6) {
        return "كلمة المرور يجب ألا تقل عن 6 أحرف";
      }

      if (!RegExp(r'[a-z]').hasMatch(password)) {
        return "كلمة المرور يجب أن تحتوي على حرف صغير (a-z) على الأقل";
      }

      if (!RegExp(r'[A-Z]').hasMatch(password)) {
        return "كلمة المرور يجب أن تحتوي على حرف كبير (A-Z) على الأقل";
      }

      if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        return "كلمة المرور يجب أن تحتوي على رمز خاص (!@#...) على الأقل";
      }

      return null; // Valid password
    }

    final passwordError = validatePassword(password);
    final nidError = validateNID(NID);
    final phoneError = validatePhone(phone);

    if (nidError != null) {
      emit(FailedState(message: nidError));
      return;
    }

    if (phoneError != null) {
      emit(FailedState(message: phoneError));
      return;
    }

    if (passwordError != null) {
      emit(FailedState(message: passwordError));
      return;
    }

    if (password != confirmPassword) {
      emit(FailedState(message: "كلمتا المرور غير متطابقتين"));
      return;
    }
    emit(LoadingState());

    try {
      Response response = await http.post(
        Uri.parse("http://gpa.runasp.net/api/Account/Register"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json", // ✅ تأكيد إرسال البيانات بصيغة JSON
        },
        body: jsonEncode({
          "firstName": firstName,
          "lastName": lastName,
          "email": email,
          "phone": phone,
          "password": password,
          "confirmPassword": confirmPassword,
          "NID": NID,
        }),
      );
      print("📩 Response received! Status Code: ${response.statusCode}");
      debugPrint("📤 Sending Data: ${jsonEncode({
            "firstName": firstName,
            "lastName": lastName,
            "email": email,
            "phone": phone,
            "password": password,
            "confirmPassword": confirmPassword,
            "NID": NID,
          })}");
      print("📌 Response Body: ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['success'] == true) {
          debugPrint("Response is : $data");
          emit(SuccessState());

          SharedPreferences prefs = await SharedPreferences.getInstance();
          if (data['email'] != null) {
            prefs.setString(
                'email', data['email']); // أو أي حقل يمثل اسم المستخدم
          }
        }
        else {
          final String errorMessage = data['message'] ?? 'حدث خطأ ما';

          if (errorMessage.contains('email') && errorMessage.contains('already')) {
            emit(FailedState(message: "البريد الإلكتروني مستخدم بالفعل"));
          } else {
            emit(FailedState(message: errorMessage));
          }

          debugPrint("📌 Full Response: ${response.body}");
        }
      }
    } catch (e) {
      debugPrint("🔥 Failed to Register: $e");
      if (e is http.Response) {
        debugPrint("📌 Server Response: ${e.body}");
      }
      emit(FailedState(message: "Error: ${e.toString()}"));
    }
  }

  //Login http
  Future<void> Login({
    required String userName,
    required String password,
  }) async {
    emit(LoadingState());

    try {
      // ✅ Trim and remove all spaces from inputs
      final cleanedUserName = userName.replaceAll(' ', ''); // Remove ALL spaces
      final cleanedPassword = password.replaceAll(' ', ''); // Remove ALL spaces

      // Validate cleaned inputs (optional)
      if (cleanedUserName.isEmpty || cleanedPassword.isEmpty) {
        emit(FailedState(message: "اسم المستخدم وكلمة المرور مطلوبان"));
        return;
      }

      // Make API request with cleaned data
      final response = await http.post(
        Uri.parse("http://gpa.runasp.net/api/Account/Login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "userName": cleanedUserName, // Send cleaned username
          "password": cleanedPassword, // Send cleaned password
        }),
      );

      // Rest of your existing logic...
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.body.isEmpty) {
        print("⛔ The Server Returned An Empty Response!");
        emit(FailedState(message: "الخادم لم يُرجع أي بيانات"));
        return;
      }

      var data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        print(" ⚠️ JSON Conversion Failed : $e");
        emit(FailedState(
            message: "An Error Occurred While Processing The Data"));
        return;
      }

      if (data == null || data.isEmpty) {
        print("⛔ البيانات المسترجعة غير صالحة!");
        emit(FailedState(message: "استجابة غير متوقعة من الخادم"));
        return;
      }

      if (!data.containsKey('isAuthenticated') ||
          !data.containsKey('message')) {
        print("⚠️ الرد لا يحتوي على المفاتيح المطلوبة!");
        emit(FailedState(message: "المصادقة فشلت: بيانات غير مكتملة"));
        return;
      }

      bool isAuthenticated = data['isAuthenticated'] ?? false;
      String message = data['message'] ?? "Unknown Error ";
      String token = data['token'] ?? "";

      if (!isAuthenticated || token.isEmpty) {
        print("❌ Login Failed : $message");
        emit(FailedState(message: message));
        return;
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString(
          'userName', data['userName']);
      await prefs.setString('token', token);
      print("🔐 Token Stored Successfully!");

      print(" ✅ Login Successful ! Token : $token");
      emit(LoginSuccessState(message: token));
    } catch (e) {
      print(" ❌ Error While Logging In:  $e");
      emit(FailedState(message: "حدث خطأ غير متوقع، حاول مرة أخرى"));
    }
  }
  //SendOTP
  Future<void> Sendotp({required String Email}) async {
    // Emit loading state
    emit(LoadingState());
    // Validate input
    if (Email.isEmpty) {
      emit(FailedState(message: "Enter the Email"));
      return;
    }
    try {
      // Make API request
      final url =
          Uri.parse("http://gpa.runasp.net/api/Account/SendOtp?Email=$Email");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // Print response for debugging
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      // Decode response
      final responseBody = jsonDecode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        // Emit success state
        if (responseBody['success'] == true) {
          print('OTP sent successfully');
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('email', Email);
          emit(SuccessState());
        } else {
          print('Failed to send OTP: ${response.statusCode}');
          // Emit failed state with error message
          emit(FailedState(message: responseBody['message']));
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      print("Error: $e");
      emit(FailedState(message: "حدث خطأ غير متوقع"));
    }
  }

  Future<void> Validateotp({required String otp}) async {
    // Emit loading state
    emit(LoadingState());
    // Validate input
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email == null) {
      emit(FailedState(message: "لم يتم العثور على البريد الإلكتروني"));
      return;
    }

    if (otp.isEmpty) {
      emit(FailedState(message: "Enter the OTP"));
      return;
    }
    try {
      // Make API request
      final url = Uri.parse(
          "http://gpa.runasp.net/api/Account/ValidateOtp?Email=$email&otp=$otp");

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      // Print response for debugging
      debugPrint("Status Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      // Decode response
      final responseBody = jsonDecode(response.body);

      // Check if the request was successful
      if (response.statusCode == 200) {
        final message = responseBody['message'];
        final isSuccess = responseBody['isSuccess'];
        // Emit success state
        if (isSuccess) {
          print('OTP تم التحقق منه بنجاح: $message');
          emit(SuccessState());
        } else {
          print('Failed to send OTP: ${response.statusCode}');
          // Emit failed state with error message
          emit(FailedState(message: responseBody['message']));
        }
      }
    } catch (e) {
      // Handle any unexpected errors
      print("Error: $e");
      emit(FailedState(message: "حدث خطأ غير متوقع"));
    }
  }

  Future<void> resendOtp() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    print('📧 Stored email: $email');

    if (email == null) {
      print('Email not found in shared preferences.');
      return;
    }

    final url = Uri.parse('http://gpa.runasp.net/api/Account/SendOtp?Email=$email');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print('OTP resent to $email');
    } else {
      print('Failed to resend OTP: ${response.body}');
      print('Status code: ${response.statusCode}');
      print('Body: ${response.body}');
    }
  }
  //ForgetPass http
  Future<void> ForgetPassword(
      {required String userName,
      required String email,
      required String newPassword,
      required String confirmNewPassword}) async {
    emit(LoadingState());

    try {
      final cleaneduserName= userName.replaceAll('', '');

      Response response = await http.post(
        Uri.parse("http://gpa.runasp.net/api/Account/ForgetPassword"),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "userName": cleaneduserName,
          "email": email,
          "newPassword": newPassword,
          "confirmNewPassword": confirmNewPassword,
        }),
      );
      print("📩 Response received! Status Code: ${response.statusCode}");
      print("📌 Response Body: ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['isSuccess'] == true) {
          debugPrint("Response is : $data");
          emit(SuccessState());
        } else {
          debugPrint("Response is : $data");
          emit(FailedState(message: data['message']));
        }
      }
    } catch (e) {
      debugPrint("Failed to Register , reason : $e");
      emit(FailedState(message: e.toString()));
    }
  }

  //ChangePass
  Future<void> ChangePass(
      {required String userName,
      required String oldPassword,
      required String newPassword}) async {
    emit(LoadingState());

    try {
      final cleaneduserName= userName.replaceAll('', '');
      Response response = await http.post(
        Uri.parse("http://gpa.runasp.net/api/Account/ResetPassword"),
        headers: {
          "Content-Type":
              "application/json",
        },
        body: jsonEncode({
          "userName":cleaneduserName,
          "oldPassword": oldPassword,
          "newPassword": newPassword,
        }),
      );
      print("📩 Response received! Status Code: ${response.statusCode}");
      print("📌 Response Body: ${response.body}");
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['isSuccess'] == true) {
          debugPrint("Response is : $data");
          emit(SuccessState());
        } else {
          debugPrint("Response is : $data");
          emit(FailedState(message: data['message']));
        }

      }
    } catch (e) {
      debugPrint("Failed to Register , reason : $e");
      emit(FailedState(message: e.toString()));
    }
  }
}
