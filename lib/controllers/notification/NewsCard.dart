import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradproject/controllers/notification/NewsItem.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/app_colors.dart';

class NewsCard extends StatefulWidget {
  final NewsItem item;

  const NewsCard({super.key, required this.item});

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> {
  bool _isLoading = true;

  void openLink(String url) {
    if (url.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            iconTheme: IconThemeData(color: Colors.white, size: 24.sp),
            backgroundColor: Colors.transparent,
            elevation: 0,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r),
                ),
                gradient: LinearGradient(
                  colors: [AppColors.primaryColor, AppColors.lightGreenColor],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            title: Text(
              'News Details',
              style: TextStyle(
                color: AppColors.whiteColor,
                fontFamily: 'IMPRISHA',
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
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
      onTap: () => openLink(widget.item.link),
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(8.w),
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
                      Icon(
                        Icons.calendar_today,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        widget.item.date,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.item.title,
                    style: TextStyle(
                      color: Color(0xff143109),
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Image container (right side)
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  widget.item.imageUrl.isNotEmpty
                      ? widget.item.imageUrl
                      : 'https://science.asu.edu.eg/storage//Uploads/2021/Nov/app/YIyDxLvs61GeHV6M.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.image,
                        size: 40.sp,
                        color: Colors.grey,
                      ),
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