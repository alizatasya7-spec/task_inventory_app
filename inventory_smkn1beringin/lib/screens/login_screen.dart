import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'register_screen.dart';
import 'user_dashboard.dart';
import 'admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  // ====================================================
  // PENGATURAN SERVER WI-FI
  // ====================================================

  Future<void> _showServerSettings() async {
    await loadAccountServerAddress();

    if (!mounted) return;

    final serverController = TextEditingController(
      text: accountServerAddressForDisplay,
    );

    String? testMessage;
    bool? testSuccess;
    bool isTesting = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFE8EBE2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              title: const Row(
                children: [
                  Icon(Icons.wifi, color: Color(0xFF1B5E20), size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Pengaturan Server Wi-Fi',
                      style: TextStyle(
                        color: Color(0xFF202820),
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Masukkan alamat IP laptop yang menjalankan server (contoh: 192.168.0.236:4545):',
                      style: TextStyle(color: Color(0xFF303830), fontSize: 15),
                    ),

                    const SizedBox(height: 18),

                    // KOLOM ALAMAT SERVER
                    TextField(
                      controller: serverController,
                      keyboardType: TextInputType.url,
                      cursorColor: const Color(0xFF1B5E20),
                      style: const TextStyle(
                        color: Color(0xFF202820),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Alamat Server & Port',
                        labelStyle: const TextStyle(color: Color(0xFF526052)),
                        floatingLabelStyle: const TextStyle(
                          color: Color(0xFF1B5E20),
                        ),
                        prefixIcon: const Icon(
                          Icons.dns,
                          color: Color(0xFF1B5E20),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFF9BA89A),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFF1B5E20),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Laptop: gunakan 127.0.0.1:4545\n'
                      'HP: gunakan IP Wi-Fi laptop.',
                      style: TextStyle(color: Color(0xFF626A61), fontSize: 13),
                    ),

                    // HASIL TES KONEKSI
                    if (testMessage != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            testSuccess == true
                                ? Icons.check_circle
                                : Icons.error,
                            color: testSuccess == true
                                ? Colors.green.shade800
                                : Colors.red.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              testMessage!,
                              style: TextStyle(
                                color: testSuccess == true
                                    ? Colors.green.shade800
                                    : Colors.red.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 18),

              actions: [
                // TOMBOL BATAL
                TextButton(
                  onPressed: isTesting
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: const Text('Batal'),
                ),

                // TOMBOL TES KONEKSI
                OutlinedButton.icon(
                  onPressed: isTesting
                      ? null
                      : () async {
                          setDialogState(() {
                            isTesting = true;
                            testMessage = null;
                            testSuccess = null;
                          });

                          try {
                            await testAccountServerConnection(
                              serverController.text,
                            );

                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isTesting = false;
                              testSuccess = true;
                              testMessage = 'Server aktif! Koneksi berhasil.';
                            });
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              isTesting = false;
                              testSuccess = false;
                              testMessage = 'Koneksi gagal: $e';
                            });
                          }
                        },
                  icon: isTesting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.wifi_find),
                  label: const Text('Tes Koneksi'),
                ),

                // TOMBOL SIMPAN
                ElevatedButton(
                  onPressed: isTesting
                      ? null
                      : () async {
                          try {
                            await saveAccountServerAddress(
                              serverController.text,
                            );

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Alamat server berhasil disimpan.',
                                ),
                                backgroundColor: Color(0xFF2E7D32),
                              ),
                            );
                          } catch (e) {
                            if (!dialogContext.mounted) return;

                            setDialogState(() {
                              testSuccess = false;
                              testMessage = e.toString();
                            });
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 13,
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ],
            );
          },
        );
      },
    );

    serverController.dispose();
  }

  // ====================================================
  // LOGIN DAN PEMERIKSAAN PERSETUJUAN
  // ====================================================

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    final usernameInput = usernameController.text.trim();
    final passwordInput = passwordController.text.trim();

    try {
      await loadRegisteredUsers();
      await loadItems();

      if (!mounted) return;

      final userIndex = registeredUsers.indexWhere(
        (user) => user.username.toLowerCase() == usernameInput.toLowerCase(),
      );

      if (userIndex == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau password salah!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      final user = registeredUsers[userIndex];

      if (user.password != passwordInput) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username atau password salah!'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (user.approvalStatus == 'Menunggu') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Akun kamu masih menunggu persetujuan Admin.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (user.approvalStatus == 'Ditolak') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pendaftaran akun kamu ditolak oleh Admin.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      // MASUK SEBAGAI ADMIN
      if (user.role == 'Admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboardScreen(user: user),
          ),
        );
      }
      // MASUK SEBAGAI USER
      else if (user.role == 'User') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => UserDashboardScreen(user: user),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Role akun tidak valid!'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membaca data aplikasi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ====================================================
  // DISPOSE
  // ====================================================

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ====================================================
  // TAMPILAN LOGIN
  // ====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B2E1A), Color(0xFF123D24), Color(0xFF0B1F13)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // TOMBOL SERVER WI-FI
                      Align(
                        alignment: Alignment.centerRight,
                        child: OutlinedButton.icon(
                          onPressed: isLoading ? null : _showServerSettings,
                          icon: const Icon(Icons.wifi),
                          label: const Text(
                            'Server Wi-Fi',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withValues(alpha: 0.55),
                            ),
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.08,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // LOGO LOGIN
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF66BB6A),
                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: Image.asset(
                            'assets/logosmk.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.school,
                                size: 65,
                                color: Color(0xFF66BB6A),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        'SMK NEGERI 1 BERINGIN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        'TASK & INVENTORY',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Text(
                        'MANAGER',
                        style: TextStyle(
                          fontSize: 22,
                          color: Color(0xFF66BB6A),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Login untuk melanjutkan',
                        style: TextStyle(color: Colors.white60),
                      ),

                      const SizedBox(height: 35),

                      // USERNAME
                      TextFormField(
                        controller: usernameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          hintText: 'Masukkan username kamu',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Username wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD
                      TextFormField(
                        controller: passwordController,
                        obscureText: hidePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(
                              hidePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 25),

                      // TOMBOL LOGIN
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              disabledBackgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 23,
                                    height: 23,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // REGISTRASI
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum memiliki akun? ',
                            style: TextStyle(color: Colors.white70),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Registrasi',
                              style: TextStyle(
                                color: Color(0xFF66BB6A),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'SMKN 1 BERINGIN',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
