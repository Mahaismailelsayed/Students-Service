import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:gradproject/Home/home_screen.dart';
import 'package:gradproject/widgets/custom_gradient_appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
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
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    // Initialize timezone
    tz.initializeTimeZones();
    print('Emulator timezone: ${tz.local.name}'); // Debug print

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _scheduleNotification(Note note, int id) async {
    if (note.reminderTime == null || note.reminderTime!.isBefore(DateTime.now())) {
      return;
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      'note_reminder_channel',
      'Note Reminders',
      channelDescription: 'Notifications for note reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(),
    );

    // Use the emulator's local timezone
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      note.title,
      note.content,
      tz.TZDateTime.from(note.reminderTime!, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: note.title,
    );
    print('Scheduled notification for ${note.title} at ${note.reminderTime} in ${tz.local.name}');
  }

  Future<String?> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
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
      print('Loaded notes: $notes');
    } else {
      print("📭 No notes for $userName");
    }
  }

  Future<void> _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = await _getUsername();
    if (userName == null) return;

    final notesJson = notes.map((note) => note.toMap()).toList();
    await prefs.setString('notes_$userName', jsonEncode(notesJson));
    print('Saved notes: $notesJson');
  }

  void _showNoteDialog({Note? note, int? index}) {
    DateTime? selectedReminderTime = note?.reminderTime;

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
        title: Text(
          note == null ? 'Add' : 'Edit',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                cursorColor: AppColors.goldColor,
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                maxLines: null,
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  labelStyle: TextStyle(color: AppColors.primaryColor),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.goldColor, width: 0),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedReminderTime == null
                        ? 'No Reminder'
                        : 'Reminder: ${selectedReminderTime.toString().substring(0, 16)}',
                    style: const TextStyle(color: AppColors.primaryColor),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: AppColors.goldColor),
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        final TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          setDialogState(() {
                            selectedReminderTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                  ),
                ],
              ),
              if (selectedReminderTime != null)
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      selectedReminderTime = null;
                    });
                  },
                  child: const Text(
                    'Clear Reminder',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'cancel',
              style: TextStyle(color: AppColors.goldColor),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                final newNote = Note(
                  title: titleController.text,
                  content: contentController.text,
                  reminderTime: selectedReminderTime,
                );
                setState(() {
                  if (note == null) {
                    notes.add(newNote);
                    _scheduleNotification(newNote, notes.length - 1);
                  } else {
                    notes[index!] = newNote;
                    _scheduleNotification(newNote, index);
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
        },
      ),
      body: notes.isEmpty
          ? const Center(child: Text('Notes is Empty'))
          : ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(
              note.title,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.content,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                ),
                if (note.reminderTime != null)
                  Text(
                    'Reminder: ${note.reminderTime.toString().substring(0, 16)}',
                    style: TextStyle(
                      color: AppColors.goldColor,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
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
                await flutterLocalNotificationsPlugin.cancel(index);
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