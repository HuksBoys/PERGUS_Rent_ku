import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/transaksi_provider.dart';
import '../providers/theme_provider.dart';
import '../models/barang_model.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      context.read<BarangProvider>().fetchItems();
      context.read<TransaksiProvider>().fetchTransaksi();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Ringkasan'),
            Tab(icon: Icon(Icons.inventory), text: 'Barang'),
            Tab(icon: Icon(Icons.receipt_long), text: 'Transaksi'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const OverviewTab(),
          const BarangTab(),
          const TransaksiTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBarangDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddBarangDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const BarangFormDialog());
  }
}

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final barangProvider = context.watch<BarangProvider>();
    final transaksiProvider = context.watch<TransaksiProvider>();

    final totalBarang = barangProvider.items.length;
    final totalTransaksi = transaksiProvider.transaksi.length;
    final transaksiAktif = transaksiProvider.transaksi.where((t) => t.status == 'dipinjam').length;
    
    double totalPendapatan = 0;
    for (var t in transaksiProvider.transaksi) {
      final days = t.tanggalKembali.difference(t.tanggalPinjam).inDays + 1;
      for (var d in t.detailTransaksi) {
        totalPendapatan += (d.barang?.hargaSewa ?? 0) * d.jumlah * days;
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Statistik Bisnis', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard('Total Barang', totalBarang.toString(), Icons.inventory, Colors.blue),
              _buildStatCard('Transaksi Aktif', transaksiAktif.toString(), Icons.timer, Colors.orange),
              _buildStatCard('Total Sewa', totalTransaksi.toString(), Icons.receipt, Colors.green),
              _buildStatCard('Pendapatan', NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ').format(totalPendapatan), Icons.payments, Colors.purple),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Aktivitas Terbaru', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...transaksiProvider.transaksi.reversed.take(5).map((t) => Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(t.user?.name ?? 'Unknown'),
              subtitle: Text('Menyewa ${t.detailTransaksi.length} item'),
              trailing: Text(DateFormat('dd MMM').format(t.tanggalPinjam)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class BarangTab extends StatelessWidget {
  const BarangTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BarangProvider>();
    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ListTile(
                leading: item.gambar != null
                    ? Image.network('http://localhost:8000/storage/barang/${item.gambar}', width: 50)
                    : const Icon(Icons.image),
                title: Text(item.namaBarang),
                subtitle: Text('Stok: ${item.stok} | Rp ${item.hargaSewa}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showDialog(context: context, builder: (_) => BarangFormDialog(barang: item)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => provider.deleteItem(item.id),
                    ),
                  ],
                ),
              );
            },
          );
  }
}

class TransaksiTab extends StatelessWidget {
  const TransaksiTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransaksiProvider>();
    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: provider.transaksi.length,
            itemBuilder: (context, index) {
              final t = provider.transaksi[index];
              return ExpansionTile(
                title: Text('Transaksi #${t.id} - ${t.user?.name}'),
                subtitle: Text('Status: ${t.status.toUpperCase()}'),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pinjam: ${DateFormat('dd MMM yyyy').format(t.tanggalPinjam)}'),
                        Text('Kembali: ${DateFormat('dd MMM yyyy').format(t.tanggalKembali)}'),
                        const Divider(),
                        ...t.detailTransaksi.map((d) => Text('• ${d.barang?.namaBarang} (${d.jumlah}x)')),
                        const SizedBox(height: 16),
                        if (t.status == 'dipinjam')
                          ElevatedButton(
                            onPressed: () => provider.updateStatus(t.id, 'kembali'),
                            child: const Text('Tandai Sudah Kembali'),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
  }
}

class BarangFormDialog extends StatefulWidget {
  final BarangModel? barang;
  const BarangFormDialog({super.key, this.barang});

  @override
  State<BarangFormDialog> createState() => _BarangFormDialogState();
}

class _BarangFormDialogState extends State<BarangFormDialog> {
  final _namaController = TextEditingController();
  final _kategoriController = TextEditingController();
  final _deskripsiController = TextEditingController();
  final _hargaController = TextEditingController();
  final _stokController = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.barang != null) {
      _namaController.text = widget.barang!.namaBarang;
      _kategoriController.text = widget.barang!.kategori;
      _deskripsiController.text = widget.barang!.deskripsi ?? '';
      _hargaController.text = widget.barang!.hargaSewa.toString();
      _stokController.text = widget.barang!.stok.toString();
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.barang == null ? 'Tambah Barang' : 'Edit Barang'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _namaController, decoration: const InputDecoration(labelText: 'Nama Barang')),
            TextField(controller: _kategoriController, decoration: const InputDecoration(labelText: 'Kategori')),
            TextField(controller: _deskripsiController, decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(controller: _hargaController, decoration: const InputDecoration(labelText: 'Harga Sewa'), keyboardType: TextInputType.number),
            TextField(controller: _stokController, decoration: const InputDecoration(labelText: 'Stok'), keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            if (_imageFile != null) Text('Gambar dipilih: ${_imageFile!.path.split('/').last}'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () async {
            final data = {
              'nama_barang': _namaController.text,
              'kategori': _kategoriController.text,
              'deskripsi': _deskripsiController.text,
              'harga_sewa': _hargaController.text,
              'stok': _stokController.text,
              if (_imageFile != null) 'gambar_file': _imageFile,
            };
            if (widget.barang == null) {
              await context.read<BarangProvider>().addItem(data);
            } else {
              await context.read<BarangProvider>().updateItem(widget.barang!.id, data);
            }
            if (mounted) Navigator.pop(context);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
