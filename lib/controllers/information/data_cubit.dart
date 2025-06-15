import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
part 'data_state.dart';



class DataCubit extends Cubit<DataState> {


  DataCubit() : super(DataInitial());

  Future<void>fetchAllData()async{
    emit(DataLoading()); // يبدأ تحميل البيانات

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print("🔑token:$token");

      if (token == null) {
        emit(DataError('Token not found'));
        return;
      }

      final response = await http.get(
        Uri.parse('http://gpa.runasp.net/api/Gpa/student-info'),
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
          final userName = data['userName'] ?? 'No user name';
          final email= data['email']??'no email';
        final phoneNumber= data['phoneNumber']??'no phoneNumber';
        final gpa = (data['gpa'] ?? 0.0).toDouble();
        final id= data['id']??'no id';

        emit(DataLoaded(userName: userName,email: email,phoneNumber: phoneNumber,gpa: gpa,id: id));

      } else {
        print("⚠️Failed to load student info. Status code: ${response.statusCode}");
        emit(DataError('فشل تحميل البيانات. كود: ${response.statusCode}'));
      }
    } catch (e) {
      print("❌ Error details:");
      emit(DataError('حدث خطأ أثناء تحميل البيانات.'));
    }
  }

}
