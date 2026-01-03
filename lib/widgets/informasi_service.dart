import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<List<Map<String, dynamic>>> fetchInformasi() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  final response = await http.get(
    Uri.parse('http://localhost:8000/api/informasi'),
    headers: {
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'] as List;
    return data.map((e) => Map<String, dynamic>.from(e)).toList();
  } else {
    throw Exception('Gagal memuat informasi (${response.statusCode})');
  }
}