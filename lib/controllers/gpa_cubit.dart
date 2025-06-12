import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

part 'gpa_state.dart';

const String _baseUrl = "http://gpa.runasp.net/api/Gpa";
const String _calculateUrl = "$_baseUrl/calculateGPA";
const String _updateUrl = "$_baseUrl/update";

class GpaCubit extends Cubit<GpaState> {
  GpaCubit() : super(GpaInitial());

  Future<void> saveGpa(double cumulativeGpa, double totalAllCredits) async {
    emit(GpaLoading());
    final prefs = await SharedPreferences.getInstance();
    String? userName = prefs.getString('userName');
    if (userName == null) {
      emit(GpaError('User is not logged in.'));
      return;
    }

    try {
      if (cumulativeGpa < 0 || totalAllCredits < 0) {
        emit(GpaError('Invalid GPA or credit hours.'));
        return;
      }

      await prefs.setDouble('$userName-savedCumulativeGpa', cumulativeGpa);
      await prefs.setDouble('$userName-savedCreditHours', totalAllCredits);

      double savedGpa = prefs.getDouble('$userName-savedCumulativeGpa') ?? 0.0;
      double savedHours = prefs.getDouble('$userName-savedCreditHours') ?? 0.0;
      print("Saved GPA: $savedGpa, Saved Credit Hours: $savedHours");

      await updateGpa(cumulativeGpa);

      emit(GpaLoaded(prevGpa: savedGpa, prevHours: savedHours));
    } catch (e) {
      emit(GpaError('Failed to save GPA: $e'));
    }
  }

  Future<void> loadSavedGpaData() async {
    emit(GpaLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      print("All SharedPreferences keys: $keys");
      String? userName = prefs.getString('userName');
      print("Fetched userName: $userName");

      if (userName != null) {
        double prevGpa = prefs.getDouble('$userName-savedCumulativeGpa') ?? 0.0;
        double prevHours = prefs.getDouble('$userName-savedCreditHours') ?? 0.0;
        print("Loaded GPA: $prevGpa, Loaded Credit Hours: $prevHours");

        if (prevGpa < 0 || prevHours < 0) {
          emit(GpaError('Invalid saved data detected.'));
          return;
        }

        emit(GpaLoaded(prevGpa: prevGpa, prevHours: prevHours));
      } else {
        emit(GpaError('User not logged in'));
      }
    } catch (e) {
      emit(GpaError('Failed to load saved data: $e'));
    }
  }

  Future<void> calculateGpa(
      List<Map<String, dynamic>> courses,
      double prevGpa,
      double prevHours,
      ) async {
    print("calculateGpa CALLED");
    print("Courses: $courses");
    print("Previous GPA: $prevGpa, Previous Hours: $prevHours");

    emit(GpaLoading());

    if (!validateCourseInputs(courses, ['A', 'A-', 'B+', 'B', 'C+', 'C', 'D', 'F']))
      return;

    if (courses.isEmpty) {
      emit(GpaError('Please enter at least one valid course.'));
      return;
    }

    double totalCredits = courses.fold(0.0, (sum, course) => sum + (course['creditHours']?.toDouble() ?? 0.0));
    if (totalCredits == 0) {
      emit(GpaError('Total credit hours cannot be zero.'));
      return;
    }

    final url = Uri.parse(_calculateUrl);

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(courses),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        double semesterGpa = result.toDouble();

        double currentQualityPoints = semesterGpa * totalCredits;
        double previousQualityPoints = prevGpa * prevHours;
        double cumulativeQualityPoints = currentQualityPoints + previousQualityPoints;
        double totalAllCredits = totalCredits + prevHours;
        double cumulativeGpa = totalAllCredits > 0 ? cumulativeQualityPoints / totalAllCredits : 0;


        // Emit the calculated state with the new values
        emit(GpaCalculated(
          semesterGpa: semesterGpa,
          cumulativeGpa: cumulativeGpa,
          totalCredits: totalAllCredits,
        ));
      } else {
        emit(GpaError('Failed to calculate GPA: ${response.body}'));
      }
    } catch (e) {
      emit(GpaError('Could not connect to server: $e'));
    }
  }

  Future<void> updateGpa(double newGpa) async {
    final url = Uri.parse(_updateUrl);
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      emit(GpaError('User must be logged in to update GPA.'));
      return;
    }

    try {
      print('Sending GPA Update...');
      print('Token: $token');
      print('GPA: $newGpa');

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"newGpa": newGpa}),
      );

      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        emit(GpaUpdated());
      } else {
        emit(GpaError('Failed to update GPA: ${response.body}'));
      }
    } catch (e) {
      emit(GpaError('Failed to connect to server: $e'));
    }
  }

  bool validateCourseInputs(List<Map<String, dynamic>> courses, List<String> validGrades) {
    for (var course in courses) {
      print("Validating course: $course");

      if (course['grade'] == null || !validGrades.contains(course['grade'])) {
        emit(GpaError('Invalid grade in one or more courses.'));
        return false;
      }

      if (course['creditHours'] == null || course['creditHours'] <= 0) {
        emit(GpaError('Invalid credit hours in one or more courses.'));
        return false;
      }
    }
    return true;
  }
}