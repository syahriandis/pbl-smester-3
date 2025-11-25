import 'package:flutter/material.dart';
import 'package:login_tes/constants/colors.dart';
import 'package:flutter/foundation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Definisikan map _users dengan data yang benar
  final Map<String, String> _users = {
    'dwiky': 'password123',
    'warga': 'warga123',
    'rtaja': 'apalah123', // Data untuk RT
  };

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final username = _emailController.text
        .trim()
        .toLowerCase(); // Menghapus spasi tambahan
    final password = _passwordController.text;

    // Debugging log untuk memastikan username yang dimasukkan
    debugPrint('Attempting to login with username: $username');
    debugPrint(
      'Users in map: ${_users.keys.toList()}',
    ); // Menampilkan semua username yang ada di map

    // Mengecek apakah username dan password kosong
    if (username.isEmpty || password.isEmpty) {
      _showSnackBar('UserID dan password harus diisi');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simulasi delay untuk memverifikasi
    await Future.delayed(const Duration(milliseconds: 1500));

    // Pastikan widget masih terpasang sebelum melakukan setState atau navigasi
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Mengecek apakah username ada di dalam map _users
    if (_users.containsKey(username)) {
      debugPrint('UserID ditemukan: $username'); // Debugging log

      if (_users[username] == password) {
        debugPrint('Password benar');
        // Arahkan ke halaman RT atau dashboard umum
        if (username == 'rtaja') {
          Navigator.pushReplacementNamed(
            context,
            '/rtDashboard',
          ); // Halaman Dashboard RT
        } else {
          Navigator.pushReplacementNamed(
            context,
            '/dashboard',
          ); // Halaman Dashboard Umum
        }
      } else {
        debugPrint('Password salah');
        _showSnackBar('Password salah!');
      }
    } else {
      debugPrint('UserID tidak ditemukan');
      _showSnackBar('UserID tidak ditemukan!');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Selamat datang,',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'silahkan masukkan userid dan password kamu',
                  style: TextStyle(fontSize: 13, color: greyColor),
                ),
              ),
              const SizedBox(height: 32),

              Image.asset(
                'assets/images/logo.png',
                width: 120,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'LOGIN',
                        style: TextStyle(
                          color: whiteColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'UserID',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.text,
                      decoration: InputDecoration(
                        hintText: 'Masukkan UserID',
                        fillColor: whiteColor,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text(
                      'Password',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        fillColor: whiteColor,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: greyColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    )
                  : ElevatedButton(
                      onPressed: _onLoginPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Masuk',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
