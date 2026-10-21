// ======================================================
// MODEL USER
// ======================================================

class UserAccount {
  final String username;
  final String password;
  final String role;

  // Menunggu, Disetujui, Ditolak
  String approvalStatus;

  UserAccount({
    required this.username,
    required this.password,
    required this.role,
    this.approvalStatus = 'Menunggu',
  });
}

// ======================================================
// DATA AKUN
// ======================================================

List<UserAccount> registeredUsers = [
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
}

// ======================================================
// DATA TASK DAN INVENTARIS
// ======================================================

List<ItemModel> globalItemList = [];
