import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/controllers/notification/NewsItem.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/app_colors.dart';

class NewsCard extends StatefulWidget {
  final NewsItem item;

  const NewsCard({super.key, required this.item});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  late final WebViewController controller;
  bool _isLoading = true;

  void openLink(String url) {
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            backgroundColor: Colors.transparent,
            elevation: 0,

            flexibleSpace:  Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.lightGreenColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            title: Text('News Details',
                style: TextStyle(
                    color: AppColors.whiteColor,
                    fontFamily: 'IMPRISHA',
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
          ),
          body: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadRequest(Uri.parse(url))
              ..setNavigationDelegate(
                NavigationDelegate(
                  onPageFinished: (String url) {
                    setState(() => _isLoading = false);
                  },
                ),
              ),
          ),
        ),
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return InkWell(

      onTap: () => openLink(widget.item.link), // Double tap for WebView
      child: Container(
        color: Colors.white,
        padding:  EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text content (left side)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Date row
                  Row(
                    children: [
                       Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                       SizedBox(width: 4),
                      Text(
                        widget.item.date,
                        style:  TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 8),
                  Text(
                    widget.item.title,
                    style:  TextStyle(
                      color: Color(0xff143109),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
             SizedBox(width: 12),
            // Image container (right side)
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.item.imageUrl.isNotEmpty
                      ? widget.item.imageUrl
                      : 'https://science.asu.edu.eg/storage//uploads/2021/Nov/app/YIyDxLvs61GeHV6M.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child:  Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}