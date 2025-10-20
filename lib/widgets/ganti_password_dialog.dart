import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';


class GantiPasswordDialog extends StatelessWidget {
  const GantiPasswordDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController userIdController = TextEditingController();
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Ganti Password",
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: userIdController,
                decoration: const InputDecoration(
                  labelText: "User ID",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: oldPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Lama",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password Baru",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    // TODO: Tambahkan logika update password di sini
                    Navigator.pop(context);
                  },
                  child: const Text(
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
