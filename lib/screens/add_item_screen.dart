import 'package:flutter/material.dart';
import '../models/item_model.dart';

class AddItemScreen extends StatefulWidget {
  final UserAccount user;

  const AddItemScreen({super.key, required this.user});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedRole;
  String? selectedStatus;

  final List<String> roles = ['Task', 'Inventory'];

  final Map<String, List<String>> statusOptions = {
    'Task': ['Pending', 'Process', 'Selesai', 'Belum Selesai'],
    'Inventory': [
      'Belum Dipinjam',
      'Dipinjam',
      'Sudah Dikembalikan',
      'Belum Dikembalikan',
    ],
  };

  List<String> get currentStatuses {
    if (selectedRole == null) {
      return [];
    }

    return statusOptions[selectedRole] ?? [];
  }

  void saveItem() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRole == null || selectedStatus == null) {
      return;
    }

    final newItem = ItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: nameController.text.trim(),
      category: selectedRole!,
      status: selectedStatus!,
      description: descriptionController.text.trim(),
      createdBy: widget.user.username,
    );

    globalItemList.add(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data berhasil ditambahkan!'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D120E),
        title: const Text(
          'Tambah Data Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B5E20), Color(0xFF66BB6A)],
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add_box, size: 45, color: Colors.white),
                    SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tambah Item',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Masukkan data task atau inventory',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // NAMA
              const Text(
                'Nama',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama item',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ROLE
              const Text(
                'Role',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: selectedRole,
                isExpanded: true,
                decoration: const InputDecoration(
                  hintText: 'Pilih Task atau Inventory',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value;

                    // Reset status saat Role berubah.
                    selectedStatus = value == null
                        ? null
                        : statusOptions[value]!.first;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Role wajib dipilih';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // STATUS
              const Text(
                'Status',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                key: ValueKey(selectedRole),
                value: selectedStatus,
                isExpanded: true,
                decoration: InputDecoration(
                  hintText: selectedRole == null
                      ? 'Pilih Role terlebih dahulu'
                      : 'Pilih status',
                  prefixIcon: const Icon(Icons.pending_actions),
                  border: const OutlineInputBorder(),
                ),
                items: currentStatuses.map((status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(status, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: selectedRole == null
                    ? null
                    : (value) {
                        setState(() {
                          selectedStatus = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Status wajib dipilih';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // DESKRIPSI
              const Text(
                'Deskripsi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Masukkan deskripsi item',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Deskripsi wajib diisi';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // PEMBUAT DATA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF151B16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFF66BB6A)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dibuat oleh: ${widget.user.username}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // SIMPAN DATA
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: saveItem,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'SIMPAN DATA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF66BB6A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
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
