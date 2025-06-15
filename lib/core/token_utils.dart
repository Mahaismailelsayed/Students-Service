import 'dart:convert';

class TokenUtils {
  static bool isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final Map<String, dynamic> payloadMap = json.decode(payload);

      if (!payloadMap.containsKey('exp')) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
      final now = DateTime.now();

      return now.isAfter(expiry);
    } catch (e) {
      print("🚫 Error decoding token: $e");
      return true; // لو حصل خطأ، اعتبره منتهي
    }
  }
}
