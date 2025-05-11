import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import '../../controllers/notification/NewsCard.dart';
import '../../controllers/notification/NewsItem.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class notificationsScreen extends StatefulWidget {
  const notificationsScreen({super.key});
  static const RouteName = 'notificationScreen';

  @override
  State<notificationsScreen> createState() => _notificationsScreenState();
}

class _notificationsScreenState extends State<notificationsScreen> {
  List<NewsItem> newsItems = [];
  bool isLoading = true;
  bool hasNewNotifications = false;
  bool _isConnected = true; // Track internet connection status
  late Stream<List<ConnectivityResult>> _connectivityStream; // Updated type


  final FlutterLocalNotificationsPlugin notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadNews();
    _connectivityStream = Connectivity().onConnectivityChanged; // Correct stream type
    _checkConnectivity(); // Check initial connectivity
    _connectivityStream.listen((List<ConnectivityResult> results) {
      setState(() {
        // Check if any connection is active (wifi or mobile)
        _isConnected = results.contains(ConnectivityResult.wifi) ||
            results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.ethernet);
      });
    });
  }

  // Check initial connectivity status
  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      // Check if any connection is active
      _isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile) ||
          result.contains(ConnectivityResult.ethernet);
    });
  }
  void _removeNews() {
    setState(() {
      newsItems.removeRange(0, newsItems.length);
    });
  }

  Future<void> _loadNews() async {
    setState(() => isLoading = true);

    try {
      // Fetch news from website
      final newItems = await _fetchNews();

      // Load saved news from local storage
      final prefs = await SharedPreferences.getInstance();
      final savedItems = _loadSavedNews(prefs);

      // Check for new items
      if (savedItems.isNotEmpty && newItems.isNotEmpty) {
        final latestSavedId = savedItems.first.id;
        final newItemIds = newItems.map((item) => item.id).toList();

        if (!newItemIds.contains(latestSavedId)) {
          hasNewNotifications = true;
          _showNotification('ASU Science News', 'New articles available!');
        }
      }

      // Save new items and update UI
      _saveNews(prefs, newItems);
      setState(() {
        newsItems = newItems;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading news: $e')),
      );
    }
  }

  Future<List<NewsItem>> _fetchNews() async {
    final response = await http.get(Uri.parse('https://science.asu.edu.eg/ar/news'));
    if (response.statusCode != 200) {
      throw Exception('Failed to load news');
    }

    final document = html_parser.parse(response.body);
    final newsElements = document.querySelectorAll('.w-full.lg\\:w-48\\%'); // Selects each news card

    return newsElements.map((element) {
      // Extract title
      final titleElement = element.querySelector('h4 a');
      final title = titleElement?.text.trim() ?? 'No title';

      // Extract link
      final link = titleElement?.attributes['href'] ?? '';

      // Extract date
      final dateElement = element.querySelector('.date');
      final dateText = dateElement?.text.trim() ?? '';

      // Extract summary (using the same text as title since no separate summary exists)
      final summary = title;

      // Extract image URL
      final imageElement = element.querySelector('img');
      final imageUrl = imageElement?.attributes['src'] ?? '';

      // Generate ID from title and date
      final id = '${title.hashCode}_${dateText.hashCode}';

      return NewsItem(
        id: id,
        title: title,
        link: link,
        date: dateText,
        summary: summary,
        imageUrl: imageUrl,
      );
    }).toList();
  }
  List<NewsItem> _loadSavedNews(SharedPreferences prefs) {
    final newsJson = prefs.getStringList('saved_news') ?? [];
    return newsJson.map((json) => NewsItem.fromJson(json)).toList();
  }

  Future<void> _saveNews(SharedPreferences prefs, List<NewsItem> items) async {
    final newsJson = items.map((item) => item.toJson()).toList();
    await prefs.setStringList('saved_news', newsJson);
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'news_channel',
      'News Updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const platformDetails = NotificationDetails(android: androidDetails);

    await notificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,

        actions: [
          if (hasNewNotifications)
            const Icon(Icons.notifications_active, color: Colors.yellow),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNews,
          ),
           SizedBox(width: 260),
          IconButton(
            color: Colors.red,
            icon: const Icon(Icons.delete),
            onPressed: _removeNews,
          )
        ],
      ),
      body: _isConnected ?isLoading
          ? const Center(child: CircularProgressIndicator())
          : newsItems.isEmpty
          ? const Center(child: Text('No news available'))
          : ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return NewsCard(item: item);
        },
      ): const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: 50,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'No Internet Connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please check your connection and try again.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
