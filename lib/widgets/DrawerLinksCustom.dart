import 'package:flutter/material.dart';
import 'package:gradproject/widgets/custom_gradient_appbar.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Home/home_screen.dart';
import '../../core/app_colors.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DrawerLinksCustom extends StatefulWidget {
  final String screenTitle;
  final String url;
  const DrawerLinksCustom({required this.screenTitle,required this.url});
  static const routeName = 'umsScreen';

  @override
  State<DrawerLinksCustom> createState() => _DrawerLinksCustomState();
}

class _DrawerLinksCustomState extends State<DrawerLinksCustom> {
  late final WebViewController controller;
  bool _isLoading = true; // Track loading status
  bool _isConnected = true; // Track internet connection status
  late Stream<List<ConnectivityResult>> _connectivityStream; // Updated type

  @override
  void initState() {
    super.initState();

    // Initialize WebView
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url))  // Use the passed URL
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => _isLoading = false);
          },
        ),
      );
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomGradientAppBar(title:  widget.screenTitle,
          gradientColors: [AppColors.primaryColor, AppColors.lightGreenColor],
          onBackPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }),
      body: Stack(
        children: [
          if (_isConnected) ...[
            WebViewWidget(controller: controller), // Show WebView if connected
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(), // Show loading indicator
              ),
          ] else ...[
            // Show no internet message if not connected
            const Center(
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
          ],
        ],
      ),
    );
  }
}