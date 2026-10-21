import 'package:flutter/material.dart';
import '../models/item_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final Color darkGreen = const Color(0xFF0B301D);
  final Color lightGreen = const Color(0xFF66BB6A);
  final Color textColor = const Color(0xFFE1E8DE);

  String selectedRole = 'User';

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  // Font seperti halaman Login, tetapi agak miring.
  TextStyle registerText({
    double size = 17,
    Color? color,
    FontWeight weight = FontWeight.w600,
  }) {
    return TextStyle(
      fontFamily: 'sans-serif',
      fontSize: size,
      color: color ?? textColor,
      fontWeight: weight,
      fontStyle: FontStyle.italic,
      letterSpacing: 0.5,
    );
  }

  InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: registerText(),
      prefixIcon: Icon(icon, color: textColor, size: 27),
      suffixIcon: suffix,
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: textColor.withValues(alpha: 0.55)),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: lightGreen, width: 2),
      ),
      errorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  void registerAccount() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final usernameExists = registeredUsers.any(
      (user) => user.username.toLowerCase() == username.toLowerCase(),
    );

    if (usernameExists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username sudah digunakan!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    registeredUsers.add(
      UserAccount(
        username: username,
        password: password,
        role: selectedRole,
        approvalStatus: 'Menunggu',
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pendaftaran berhasil. Tunggu persetujuan admin.'),
        backgroundColor: Color(0xFF388E3C),
      ),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkGreen,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D321F), Color(0xFF0B301D), Color(0xFF081F15)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 15),

                    // Ikon pendaftaran
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 100,
                      color: lightGreen,
                    ),

                    const SizedBox(height: 32),

                    // Judul
                    Text(
                      'BUAT AKUN',
                      textAlign: TextAlign.center,
                      style: registerText(
                        size: 35,
                        color: Colors.white,
                        weight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 15),

                    Text(
                      'Daftar untuk menggunakan aplikasi',
                      textAlign: TextAlign.center,
                      style: registerText(
                        size: 17,
                        color: textColor.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      style: registerText(),
                      decoration: inputDecoration(
                        hint: 'Username',
                        icon: Icons.person_outline,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Username wajib diisi';
                        }

                        if (value.trim().length < 3) {
                          return 'Username minimal 3 karakter';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: obscurePassword,
                      style: registerText(),
                      decoration: inputDecoration(
                        hint: 'Password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password wajib diisi';
                        }

                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Konfirmasi password
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: obscureConfirmPassword,
                      style: registerText(),
                      decoration: inputDecoration(
                        hint: 'Konfirmasi Password',
                        icon: Icons.lock_outline,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword = !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: textColor,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Konfirmasi password wajib diisi';
                        }

                        if (value != _passwordController.text) {
                          return 'Password tidak sama';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    // Pilihan role
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      dropdownColor: const Color(0xFF17432B),
                      style: registerText(size: 17, color: Colors.white),
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 28,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Role',
                        labelStyle: registerText(size: 15, color: textColor),
                        prefixIcon: const Icon(
                          Icons.admin_panel_settings_outlined,
                          color: Color(0xFFE1E8DE),
                          size: 27,
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: textColor.withValues(alpha: 0.55),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: lightGreen, width: 2),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'User',
                          child: Text('User / Anggota'),
                        ),
                        DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedRole = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 45),

                    // Tombol daftar
                    SizedBox(
                      height: 66,
                      child: ElevatedButton(
                        onPressed: registerAccount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightGreen,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: Text(
                          'DAFTAR',
                          style: registerText(
                            size: 23,
                            color: Colors.white,
                            weight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // Kembali ke login
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Sudah punya akun? Kembali ke Login',
                          textAlign: TextAlign.center,
                          style: registerText(
                            size: 16,
                            color: const Color(0xFFA5D6A7),
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
