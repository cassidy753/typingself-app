import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  // In production, these go through Firebase Cloud Messaging
  // For MVP, we use local notifications as fallback

  Future<void> registerDeviceToken(String token) async {
    // TODO: Send FCM token to Supabase
    // await supabase.from('user_devices').upsert({...});
  }

  Future<void> scheduleDailyQuote() async {
    // Android: use flutter_local_notifications to schedule
    // iOS: use FCM + APNs
    // MVP: triggered by app open (poll for new day)
  }
}

class DeepSeekService {
  final String _baseUrl = 'https://openrouter.ai/api/v1/chat/completions';
  final String _apiKey; // from env

  DeepSeekService(this._apiKey);

  Future<String> generateQuote(String prompt) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'model': 'deepseek/deepseek-chat',
        'messages': [
          {
            'role': 'system',
            'content': '你係「型得你」App 嘅語句生成器。用廣東話作一句關於自我認識、心理健康、鼓勵嘅語句。要溫暖、真誠、有深度。唔好太宗教。一句起兩句止。',
          },
          {
            'role': 'user',
            'content': prompt,
          }
        ],
        'max_tokens': 100,
        'temperature': 0.8,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['choices'][0]['message']['content'] as String;
    }
    throw Exception('DeepSeek API error: ${response.statusCode}');
  }

  Future<String> generateMovieQuote() async {
    return generateQuote('作一句電影金句風格嘅鼓勵語句，可以好似「怯？你就輸一世」咁。唔需要用真實電影名。');
  }

  Future<String> generateEncouragement() async {
    return generateQuote('作一句溫暖嘅鼓勵語句，俾覺得迷惘嘅香港年輕人。');
  }

  Future<String> generateInspirational() async {
    return generateQuote('作一句關於自我認識嘅 inspiring 語句。');
  }
}
