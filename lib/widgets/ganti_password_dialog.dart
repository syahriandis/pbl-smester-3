import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditPasswordDialog extends StatefulWidget {
  const EditPasswordDialog({super.key});

  @override
  State<EditPasswordDialog> createState() => _EditPasswordDialogState();
}

class _EditPasswordDialogState extends State<EditPasswordDialog> {
  final TextEditingController oldPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  bool isLoading = false;
  bool oldVisible = false;
  bool newVisible = false;
  bool confirmVisible = false;
  String? errorMessage;

  bool _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasMinLength = password.length >= 6;
    return hasUppercase && hasNumber && hasMinLength;
  }

  Future<void> updatePassword() async {
    final newPass = newPassController.text;
    final confirmPass = confirmPassController.text;

    if (newPass != confirmPass) {
      setState(() => errorMessage = "Konfirmasi password tidak cocok");
      return;
    }

    if (!_validatePassword(newPass)) {
      setState(() => errorMessage =
          "Password harus minimal 6 karakter, mengandung huruf besar dan angka");
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.put(
        Uri.parse("http://127.0.0.1:8000/api/profile/password"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "old_password": oldPassController.text,
          "new_password": newPass,
        }),
      );

      print("Token: $token");
      print("Status code: ${response.statusCode}");
      print("Body: ${response.body}");

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password berhasil diubah!")),
        );
      } else {
        setState(() => errorMessage = "Gagal: ${response.body}");
      }
    } catch (e, stack) {
      setState(() {
        isLoading = false;
        errorMessage = "Error: $e";
      });
      print("Error: $e");
      print("Stack: $stack");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Edit Password",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),

              if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),

              const SizedBox(height: 12),

              // PASSWORD LAMA
              TextField(
                controller: oldPassController,
                obscureText: !oldVisible,
                decoration: InputDecoration(
                  labelText: "Password Lama",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      oldVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => oldVisible = !oldVisible);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // PASSWORD BARU
              TextField(
                controller: newPassController,
                obscureText: !newVisible,
                decoration: InputDecoration(
                  labelText: "Password Baru",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      newVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => newVisible = !newVisible);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // KONFIRMASI PASSWORD BARU
              TextField(
                controller: confirmPassController,
                obscureText: !confirmVisible,
                decoration: InputDecoration(
                  labelText: "Konfirmasi Password Baru",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      confirmVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => confirmVisible = !confirmVisible);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // TOMBOL KONFIRMASI
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: isLoading ? null : updatePassword,
                  child: isLoading
                      ? const CircularProgressIndicator(color: whiteColor)
                      : const Text(
                          "Konfirmasi",
                          style: TextStyle(color: whiteColor),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}