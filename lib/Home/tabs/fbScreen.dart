import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FbScreen extends StatefulWidget {
  const FbScreen({super.key});
  static const RouteName = 'fbScreen';

  @override
  State<FbScreen> createState() => _FbScreenState();
}

class _FbScreenState extends State<FbScreen> {
  late final WebViewController controller;
  bool _isLoading = true;
  bool _isConnected = true; // Track internet connection status
  late Stream<List<ConnectivityResult>> _connectivityStream;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.facebook.com/share/18SEaTKGmB/')) // Changed URL
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => _isLoading = true),
          onPageFinished: (url) => setState(() => _isLoading = false),
          onNavigationRequest: (navigation) async {
            if (!navigation.url.startsWith('http')) {
              if (await canLaunchUrl(Uri.parse(navigation.url))) {
                await launchUrl(Uri.parse(navigation.url));
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
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