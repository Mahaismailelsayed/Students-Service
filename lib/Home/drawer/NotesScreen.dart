import 'package:flutter/material.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/widgets/custom_gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

import '../../core/app_colors.dart';
import '../../core/notesModel.dart';

class NotesScreen extends StatefulWidget {
  static const String RouteName = 'notes_screen';

  const NotesScreen({super.key});

  @override
  _NotesScreenState createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<Note> notes = [];
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }
  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName'); // الحصول على اسم المستخدم المخزن
  }

  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = await _getUsername();
    if (userName == null) {
      print("❌ No username found");
      return;
    }

    final String? notesString = prefs.getString('notes_$userName');
    if (notesString != null) {
      final List<dynamic> notesJson = jsonDecode(notesString);
      setState(() {
        notes = notesJson.map((json) => Note.fromMap(json)).toList();
      });
    } else {
      print("📭 No notes for $userName");
    }
  }

  // حفظ الملاحظات في SharedPreferences
  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = await _getUsername();
    if (userName == null) return;

    final notesJson = notes.map((note) => note.toMap()).toList();
    await prefs.setString('notes_$userName', jsonEncode(notesJson));
  }

  void _showNoteDialog({Note? note, int? index}) {
    if (note != null) {
      titleController.text = note.title;
      contentController.text = note.content;
    } else {
      titleController.clear();
      contentController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(note == null ? 'Add' : 'Edit',style: TextStyle(color: AppColors.primaryColor,fontWeight:FontWeight.w700 ),),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              cursorColor: AppColors.goldColor,
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: AppColors.primaryColor),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.goldColor, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                ),
              ),
            ),
            SizedBox(height: 10,),
            TextField(
              maxLines: null,
              controller: contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: AppColors.primaryColor),
                enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: AppColors.goldColor, width: 0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('cancel',
                style: TextStyle(color: AppColors.goldColor)),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                final newNote = Note(
                  title: titleController.text,
                  content: contentController.text,
                );
                setState(() {
                  if (note == null) {
                    notes.add(newNote);
                  } else {
                    notes[index!] = newNote;
                  }
                });
                await _saveNotes();
                Navigator.pop(context);
              }
            },
            child: Text(
              note == null ? 'Add' : 'Edit',
              style: TextStyle(color: AppColors.goldColor),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(
          title: 'Notes',
          gradientColors: [AppColors.primaryColor, AppColors.lightGreenColor],
          onBackPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }),
      body: notes.isEmpty
          ? const Center(child: Text('Notes is Empty',style: TextStyle(color: AppColors.primaryColor,fontWeight:FontWeight.w700,fontSize: 20,fontFamily: 'IMPRISHA' )))
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return ListTile(
                  title: Text(note.title,style: TextStyle(color: AppColors.primaryColor,fontWeight:FontWeight.w700 ,fontSize:20)),
                  subtitle: Text(note.content,style: TextStyle(color: AppColors.primaryColor,fontWeight:FontWeight.w400,fontSize:15 ),maxLines: 1,),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () async {
                      setState(() {
                        notes.removeAt(index);
                      });
                      await _saveNotes();
                    },
                  ),
                  onTap: () => _showNoteDialog(note: note, index: index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteDialog(),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [AppColors.primaryColor, AppColors.lightGreenColor],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Icon(Icons.add, size: 30, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
