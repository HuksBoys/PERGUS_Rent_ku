import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/barang_model.dart';
import '../providers/transaksi_provider.dart';
import '../utils/constants.dart';
import 'package:lottie/lottie.dart';

class DetailScreen extends StatefulWidget {
  final BarangModel barang;
  const DetailScreen({super.key, required this.barang});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  int _jumlah = 1;
  DateTime _tanggalPinjam = DateTime.now();
  DateTime _tanggalKembali = DateTime.now().add(const Duration(days: 1));

  void _sewa() async {
    try {
      await context.read<TransaksiProvider>().createTransaksi({
        'tanggal_pinjam': DateFormat('yyyy-MM-dd').format(_tanggalPinjam),
        'tanggal_kembali': DateFormat('yyyy-MM-dd').format(_tanggalKembali),
        'items': [
          {'barang_id': widget.barang.id, 'jumlah': _jumlah}
        ],
      });
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Lottie.network(
                  'https://assets10.lottiefiles.com/packages/lf20_kz9m5c2v.json', // More stable URL
                  width: 150,
                  height: 150,
                  repeat: false,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.check_circle, size: 80, color: Colors.green);
                  },
                ),
                const Text('Berhasil menyewa barang!', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Back to Home
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyewa: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Barang')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: widget.barang.gambarUrl != null
                  ? Hero(
                      tag: 'barang_${widget.barang.id}',
                      child: Image.network(widget.barang.gambarUrl!, fit: BoxFit.cover),
                    )
                  : const Icon(Icons.image, size: 100, color: Colors.grey),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.barang.namaBarang, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(widget.barang.hargaSewa),
                    style: const TextStyle(fontSize: 20, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(widget.barang.deskripsi ?? 'Tidak ada deskripsi.'),
                  const SizedBox(height: 16),
                  Text('Stok Tersedia: ${widget.barang.stok}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(height: 32),
                  const Text('Atur Penyewaan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah:'),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _jumlah > 1 ? () => setState(() => _jumlah--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                          ),
                          Text('$_jumlah', style: const TextStyle(fontSize: 18)),
                          IconButton(
                            onPressed: _jumlah < widget.barang.stok ? () => setState(() => _jumlah++) : null,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ListTile(
                    title: const Text('Tanggal Pinjam'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_tanggalPinjam)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tanggalPinjam,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                      );
                      if (picked != null) setState(() => _tanggalPinjam = picked);
                    },
                  ),
                  ListTile(
                    title: const Text('Tanggal Kembali'),
                    subtitle: Text(DateFormat('dd MMMM yyyy').format(_tanggalKembali)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _tanggalKembali,
                        firstDate: _tanggalPinjam.add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                      );
                      if (picked != null) setState(() => _tanggalKembali = picked);
                    },
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.barang.stok > 0 ? _sewa : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('SEWA SEKARANG'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
