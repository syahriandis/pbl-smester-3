import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    // Deteksi platform
    if (kIsWeb) {
      return "http://localhost:8000";
    } else {
      return "http://127.0.0.1:8000";
    }
  }

  static Future<http.Response> getRequest(String endpoint, String token) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }

  static Future<http.Response> postRequest(String endpoint, Map<String, dynamic> body, String token) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.post(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> putRequest(String endpoint, Map<String, dynamic> body, String token) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.put(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteRequest(String endpoint, String token) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );
  }
}