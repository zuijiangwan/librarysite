import 'dart:convert';
import 'package:http/http.dart' as http;

// 核心函数，负责发送请求
Future<String> request(String username, String action, Map<String, dynamic> parameter) async {
  const url = 'http://127.0.0.1:8000/';
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      "username": username,
      "action": action,
      "parameter": parameter
    }),
  );
  return response.body;
}