class NewsItem {
  final String id;
  final String title;
  final String link;
  final String date;
  final String summary;
  final String imageUrl;

  NewsItem({
    required this.id,
    required this.title,
    required this.link,
    required this.date,
    required this.summary,
    required this.imageUrl,
  });

  factory NewsItem.fromJson(String json) {
    final parts = json.split('|');
    return NewsItem(
      id: parts[0],
      title: parts[1],
      link: parts[2],
      date: parts[3],
      summary: parts[4],
      imageUrl: parts.length > 5 ? parts[5] : '',
    );
  }

  String toJson() {
    return '$id|$title|$link|$date|$summary|$imageUrl';
  }
}
