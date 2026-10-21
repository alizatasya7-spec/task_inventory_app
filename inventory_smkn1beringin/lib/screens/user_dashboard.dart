import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'add_item_screen.dart';
import 'login_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  final UserAccount user;

  const UserDashboardScreen({super.key, required this.user});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String selectedCategory = 'Semua';

  // ======================================================
  // FILTER DATA USER
  // ======================================================

  List<ItemModel> get filteredItems {
    final userItems = globalItemList
        .where((item) => item.createdBy == widget.user.username)
        .toList();

    if (selectedCategory == 'Semua') {
      return userItems;
    }

    return userItems
        .where((item) => item.category == selectedCategory)
        .toList();
  }

  // ======================================================
  // TAMBAH DATA
  // ======================================================

  void _openAddItem() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddItemScreen(user: widget.user)),
    );

    if (result == true) {
      setState(() {});
    }
  }

  // ======================================================
  // DETAIL DATA
  // ======================================================

  void _showDetail(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: Color(0xFF66BB6A)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Detail Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailItem('Nama', item.title, Icons.edit),
                const SizedBox(height: 15),
                _detailItem('Kategori', item.category, Icons.category),
                const SizedBox(height: 15),
                _detailItem('Status', item.status, Icons.flag),
                const SizedBox(height: 15),
                _detailItem('Deskripsi', item.description, Icons.description),
                const SizedBox(height: 15),
                _detailItem('Dibuat oleh', item.createdBy, Icons.person),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('TUTUP'),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // TAMPILAN DETAIL
  // ======================================================

  Widget _detailItem(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF66BB6A)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.white60),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================================================
  // KONFIRMASI HAPUS
  // ======================================================

  void _confirmDelete(ItemModel item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hapus Data?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text('Apakah kamu yakin ingin menghapus "${item.title}"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                _deleteItem(item);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('HAPUS'),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // HAPUS DATA
  // ======================================================

  void _deleteItem(ItemModel item) {
    setState(() {
      globalItemList.removeWhere((data) => data.id == item.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil dihapus'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ======================================================
  // LOGOUT
  // ======================================================

  void _logout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text('Apakah Anda ingin keluar dari akun?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('BATAL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF388E3C),
                foregroundColor: Colors.white,
              ),
              child: const Text('KELUAR'),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final items = filteredItems;

    final total = items.length;

    final pending = items.where((item) => item.status == 'Pending').length;

    final proses = items.where((item) => item.status == 'Proses').length;

    final selesai = items.where((item) => item.status == 'Selesai').length;

    return Scaffold(
      // ==================================================
      // APP BAR
      // ==================================================
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D120E),
        elevation: 0,
        titleSpacing: 15,
        title: const Row(
          children: [
            Icon(Icons.person, size: 22),
            SizedBox(width: 10),
            Text(
              'USER DASHBOARD',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),

      // ==================================================
      // TOMBOL TAMBAH
      // ==================================================
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddItem,
        backgroundColor: const Color(0xFF66BB6A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),

      // ==================================================
      // BODY
      // ==================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==================================================
            // HEADER
            // ==================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
                ),
              ),
              child: Row(
                children: [
                  // LOGO TANPA BACKGROUND
                  Image.asset(
                    'assets/logosmk.png',
                    width: 65,
                    height: 65,
                    fit: BoxFit.contain,
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SMKN 1 BERINGIN',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Halo, ${widget.user.username}',
                          style: const TextStyle(fontSize: 14),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Kelola task dan inventory kamu',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // STATISTIK
            // ==================================================
            Row(
              children: [
                Expanded(
                  child: _statCard(
                    Icons.inventory_2_outlined,
                    total.toString(),
                    'TOTAL',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    Icons.more_horiz,
                    pending.toString(),
                    'PENDING',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(Icons.sync, proses.toString(), 'PROSES'),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _statCard(
                    Icons.check_circle,
                    selesai.toString(),
                    'SELESAI',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==================================================
            // FILTER KATEGORI
            // ==================================================
            const Text(
              'Filter Kategori',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 7),

            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.filter_list),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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

            const SizedBox(height: 20),

            // ==================================================
            // JUDUL LIST
            // ==================================================
            const Row(
              children: [
                Icon(Icons.list_alt, color: Color(0xFF66BB6A)),
                SizedBox(width: 10),
                Text(
                  'TASK / INVENTORY LIST',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // LIST DATA
            // ==================================================
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B16),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Center(
                  child: Text(
                    'Belum ada data.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              )
            else
              ...items.map((item) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151B16),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),

                    // ICON
                    leading: CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF2E7D32),
                      child: Icon(
                        item.category == 'Task'
                            ? Icons.assignment
                            : Icons.inventory_2,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),

                    // NAMA
                    title: Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),

                    // KATEGORI + STATUS
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '${item.category} • ${item.status}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    // DETAIL + HAPUS
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // DETAIL
                        IconButton(
                          onPressed: () {
                            _showDetail(item);
                          },
                          icon: const Icon(
                            Icons.visibility_outlined,
                            color: Color(0xFF66BB6A),
                          ),
                          tooltip: 'Detail',
                        ),

                        // HAPUS
                        IconButton(
                          onPressed: () {
                            _confirmDelete(item);
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // CARD STATISTIK
  // ======================================================

  Widget _statCard(IconData icon, String value, String label) {
    return Container(
      height: 82,
      decoration: BoxDecoration(
        color: const Color(0xFF151B16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF66BB6A), size: 21),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          Text(
            label,
            style: const TextStyle(fontSize: 8, color: Colors.white60),
          ),
        ],
      ),
    );
  }
}
