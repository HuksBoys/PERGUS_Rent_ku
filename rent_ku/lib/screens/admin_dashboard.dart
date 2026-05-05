import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/barang_provider.dart';
import '../providers/transaksi_provider.dart';
import '../providers/theme_provider.dart';
import '../models/barang_model.dart';
import '../utils/constants.dart';
import '../widgets/skeleton_loader.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'scanner_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
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
        title: const Text('Admin Dashboard',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ScannerScreen())),
          ),
          IconButton(
            icon: Icon(context.watch<ThemeProvider>().isDarkMode
                ? Icons.light_mode
                : Icons.dark_mode),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalBarang = barangProvider.items.length;
    final totalTransaksi = transaksiProvider.transaksi.length;
    final transaksiAktif =
        transaksiProvider.transaksi.where((t) => t.status == 'dipinjam').length;

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
          const Text('Statistik Bisnis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatCard(
                  'Total Barang', totalBarang.toString(), Icons.inventory,
                  Colors.blue),
              _buildStatCard('Transaksi Aktif', transaksiAktif.toString(),
                  Icons.timer, Colors.orange),
              _buildStatCard(
                  'Total Sewa', totalTransaksi.toString(), Icons.receipt,
                  Colors.green),
              _buildStatCard(
                  'Pendapatan',
                  NumberFormat.compactCurrency(locale: 'id', symbol: 'Rp ')
                      .format(totalPendapatan),
                  Icons.payments,
                  Colors.purple),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Grafik Pendapatan per Kategori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            height: 200,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1000000,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        const style = TextStyle(
                            fontSize: 10, fontWeight: FontWeight.bold);
                        String text = '';
                        switch (value.toInt()) {
                          case 0:
                            text = 'Kamera';
                            break;
                          case 1:
                            text = 'Laptop';
                            break;
                          case 2:
                            text = 'Drone';
                            break;
                          case 3:
                            text = 'HP';
                            break;
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(text, style: style),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: _generateBarGroups(transaksiProvider),
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Text('Aktivitas Terbaru',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

  List<BarChartGroupData> _generateBarGroups(TransaksiProvider provider) {
    Map<String, double> revenueMap = {
      'Kamera': 0,
      'Laptop': 0,
      'Drone': 0,
      'HP': 0
    };

    for (var t in provider.transaksi) {
      for (var d in t.detailTransaksi) {
        String cat = d.barang?.kategori ?? 'Lainnya';
        if (revenueMap.containsKey(cat)) {
          revenueMap[cat] =
              revenueMap[cat]! + (d.barang?.hargaSewa ?? 0) * d.jumlah;
        }
      }
    }

    List<String> keys = revenueMap.keys.toList();
    return List.generate(keys.length, (i) {
      double value = revenueMap[keys[i]]!;
      return BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: value > 0 ? value : 50000,
            color: Colors.blueAccent,
            width: 20,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
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
            Text(value,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(title,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: SkeletonLoader.productGrid(),
          )
        : ListView.builder(
            itemCount: provider.items.length,
            itemBuilder: (context, index) {
              final item = provider.items[index];
              return ListTile(
                leading: item.gambarUrl != null
                    ? Image.network(item.gambarUrl!, width: 50)
                    : const Icon(Icons.image),
                title: Text(item.namaBarang),
                subtitle: Text('Stok: ${item.stok} | Rp ${item.hargaSewa}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showDialog(
                          context: context,
                          builder: (_) => BarangFormDialog(barang: item)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return provider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.transaksi.length,
            itemBuilder: (context, index) {
              final t =
                  provider.transaksi[provider.transaksi.length - 1 - index];

              final isLate = t.status == 'dipinjam' &&
                  DateTime.now().isAfter(t.tanggalKembali);

              Color statusColor = Colors.green;
              if (isLate) {
                statusColor = Colors.red;
              } else if (t.status == 'dipinjam') {
                statusColor = Colors.orange;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  onTap: () => _showTransactionDetail(context, t),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(
                      isLate
                          ? Icons.warning_amber_rounded
                          : (t.status == 'dipinjam'
                              ? Icons.timer
                              : Icons.check_circle_outline),
                      color: statusColor,
                    ),
                  ),
                  title: Text('TRX-${t.id} • ${t.user?.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    '${DateFormat('dd MMM').format(t.tanggalPinjam)} - ${DateFormat('dd MMM').format(t.tanggalKembali)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isLate ? 'TERLAMBAT' : t.status.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          );
  }

  void _showTransactionDetail(BuildContext context, t) {
    final provider = context.read<TransaksiProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey.shade900 : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Detail Transaksi',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87)),
                IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildInfoRow(
                'Customer', t.user?.name ?? 'Unknown', Icons.person_outline),
            _buildInfoRow('Email', t.user?.email ?? '-', Icons.email_outlined),
            _buildInfoRow(
                'Tanggal Pinjam',
                DateFormat('dd MMMM yyyy').format(t.tanggalPinjam),
                Icons.calendar_today_outlined),
            _buildInfoRow(
                'Jadwal Kembali',
                DateFormat('dd MMMM yyyy').format(t.tanggalKembali),
                Icons.event_available_outlined),
            const SizedBox(height: 16),
            const Text('Item yang Disewa:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...t.detailTransaksi
                .map<Widget>((d) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right,
                              size: 16, color: Colors.blueAccent),
                          Expanded(
                              child: Text('${d.barang?.namaBarang} (${d.jumlah}x)')),
                          Text(NumberFormat.currency(
                                  locale: 'id', symbol: 'Rp ', decimalDigits: 0)
                              .format((d.barang?.hargaSewa ?? 0) * d.jumlah)),
                        ],
                      ),
                    ))
                .toList(),
            const SizedBox(height: 32),
            if (t.status == 'dipinjam')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await provider.updateStatus(t.id, 'kembali');
                    if (context.mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Status Berhasil Diupdate!')));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('TANDAI SUDAH KEMBALI',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
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
            TextField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Barang')),
            TextField(
                controller: _kategoriController,
                decoration: const InputDecoration(labelText: 'Kategori')),
            TextField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi')),
            TextField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: 'Harga Sewa'),
                keyboardType: TextInputType.number),
            TextField(
                controller: _stokController,
                decoration: const InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pilih Gambar'),
            ),
            if (_imageFile != null)
              Text('Gambar dipilih: ${_imageFile!.path.split('/').last}'),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: const Text('Batal')),
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
