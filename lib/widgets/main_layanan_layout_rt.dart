import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MainLayananLayoutRT extends StatefulWidget {
  final Widget body;
  final String title;
  final VoidCallback? onBack;
  final String? token;

  const MainLayananLayoutRT({
    super.key,
    required this.body,
    required this.title,
    this.onBack,
    this.token,
  });

  @override
  State<MainLayananLayoutRT> createState() => _MainLayananLayoutRTState();
}

class _MainLayananLayoutRTState extends State<MainLayananLayoutRT> {
  String? _userPhoto;

  @override
  void initState() {
    super.initState();
    if (widget.token != null) {
      _loadUserPhoto();
    }
  }

  Future<void> _loadUserPhoto() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:8000/api/profile'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final userData = result['data'];
        if (mounted) {
          setState(() => _userPhoto = userData['photo']);
        }
      }
    } catch (e) {
      print('Error loading photo: $e');
    }
  }

  String _getPhotoUrl(String? photo) {
    if (photo == null || photo.isEmpty) {
      return 'assets/images/avatar.jpg';
    }
    if (photo.startsWith('http')) {
      return photo;
    }
    return 'http://localhost:8000/api/storage/$photo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, secondaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.onBack != null)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: widget.onBack,
                          ),
                        ),
                      const SizedBox(width: 12),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  _userPhoto != null && _userPhoto!.isNotEmpty
                      ? CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: Image.network(
                              _getPhotoUrl(_userPhoto),
                              fit: BoxFit.cover,
                              width: 44,
                              height: 44,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.person, color: primaryColor);
                              },
                            ),
                          ),
                        )
                      : const CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, color: primaryColor, size: 24),
                        ),
                ],
              ),
            ),
            Expanded(child: widget.body),
          ],
        ),
      ),
    );
  }
}