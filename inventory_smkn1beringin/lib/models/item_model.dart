import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================
// PENGATURAN SERVER WI-FI
// ======================================================

const String defaultAccountServerUrl = 'http://192.168.0.236:4545';

const String serverAddressStorageKey = 'task_inventory_server_address_v1';

const Duration serverTimeout = Duration(seconds: 15);

// Alamat server yang sedang digunakan.
String accountServerBaseUrl = defaultAccountServerUrl;

// Menampilkan alamat tanpa http://
String get accountServerAddressForDisplay {
  return accountServerBaseUrl.replaceFirst(RegExp(r'^https?://'), '');
}

// Memeriksa format alamat server.
String normalizeAccountServerAddress(String address) {
  final input = address.trim();

  if (input.isEmpty) {
    throw const FormatException('Alamat server wajib diisi.');
  }

  final uri = Uri.tryParse(input.contains('://') ? input : 'http://$input');

  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      !uri.hasPort ||
      uri.port < 1 ||
      uri.port > 65535 ||
      (uri.path.isNotEmpty && uri.path != '/') ||
      uri.hasQuery ||
      uri.hasFragment) {
    throw const FormatException(
      'Format alamat tidak valid. Contoh: 192.168.0.236:4545',
    );
  }

  return '${uri.scheme}://${uri.host}:${uri.port}';
}

// Memuat alamat server yang pernah disimpan.
Future<void> loadAccountServerAddress() async {
  final prefs = await SharedPreferences.getInstance();

  final savedAddress = prefs.getString(serverAddressStorageKey);

  if (savedAddress == null || savedAddress.isEmpty) {
    accountServerBaseUrl = defaultAccountServerUrl;
    return;
  }

  try {
    accountServerBaseUrl = normalizeAccountServerAddress(savedAddress);
  } catch (_) {
    accountServerBaseUrl = defaultAccountServerUrl;
  }
}

// Menguji apakah server dapat dihubungi.
Future<void> testAccountServerConnection(String address) async {
  final normalizedAddress = normalizeAccountServerAddress(address);

  final response = await http
      .get(Uri.parse('$normalizedAddress/health'))
      .timeout(serverTimeout);

  if (response.statusCode != 200) {
    throw Exception('Server memberikan respons HTTP ${response.statusCode}.');
  }

  final result = jsonDecode(response.body);

  if (result is! Map || result['status'] != 'success') {
    throw Exception('Server belum memberikan status aktif.');
  }
}

// Menyimpan alamat server ke perangkat.
Future<void> saveAccountServerAddress(String address) async {
  final normalizedAddress = normalizeAccountServerAddress(address);

  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(serverAddressStorageKey, normalizedAddress);

  accountServerBaseUrl = normalizedAddress;
}

// ======================================================
// MODEL USER
// ======================================================

class UserAccount {
  final String username;
  final String password;
  final String role;

  String approvalStatus;

  UserAccount({
    required this.username,
    required this.password,
    required this.role,
    this.approvalStatus = 'Menunggu',
  });

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'role': role,
      'approvalStatus': approvalStatus,
    };
  }

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      role: map['role']?.toString() ?? 'User',
      approvalStatus: map['approvalStatus']?.toString() ?? 'Menunggu',
    );
  }
}

// ======================================================
// DATA AKUN DEFAULT
// ======================================================

List<UserAccount> _defaultAccounts() {
  return [
    UserAccount(
      username: 'user1',
      password: '123456',
      role: 'User',
      approvalStatus: 'Disetujui',
    ),
    UserAccount(
      username: 'admin1',
      password: 'admin123',
      role: 'Admin',
      approvalStatus: 'Disetujui',
    ),
  ];
}

List<UserAccount> registeredUsers = _defaultAccounts();

// ======================================================
// MENGAMBIL AKUN DARI SERVER
// ======================================================

Future<List<UserAccount>> _fetchServerAccounts() async {
  await loadAccountServerAddress();

  final response = await http
      .get(Uri.parse('$accountServerBaseUrl/accounts'))
      .timeout(serverTimeout);

  if (response.statusCode != 200) {
    throw Exception('Server gagal mengambil akun. HTTP ${response.statusCode}');
  }

  final decoded = jsonDecode(response.body);

  if (decoded is! List) {
    throw const FormatException(
      'Format accounts.json harus berupa daftar akun.',
    );
  }

  return decoded
      .whereType<Map>()
      .map((item) => UserAccount.fromMap(Map<String, dynamic>.from(item)))
      .toList();
}

// ======================================================
// MEMUAT AKUN
// ======================================================

Future<void> loadRegisteredUsers() async {
  final serverUsers = await _fetchServerAccounts();

  registeredUsers = _defaultAccounts();

  for (final serverUser in serverUsers) {
    final exists = registeredUsers.any(
      (user) =>
          user.username.toLowerCase() == serverUser.username.toLowerCase(),
    );

    if (!exists) {
      registeredUsers.add(serverUser);
    }
  }
}

// ======================================================
// MENYIMPAN / MENYINKRONKAN AKUN KE SERVER
// ======================================================

Future<void> saveRegisteredUsers() async {
  final serverUsers = await _fetchServerAccounts();

  for (final user in registeredUsers) {
    final isDefaultAccount = [
      'user1',
      'admin1',
    ].contains(user.username.toLowerCase());

    if (isDefaultAccount) continue;

    final serverIndex = serverUsers.indexWhere(
      (item) => item.username.toLowerCase() == user.username.toLowerCase(),
    );

    if (serverIndex == -1) {
      final response = await http
          .post(
            Uri.parse('$accountServerBaseUrl/accounts'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': user.username,
              'password': user.password,
              'role': user.role,
            }),
          )
          .timeout(serverTimeout);

      if (response.statusCode == 409) {
        throw Exception('Username sudah digunakan di server.');
      }

      if (response.statusCode != 200) {
        throw Exception('Gagal menyimpan akun ke server: ${response.body}');
      }

      serverUsers.add(user);
    } else {
      final serverUser = serverUsers[serverIndex];

      if (serverUser.approvalStatus != user.approvalStatus) {
        final response = await http
            .put(
              Uri.parse('$accountServerBaseUrl/accounts'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'username': user.username,
                'approvalStatus': user.approvalStatus,
              }),
            )
            .timeout(serverTimeout);

        if (response.statusCode != 200) {
          throw Exception(
            'Gagal memperbarui persetujuan akun: ${response.body}',
          );
        }

        serverUsers[serverIndex].approvalStatus = user.approvalStatus;
      }
    }
  }
}

// ======================================================
// MODEL TASK DAN INVENTARIS
// ======================================================

class ItemModel {
  final String id;
  final String title;
  final String category;
  String status;
  final String description;
  final String createdBy;

  ItemModel({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.description,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'status': status,
      'description': description,
      'createdBy': createdBy,
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map) {
    return ItemModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      status: map['status']?.toString() ?? 'Pending',
      description: map['description']?.toString() ?? '',
      createdBy: map['createdBy']?.toString() ?? '',
    );
  }
}

// ======================================================
// PENYIMPANAN TASK DAN INVENTARIS
// ======================================================

const String itemStorageKey = 'task_inventory_items_v1';

List<ItemModel> globalItemList = [];

Future<void> loadItems() async {
  final prefs = await SharedPreferences.getInstance();
  final savedData = prefs.getString(itemStorageKey);

  if (savedData == null) {
    globalItemList = [];
    return;
  }

  try {
    final List<dynamic> decoded = jsonDecode(savedData);

    globalItemList = decoded
        .whereType<Map>()
        .map((item) => ItemModel.fromMap(Map<String, dynamic>.from(item)))
        .toList();
  } catch (e) {
    print('Gagal membaca data Task dan Inventaris: $e');
    globalItemList = [];
  }
}

Future<void> saveItems() async {
  final prefs = await SharedPreferences.getInstance();

  final encodedData = jsonEncode(
    globalItemList.map((item) => item.toMap()).toList(),
  );

  await prefs.setString(itemStorageKey, encodedData);
}
