import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const AdminDashboardScreen({super.key, required this.user});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String selectedCategory = 'Semua';

  // HANYA ADMIN1 YANG MEMILIKI MENU PERSETUJUAN AKUN
  bool get isSuperAdmin =>
      widget.user.username.trim().toLowerCase() == 'admin1';

  // ====================================================
  // FILTER ITEM
  // ====================================================

  List<ItemModel> get filteredItems {
    if (selectedCategory == 'Semua') {
      return globalItemList;
    }

    return globalItemList
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  // ====================================================
  // DAFTAR AKUN YANG MENUNGGU PERSETUJUAN
  // ====================================================

  List<UserAccount> get pendingUsers {
    return registeredUsers
        .where((user) => user.approvalStatus == 'Menunggu')
        .toList();
  }

  // ====================================================
  // TAMPILKAN PERSETUJUAN AKUN - KHUSUS ADMIN1
  // ====================================================

  void _showPendingAccounts() {
    if (!isSuperAdmin) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final users = pendingUsers;

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Color(0xFF66BB6A)),
                  SizedBox(width: 10),
                  Expanded(child: Text('Persetujuan Akun')),
                ],
              ),
              content: SizedBox(
                width: 450,
                child: users.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              size: 55,
                              color: Color(0xFF66BB6A),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Tidak ada akun yang menunggu persetujuan.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : SizedBox(
                        height: 300,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final account = users[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFF1B5E20),
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                account.username,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const Text(
                                                'Role: User',
                                                style: TextStyle(
                                                  color: Colors.white60,
                                                ),
                                              ),
                                              const Text(
                                                'Status: Menunggu',
                                                style: TextStyle(
                                                  color: Colors.orange,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              if (!isSuperAdmin) return;

                                              setState(() {
                                                account.approvalStatus =
                                                    'Disetujui';
                                              });

                                              setDialogState(() {});

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Akun ${account.username} disetujui.',
                                                  ),
                                                  backgroundColor: const Color(
                                                    0xFF2E7D32,
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.check,
                                              size: 18,
                                            ),
                                            label: const Text('Setujui'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF2E7D32,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              if (!isSuperAdmin) return;

                                              setState(() {
                                                account.approvalStatus =
                                                    'Ditolak';
                                              });

                                              setDialogState(() {});

                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Akun ${account.username} ditolak.',
                                                  ),
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.close,
                                              size: 18,
                                            ),
                                            label: const Text('Tolak'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.redAccent,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('TUTUP'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ====================================================
  // UBAH STATUS ITEM
  // ====================================================

  void _changeStatus(ItemModel item) {
    const statuses = ['Pending', 'Proses', 'Selesai'];

    String selectedStatus = statuses.contains(item.status)
        ? item.status
        : 'Pending';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Ubah Status'),
              content: DropdownButtonFormField<String>(
                initialValue: selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() {
                      selectedStatus = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('BATAL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      item.status = selectedStatus;
                    });

                    Navigator.pop(dialogContext);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Status berhasil diubah menjadi $selectedStatus!',
                        ),
                      ),
                    );
                  },
                  child: const Text('SIMPAN'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ====================================================
  // DETAIL ITEM
  // ====================================================

  void _showDetail(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Detail Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text('ID: ${item.id}'),
              const SizedBox(height: 8),
              Text('Kategori: ${item.category}'),
              const SizedBox(height: 8),
              Text('Status: ${item.status}'),
              const SizedBox(height: 8),
              Text('Dibuat oleh: ${item.createdBy}'),
              const SizedBox(height: 8),
              Text('Deskripsi: ${item.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('TUTUP'),
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  // HAPUS ITEM
  // ====================================================

  void _deleteItem(ItemModel item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Item?'),
          content: Text('Apakah kamu yakin ingin menghapus "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  globalItemList.remove(item);
                });

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Item berhasil dihapus!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  // LOGOUT
  // ====================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah kamu yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('KELUAR'),
            ),
          ],
        );
      },
    );
  }

  // ====================================================
  // HITUNG STATUS ITEM
  // ====================================================

  int countStatus(String status) {
    return globalItemList.where((item) => item.status == status).length;
  }

  // ====================================================
  // DASHBOARD
  // ====================================================

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings),
            SizedBox(width: 10),
            Flexible(
              child: Text(
                'ADMIN DASHBOARD',
                style: TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // TOMBOL PERSETUJUAN HANYA UNTUK ADMIN1
          if (isSuperAdmin)
            IconButton(
              tooltip: 'Persetujuan Akun',
              onPressed: _showPendingAccounts,
              icon: Badge(
                isLabelVisible: pendingUsers.isNotEmpty,
                label: Text('${pendingUsers.length}'),
                child: const Icon(Icons.group_add),
              ),
            ),

          // TOMBOL LOGOUT
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),

      body: Column(
        children: [
          // ==================================================
          // COVER
          // ==================================================
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
              ),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 70,
                  height: 70,
                  child: Image(
                    image: AssetImage('assets/logosmk.png'),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SMKN 1 BERINGIN',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Halo, ${widget.user.username}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Kelola task dan inventory',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // INFORMASI PERSETUJUAN - HANYA UNTUK ADMIN1
          // ==================================================
          if (isSuperAdmin)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFF1B5E20),
                    child: Icon(Icons.person_add_alt_1, color: Colors.white),
                  ),
                  title: const Text(
                    'Persetujuan Akun',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    pendingUsers.isEmpty
                        ? 'Tidak ada akun yang menunggu'
                        : '${pendingUsers.length} akun menunggu persetujuan',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: _showPendingAccounts,
                ),
              ),
            ),

          // ==================================================
          // STATISTIK
          // ==================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: statCard(
                    Icons.inventory_2,
                    'TOTAL',
                    '${globalItemList.length}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: statCard(
                    Icons.pending,
                    'PENDING',
                    '${countStatus('Pending')}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: statCard(
                    Icons.sync,
                    'PROSES',
                    '${countStatus('Proses')}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: statCard(
                    Icons.check_circle,
                    'SELESAI',
                    '${countStatus('Selesai')}',
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // FILTER KATEGORI
          // ==================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: DropdownButtonFormField<String>(
              initialValue: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Filter Kategori',
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Semua', child: Text('Semua')),
                DropdownMenuItem(value: 'Task', child: Text('Task')),
                DropdownMenuItem(
                  value: 'Inventaris',
                  child: Text('Inventaris'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCategory = value;
                  });
                }
              },
            ),
          ),

          // ==================================================
          // JUDUL LIST
          // ==================================================
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF66BB6A)),
                SizedBox(width: 10),
                Text(
                  'TASK / INVENTORY LIST',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // ==================================================
          // LIST DATA ITEM
          // ==================================================
          Expanded(
            child: items.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data.',
                      style: TextStyle(color: Colors.white54, fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF2E7D32),
                            child: Icon(
                              item.category == 'Task'
                                  ? Icons.assignment
                                  : Icons.inventory_2,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${item.category} • ${item.status}\n'
                            'Dibuat oleh: ${item.createdBy}',
                          ),
                          isThreeLine: true,
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'status') {
                                _changeStatus(item);
                              } else if (value == 'detail') {
                                _showDetail(item);
                              } else if (value == 'delete') {
                                _deleteItem(item);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'status',
                                child: Text('Ubah Status'),
                              ),
                              PopupMenuItem(
                                value: 'detail',
                                child: Text('Lihat Detail'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // KARTU STATISTIK
  // ====================================================

  Widget statCard(IconData icon, String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF66BB6A), size: 25),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 9, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }
}
